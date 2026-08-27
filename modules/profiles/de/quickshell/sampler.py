#!/usr/bin/env python3
"""Low-overhead JSON-lines sampler for the Quickshell status bar.

The shell owns event-driven state such as power, networking, Bluetooth, and
PipeWire links. This process only samples values that are not exposed by the
native Quickshell APIs. It deliberately uses the Python standard library so
the process has no extra runtime dependencies.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import signal
import subprocess
import threading
import time
from pathlib import Path
from typing import Any


SYSTEM_AC_INTERVAL = 2.0
SYSTEM_BATTERY_INTERVAL = 10.0
AMBIENT_INTERVAL = 10.0

_stop_event = threading.Event()


def _stop(_signum: int, _frame: Any) -> None:
    _stop_event.set()


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8").strip()
    except (OSError, UnicodeError):
        return ""


def read_int(path: Path) -> int | None:
    value = read_text(path)
    try:
        return int(value)
    except ValueError:
        return None


def clamp_percent(value: float | int) -> int:
    return max(0, min(100, int(round(value))))


class Sampler:
    def __init__(self, pw_dump: str) -> None:
        self.pw_dump = pw_dump
        self.previous_cpu: tuple[int, int] | None = None

    def emit(self, kind: str, values: dict[str, Any]) -> None:
        payload = {"kind": kind, **values}
        try:
            print(json.dumps(payload, separators=(",", ":")), flush=True)
        except BrokenPipeError:
            raise SystemExit(0)

    def read_cpu_counters(self) -> tuple[int, int] | None:
        try:
            with open("/proc/stat", encoding="ascii") as proc_stat:
                for line in proc_stat:
                    if not line.startswith("cpu "):
                        continue
                    fields = [int(field) for field in line.split()[1:]]
                    if len(fields) < 4:
                        return None
                    # Guest time is already included in user/nice. Use the
                    # first eight counters so it is not double-counted while
                    # still including steal time on virtualized systems.
                    counters = fields[:8]
                    return sum(counters), counters[3] + (counters[4] if len(counters) > 4 else 0)
        except (OSError, ValueError):
            return None
        return None

    def sample_system(self) -> dict[str, Any]:
        counters = self.read_cpu_counters()
        cpu = 0
        if counters is not None and self.previous_cpu is not None:
            total_delta = counters[0] - self.previous_cpu[0]
            idle_delta = counters[1] - self.previous_cpu[1]
            if total_delta > 0:
                cpu = clamp_percent((total_delta - idle_delta) * 100 / total_delta)
        if counters is not None:
            self.previous_cpu = counters

        return {
            "cpu": cpu,
            "cpuFrequencyMHz": self.read_cpu_frequency(),
            "cpuCores": os.cpu_count() or 0,
            "loadAverage": self.read_load_average(),
            **self.read_memory(),
        }

    @staticmethod
    def read_cpu_frequency() -> int:
        frequencies: list[int] = []
        for path in glob.glob("/sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq"):
            value = read_int(Path(path))
            if value is not None and value > 0:
                frequencies.append(value)
        if frequencies:
            return sum(frequencies) // len(frequencies) // 1000

        values: list[float] = []
        try:
            with open("/proc/cpuinfo", encoding="ascii", errors="ignore") as cpuinfo:
                for line in cpuinfo:
                    if line.lower().startswith("cpu mhz"):
                        try:
                            values.append(float(line.split(":", 1)[1]))
                        except (IndexError, ValueError):
                            continue
        except OSError:
            pass
        return int(round(sum(values) / len(values))) if values else 0

    @staticmethod
    def read_load_average() -> float:
        fields = read_text(Path("/proc/loadavg")).split()
        try:
            return float(fields[0])
        except (IndexError, ValueError):
            return 0.0

    @staticmethod
    def read_memory() -> dict[str, int]:
        values: dict[str, int] = {}
        try:
            with open("/proc/meminfo", encoding="ascii") as meminfo:
                for line in meminfo:
                    key, separator, raw_value = line.partition(":")
                    if not separator:
                        continue
                    fields = raw_value.split()
                    if not fields:
                        continue
                    try:
                        # Meminfo values are kB when a unit is present.
                        values[key] = int(fields[0])
                    except ValueError:
                        continue
        except OSError:
            return {
                "memory": 0,
                "memoryUsed": 0,
                "memoryTotal": 0,
                "swapUsed": 0,
                "swapTotal": 0,
            }

        total = values.get("MemTotal", 0)
        available = values.get("MemAvailable", values.get("MemFree", 0))
        used = max(0, total - available)
        swap_total = values.get("SwapTotal", 0)
        swap_free = values.get("SwapFree", 0)
        swap_used = max(0, swap_total - swap_free)
        return {
            "memory": clamp_percent(used * 100 / total) if total else 0,
            "memoryUsed": round(used / 1024),
            "memoryTotal": round(total / 1024),
            "swapUsed": round(swap_used / 1024),
            "swapTotal": round(swap_total / 1024),
        }

    @staticmethod
    def sample_ambient() -> dict[str, int]:
        return {
            "temperature": Sampler.read_temperature(),
            "brightness": Sampler.read_brightness(),
        }

    @staticmethod
    def read_temperature() -> int:
        candidates: list[tuple[int, int]] = []
        for zone in sorted(glob.glob("/sys/class/thermal/thermal_zone*")):
            zone_path = Path(zone)
            value = read_int(zone_path / "temp")
            if value is None or value <= 0:
                continue
            zone_type = read_text(zone_path / "type").lower()
            priority = 0
            if any(name in zone_type for name in ("pkg", "cpu", "core", "x86")):
                priority = 1
            candidates.append((priority, value))
        if not candidates:
            return 0
        candidates.sort(key=lambda item: item[0], reverse=True)
        return max(0, min(150, round(candidates[0][1] / 1000)))

    @staticmethod
    def read_brightness() -> int:
        for backlight in sorted(glob.glob("/sys/class/backlight/*")):
            base = Path(backlight)
            current = read_int(base / "brightness")
            maximum = read_int(base / "max_brightness")
            if current is not None and maximum is not None and maximum > 0:
                return clamp_percent(current * 100 / maximum)
        return 0

    @staticmethod
    def read_on_battery() -> bool:
        battery_present = False
        discharging = False
        mains_online = False
        for supply in sorted(glob.glob("/sys/class/power_supply/*")):
            base = Path(supply)
            supply_type = read_text(base / "type").lower()
            if supply_type == "battery":
                battery_present = True
                status = read_text(base / "status").lower()
                if status == "discharging":
                    discharging = True
                elif status in {"charging", "full", "not charging"}:
                    mains_online = True
            else:
                mains_online = read_text(base / "online") == "1" or mains_online
        if discharging:
            return True
        return battery_present and not mains_online

    def sample_privacy(self) -> dict[str, Any]:
        empty = {
            "audioIn": False,
            "screenShare": False,
            "audioInApps": [],
            "screenShareApps": [],
        }
        if not self.pw_dump:
            return empty
        try:
            result = subprocess.run(
                [self.pw_dump],
                capture_output=True,
                text=True,
                timeout=1.0,
                check=False,
            )
            payload = json.loads(result.stdout)
        except (OSError, UnicodeError, subprocess.SubprocessError, json.JSONDecodeError):
            return empty

        if not isinstance(payload, list):
            return empty
        audio_apps: set[str] = set()
        screen_apps: set[str] = set()
        for item in payload:
            if not isinstance(item, dict) or item.get("type") != "PipeWire:Interface:Node":
                continue
            info = item.get("info")
            if not isinstance(info, dict) or str(info.get("state", "")).lower() != "running":
                continue
            props = info.get("props")
            if not isinstance(props, dict):
                props = {}
            if (str(props.get("stream.monitor", "false")).lower() == "true" or
                    str(props.get("media.category", "")).lower() == "monitor"):
                continue
            names = [props.get("application.name"), props.get("node.name"), props.get("media.name")]
            name = next((str(value) for value in names if isinstance(value, str) and value), "Unknown")
            if name.lower() == "cava" or str(props.get("node.name", "")).lower() == "cava":
                continue
            media_class = str(props.get("media.class", ""))
            if media_class == "Stream/Input/Audio":
                audio_apps.add(name)
            elif media_class == "Stream/Input/Video":
                screen_apps.add(name)
        return {
            "audioIn": bool(audio_apps),
            "screenShare": bool(screen_apps),
            "audioInApps": sorted(audio_apps),
            "screenShareApps": sorted(screen_apps),
        }


def run() -> None:
    sampler = Sampler("")
    now = time.monotonic()
    next_system = now
    next_ambient = now
    on_battery = sampler.read_on_battery()

    while not _stop_event.is_set():
        now = time.monotonic()
        if now >= next_system:
            # Power state only affects the system cadence, so read it when a
            # system sample is due instead of waking the process once per
            # second just to poll /sys.
            on_battery = sampler.read_on_battery()
            sampler.emit("system", sampler.sample_system())
            next_system = time.monotonic() + (
                SYSTEM_BATTERY_INTERVAL if on_battery else SYSTEM_AC_INTERVAL
            )

        if now >= next_ambient:
            sampler.emit("ambient", sampler.sample_ambient())
            next_ambient = time.monotonic() + AMBIENT_INTERVAL

        next_due = min(next_system, next_ambient)
        # Event.wait() wakes immediately on SIGINT/SIGTERM while otherwise
        # sleeping until the next monotonic deadline. No heartbeat is needed.
        _stop_event.wait(max(0.05, next_due - time.monotonic()))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pw-dump", default="pw-dump", help="path to pw-dump for privacy fallback")
    parser.add_argument("--privacy-once", action="store_true", help="emit one privacy sample and exit")
    args = parser.parse_args()
    signal.signal(signal.SIGINT, _stop)
    signal.signal(signal.SIGTERM, _stop)
    if args.privacy_once:
        sampler = Sampler(args.pw_dump)
        sampler.emit("privacy", sampler.sample_privacy())
        return
    run()


if __name__ == "__main__":
    main()
