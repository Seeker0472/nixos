from __future__ import annotations

import importlib.util
import json
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest import mock


SAMPLER_PATH = Path(__file__).resolve().parents[1] / "sampler.py"
SPEC = importlib.util.spec_from_file_location("quickshell_sampler", SAMPLER_PATH)
assert SPEC is not None and SPEC.loader is not None
sampler_module = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = sampler_module
SPEC.loader.exec_module(sampler_module)


class SamplerTest(unittest.TestCase):
    def test_clamp_percent(self) -> None:
        self.assertEqual(sampler_module.clamp_percent(-1), 0)
        self.assertEqual(sampler_module.clamp_percent(49.6), 50)
        self.assertEqual(sampler_module.clamp_percent(101), 100)

    def test_cpu_delta(self) -> None:
        sampler = sampler_module.Sampler("")
        sampler.previous_cpu = (100, 50)
        with (
            mock.patch.object(sampler, "read_cpu_counters", return_value=(200, 70)),
            mock.patch.object(sampler, "read_cpu_frequency", return_value=2400),
            mock.patch.object(sampler, "read_load_average", return_value=0.5),
            mock.patch.object(
                sampler,
                "read_memory",
                return_value={
                    "memory": 40,
                    "memoryUsed": 400,
                    "memoryTotal": 1000,
                    "swapUsed": 0,
                    "swapTotal": 0,
                },
            ),
        ):
            result = sampler.sample_system()

        self.assertEqual(result["cpu"], 80)
        self.assertEqual(result["cpuFrequencyMHz"], 2400)
        self.assertEqual(sampler.previous_cpu, (200, 70))

    def test_privacy_filters_monitor_and_cava(self) -> None:
        payload = [
            self.node("Stream/Input/Audio", "Recorder"),
            self.node("Stream/Input/Video", "Meeting"),
            self.node("Stream/Input/Audio", "Cava", node_name="cava"),
            self.node("Stream/Input/Audio", "Monitor", media_category="monitor"),
            self.node("Stream/Input/Audio", "Stopped", state="idle"),
        ]
        sampler = sampler_module.Sampler("/bin/pw-dump")
        completed = SimpleNamespace(stdout=json.dumps(payload))
        with mock.patch.object(sampler_module.subprocess, "run", return_value=completed):
            result = sampler.sample_privacy()

        self.assertTrue(result["audioIn"])
        self.assertTrue(result["screenShare"])
        self.assertEqual(result["audioInApps"], ["Recorder"])
        self.assertEqual(result["screenShareApps"], ["Meeting"])

    @staticmethod
    def node(
        media_class: str,
        application_name: str,
        *,
        node_name: str = "stream",
        media_category: str = "",
        state: str = "running",
    ) -> dict[str, object]:
        return {
            "type": "PipeWire:Interface:Node",
            "info": {
                "state": state,
                "props": {
                    "media.class": media_class,
                    "application.name": application_name,
                    "node.name": node_name,
                    "media.category": media_category,
                },
            },
        }


if __name__ == "__main__":
    unittest.main()
