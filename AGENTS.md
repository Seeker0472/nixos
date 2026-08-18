# Repository Instructions

## King'sCross

The VPS configuration is `nixosConfigurations."King'sCross"` and targets
`root@vps.seekerer.com`. Follow [the maintenance workflow](docs/kings-cross-maintenance.md)
for changes.

Use `nixos-rebuild test` before `switch` when changing services, networking, SSH,
the kernel, or boot settings. Do not use `nixos-anywhere` for routine updates:
it may run Disko and erase the VPS disk.
