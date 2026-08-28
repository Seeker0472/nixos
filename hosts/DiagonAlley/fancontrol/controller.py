"""Validated fancontrol frontend for DiagonAlley."""

from __future__ import annotations

import argparse
import copy
import fcntl
import json
import os
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, NoReturn


DEFAULT_STATE: dict[str, Any] = {
    "version": 1,
    "mode": "bios",
    "cpu": {
        "zeroRpm": False,
        "minPwm": 96,
        "startTemp": 55,
        "fullTemp": 80,
    },
    "case": {
        "zeroRpm": False,
        "minPwm": 64,
        "startTemp": 50,
        "fullTemp": 80,
    },
}

GROUP_LIMITS = {
    "cpu": {
        "minPwm": (64, 160),
        "startTemp": (40, 65),
        "fullTemp": (70, 85),
        "minimumGap": 10,
        "startPwm": 128,
        "stopPwm": 96,
    },
    "case": {
        "minPwm": (64, 128),
        "startTemp": (40, 65),
        "fullTemp": (65, 85),
        "minimumGap": 10,
        "startPwm": 96,
        "stopPwm": 64,
    },
}

FAN_CHANNELS = {
    "cpu": (1,),
    "case": (3, 4),
}


class ControlError(RuntimeError):
    """An expected controller failure suitable for display in the shell."""


@dataclass(frozen=True)
class Paths:
    sysfs_root: Path
    sys_root: Path
    state_file: Path
    config_file: Path
    lock_file: Path
    systemctl: str
    pkexec: str
    helper: str
    fancontrol: str

    @classmethod
    def from_environment(cls) -> "Paths":
        return cls(
            sysfs_root=Path(os.environ.get("FAN_CONTROL_SYSFS_ROOT", "/sys/class/hwmon")),
            sys_root=Path(os.environ.get("FAN_CONTROL_SYS_ROOT", "/sys")),
            state_file=Path(
                os.environ.get(
                    "FAN_CONTROL_STATE_FILE",
                    "/var/lib/diagonalley-fan-control/state.json",
                )
            ),
            config_file=Path(
                os.environ.get(
                    "FAN_CONTROL_CONFIG_FILE",
                    "/run/diagonalley-fan-control/fancontrol.conf",
                )
            ),
            lock_file=Path(
                os.environ.get(
                    "FAN_CONTROL_LOCK_FILE",
                    "/run/diagonalley-fan-control.lock",
                )
            ),
            systemctl=os.environ.get("FAN_CONTROL_SYSTEMCTL", "systemctl"),
            pkexec=os.environ.get("FAN_CONTROL_PKEXEC", "pkexec"),
            helper=os.environ.get("FAN_CONTROL_HELPER", "diagonalley-fan-control-apply"),
            fancontrol=os.environ.get("FAN_CONTROL_FANCONTROL", "fancontrol"),
        )


def atomic_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary, 0o644)
        os.replace(temporary, path)
    except BaseException:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass
        raise


def read_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def integer(value: Any, label: str, minimum: int, maximum: int) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise ControlError(f"{label} must be an integer")
    if not minimum <= value <= maximum:
        raise ControlError(f"{label} must be between {minimum} and {maximum}")
    return value


def validate_group(name: str, value: Any) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ControlError(f"{name} settings must be an object")
    allowed = {"zeroRpm", "minPwm", "startTemp", "fullTemp"}
    unknown = set(value) - allowed
    if unknown:
        raise ControlError(f"unknown {name} settings: {', '.join(sorted(unknown))}")

    limits = GROUP_LIMITS[name]
    if not isinstance(value.get("zeroRpm"), bool):
        raise ControlError(f"{name}.zeroRpm must be a boolean")
    result = {
        "zeroRpm": value["zeroRpm"],
        "minPwm": integer(value.get("minPwm"), f"{name}.minPwm", *limits["minPwm"]),
        "startTemp": integer(
            value.get("startTemp"),
            f"{name}.startTemp",
            *limits["startTemp"],
        ),
        "fullTemp": integer(
            value.get("fullTemp"),
            f"{name}.fullTemp",
            *limits["fullTemp"],
        ),
    }
    if result["fullTemp"] - result["startTemp"] < limits["minimumGap"]:
        raise ControlError(
            f"{name}.fullTemp must be at least {limits['minimumGap']} C above startTemp"
        )
    return result


def validate_state(value: Any) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ControlError("fan state must be an object")
    allowed = {"version", "mode", "cpu", "case"}
    unknown = set(value) - allowed
    if unknown:
        raise ControlError(f"unknown fan state fields: {', '.join(sorted(unknown))}")
    if value.get("version") != 1:
        raise ControlError("unsupported fan state version")
    if value.get("mode") not in {"bios", "software"}:
        raise ControlError("mode must be bios or software")
    return {
        "version": 1,
        "mode": value["mode"],
        "cpu": validate_group("cpu", value.get("cpu")),
        "case": validate_group("case", value.get("case")),
    }


def merge_patch(state: dict[str, Any], patch: Any) -> dict[str, Any]:
    if not isinstance(patch, dict):
        raise ControlError("patch must be an object")
    allowed = {"mode", "cpu", "case"}
    unknown = set(patch) - allowed
    if unknown:
        raise ControlError(f"unknown patch fields: {', '.join(sorted(unknown))}")

    result = copy.deepcopy(state)
    if "mode" in patch:
        result["mode"] = patch["mode"]
    for group in ("cpu", "case"):
        if group not in patch:
            continue
        if not isinstance(patch[group], dict):
            raise ControlError(f"{group} patch must be an object")
        result[group].update(patch[group])
    return validate_state(result)


class Controller:
    def __init__(self, paths: Paths):
        self.paths = paths

    def load_state(self) -> dict[str, Any]:
        try:
            return validate_state(read_json(self.paths.state_file))
        except (FileNotFoundError, json.JSONDecodeError, OSError, ControlError):
            return copy.deepcopy(DEFAULT_STATE)

    def discover(self) -> dict[str, Path]:
        devices: dict[str, Path] = {}
        try:
            candidates = sorted(self.paths.sysfs_root.glob("hwmon*"))
        except OSError:
            return devices
        for candidate in candidates:
            try:
                name = (candidate / "name").read_text(encoding="utf-8").strip()
            except OSError:
                continue
            if name in {"it8689", "k10temp"} and name not in devices:
                devices[name] = candidate
        return devices

    @staticmethod
    def read_int(path: Path) -> int | None:
        try:
            return int(path.read_text(encoding="utf-8").strip())
        except (OSError, ValueError):
            return None

    def service_active(self) -> bool:
        try:
            completed = subprocess.run(
                [self.paths.systemctl, "is-active", "--quiet", "fancontrol.service"],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError:
            return False
        return completed.returncode == 0

    def status(self) -> dict[str, Any]:
        state = self.load_state()
        devices = self.discover()
        it87 = devices.get("it8689")
        cpu_sensor = devices.get("k10temp")
        available = it87 is not None and cpu_sensor is not None
        active = self.service_active()

        fans: dict[str, dict[str, int | None]] = {}
        if it87 is not None:
            for label, channel in (("cpu", 1), ("case1", 3), ("case2", 4)):
                pwm = self.read_int(it87 / f"pwm{channel}")
                fans[label] = {
                    "rpm": self.read_int(it87 / f"fan{channel}_input"),
                    "pwm": pwm,
                    "percent": None if pwm is None else round(pwm * 100 / 255),
                    "enable": self.read_int(it87 / f"pwm{channel}_enable"),
                }
        else:
            fans = {
                label: {"rpm": None, "pwm": None, "percent": None, "enable": None}
                for label in ("cpu", "case1", "case2")
            }

        enables = [fan["enable"] for fan in fans.values()]
        bios_owned = len(enables) == 3 and all(value == 2 for value in enables)
        if not available:
            control_mode = "unavailable"
        elif state["mode"] == "software" and active:
            control_mode = "software"
        elif state["mode"] == "bios" and bios_owned:
            control_mode = "bios"
        else:
            control_mode = "degraded"

        temperature = None
        if cpu_sensor is not None:
            raw_temperature = self.read_int(cpu_sensor / "temp1_input")
            if raw_temperature is not None:
                temperature = round(raw_temperature / 1000)

        return {
            "available": available,
            "serviceActive": active,
            "controlMode": control_mode,
            "temperature": temperature,
            "fans": fans,
            "settings": state,
        }

    def device_path(self, hwmon: Path) -> str:
        try:
            resolved = (hwmon / "device").resolve(strict=True)
            return str(resolved.relative_to(self.paths.sys_root))
        except (OSError, ValueError) as error:
            raise ControlError(f"cannot resolve device path for {hwmon.name}") from error

    @staticmethod
    def entries(values: dict[str, Any]) -> str:
        return " ".join(f"{key}={value}" for key, value in values.items())

    def build_config(self, state: dict[str, Any], *, absolute: bool = False) -> str:
        devices = self.discover()
        try:
            it87 = devices["it8689"]
            cpu_sensor = devices["k10temp"]
        except KeyError as error:
            raise ControlError("it8689 and k10temp are required for software control") from error

        it_id = str(it87) if absolute else it87.name
        cpu_id = str(cpu_sensor) if absolute else cpu_sensor.name
        temp_path = f"{cpu_id}/temp1_input"
        pwm_paths = [f"{it_id}/pwm{channel}" for channel in (1, 3, 4)]
        fan_paths = [f"{it_id}/fan{channel}_input" for channel in (1, 3, 4)]

        min_temp: dict[str, int] = {}
        max_temp: dict[str, int] = {}
        min_start: dict[str, int] = {}
        min_stop: dict[str, int] = {}
        min_pwm: dict[str, int] = {}
        max_pwm: dict[str, int] = {}
        average: dict[str, int] = {}

        for group, channels in FAN_CHANNELS.items():
            settings = state[group]
            limits = GROUP_LIMITS[group]
            for channel in channels:
                pwm_path = f"{it_id}/pwm{channel}"
                min_temp[pwm_path] = settings["startTemp"]
                max_temp[pwm_path] = settings["fullTemp"]
                min_start[pwm_path] = max(settings["minPwm"], limits["startPwm"])
                min_stop[pwm_path] = (
                    limits["stopPwm"] if settings["zeroRpm"] else settings["minPwm"]
                )
                min_pwm[pwm_path] = 0 if settings["zeroRpm"] else settings["minPwm"]
                max_pwm[pwm_path] = 255
                average[pwm_path] = 3

        return "\n".join(
            (
                "# Generated by diagonalley-fan-control",
                "INTERVAL=3",
                "DEVPATH="
                + (
                    ""
                    if absolute
                    else self.entries(
                        {
                            it_id: self.device_path(it87),
                            cpu_id: self.device_path(cpu_sensor),
                        }
                    )
                ),
                "DEVNAME="
                + ("" if absolute else self.entries({it_id: "it8689", cpu_id: "k10temp"})),
                "FCTEMPS=" + self.entries(dict.fromkeys(pwm_paths, temp_path)),
                "FCFANS=" + self.entries(dict(zip(pwm_paths, fan_paths, strict=True))),
                "MINTEMP=" + self.entries(min_temp),
                "MAXTEMP=" + self.entries(max_temp),
                "MINSTART=" + self.entries(min_start),
                "MINSTOP=" + self.entries(min_stop),
                "MINPWM=" + self.entries(min_pwm),
                "MAXPWM=" + self.entries(max_pwm),
                "AVERAGE=" + self.entries(average),
                "",
            )
        )

    def prepare(self) -> None:
        self.require_root()
        state = self.load_state()
        self.paths.config_file.parent.mkdir(parents=True, exist_ok=True)
        content = (
            self.build_config(state)
            if state["mode"] == "software"
            else "# BIOS owns all fan channels\n"
        )
        self.paths.config_file.write_text(content, encoding="utf-8")
        os.chmod(self.paths.config_file, 0o644)

    def restore_bios(self) -> None:
        self.require_root()
        it87 = self.discover().get("it8689")
        if it87 is None:
            return
        failures = []
        for channel in (1, 3, 4):
            enable = it87 / f"pwm{channel}_enable"
            try:
                enable.write_text("2\n", encoding="ascii")
                if self.read_int(enable) != 2:
                    failures.append(enable.name)
            except OSError:
                failures.append(enable.name)
        if failures:
            raise ControlError(f"failed to return BIOS control for: {', '.join(failures)}")

    def run(self) -> None:
        self.require_root()
        state = self.load_state()
        if state["mode"] == "bios":
            self.restore_bios()
            return
        os.execv(self.paths.fancontrol, [self.paths.fancontrol, str(self.paths.config_file)])

    def systemctl(self, action: str, *, check: bool = True) -> subprocess.CompletedProcess[str]:
        try:
            completed = subprocess.run(
                [self.paths.systemctl, action, "fancontrol.service"],
                check=False,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        except OSError as error:
            raise ControlError(f"unable to {action} fancontrol.service") from error
        if check and completed.returncode != 0:
            message = completed.stderr.strip() or completed.stdout.strip()
            raise ControlError(message or f"unable to {action} fancontrol.service")
        return completed

    def apply_root(self, patch: Any) -> None:
        self.require_root()
        self.paths.lock_file.parent.mkdir(parents=True, exist_ok=True)
        with self.paths.lock_file.open("a+", encoding="utf-8") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            state = merge_patch(self.load_state(), patch)
            atomic_json(self.paths.state_file, state)
            if state["mode"] == "bios":
                self.systemctl("stop")
                self.restore_bios()
                return

            completed = self.systemctl("restart", check=False)
            if completed.returncode == 0:
                return

            state["mode"] = "bios"
            atomic_json(self.paths.state_file, state)
            self.systemctl("stop", check=False)
            self.restore_bios()
            message = completed.stderr.strip() or "fancontrol failed to start"
            raise ControlError(message)

    def apply(self, patch: Any) -> dict[str, Any]:
        merge_patch(self.load_state(), patch)
        try:
            completed = subprocess.run(
                [
                    self.paths.pkexec,
                    self.paths.helper,
                    json.dumps(patch, separators=(",", ":")),
                ],
                check=False,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        except OSError as error:
            raise ControlError("unable to launch the fan control helper") from error
        if completed.returncode != 0:
            message = completed.stderr.strip() or completed.stdout.strip()
            raise ControlError(message or "fan control request was rejected")
        return self.status()

    @staticmethod
    def require_root() -> None:
        if os.geteuid() != 0:
            raise ControlError("this operation requires root privileges")


def parse_json(value: str) -> Any:
    try:
        return json.loads(value)
    except json.JSONDecodeError as error:
        raise ControlError("request must be valid JSON") from error


def fail(message: str, status: int = 1) -> NoReturn:
    print(json.dumps({"error": message}), file=sys.stderr)
    raise SystemExit(status)


def main() -> None:
    parser = argparse.ArgumentParser(description="Control DiagonAlley fans")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("status")
    apply_parser = subparsers.add_parser("apply")
    apply_parser.add_argument("patch")
    root_parser = subparsers.add_parser("apply-root")
    root_parser.add_argument("patch")
    subparsers.add_parser("prepare")
    subparsers.add_parser("run")
    subparsers.add_parser("restore-bios")
    subparsers.add_parser("print-config")
    args = parser.parse_args()
    controller = Controller(Paths.from_environment())

    try:
        if args.command == "status":
            result = controller.status()
        elif args.command == "apply":
            result = controller.apply(parse_json(args.patch))
        elif args.command == "apply-root":
            controller.apply_root(parse_json(args.patch))
            result = controller.status()
        elif args.command == "prepare":
            controller.prepare()
            return
        elif args.command == "run":
            controller.run()
            return
        elif args.command == "restore-bios":
            controller.restore_bios()
            return
        elif args.command == "print-config":
            print(controller.build_config(controller.load_state()), end="")
            return
        else:
            fail("unknown command", 2)
        print(json.dumps(result, separators=(",", ":")))
    except ControlError as error:
        fail(str(error))


if __name__ == "__main__":
    main()
