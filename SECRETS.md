# Secret Management

SOPS uses two human-managed age identities:

- `admin_seeker_age` is installed on `miLaptop` and `nixos-wsl` for daily editing.
- `recovery_age` is kept offline and is a recipient for every encrypted file.

`devVM` and `DiagonAlley` have separate runtime identities. Each can decrypt its
own SSH client key and the shared secrets consumed by that host. `DiagonAlley`
also receives the administrator SSH key so it retains VPS maintenance access.
`gpu01` has a separate runtime identity, scoped to the shared external and
GitHub keys plus the shared Codex authentication file.
The `mi15` and `miPad` nix-on-droid environments each have a dedicated runtime
identity. They can decrypt the same SSH and Codex secrets as `miLaptop`, but
their age private keys are kept separately so either Android device can be
revoked without changing the other one.
The bootstrap identities live under the git-ignored `.secrets/age/` directory.
The SOPS identity itself must be installed out of band because it cannot decrypt
itself.

## SSH layout

- `users/seeker/ssh/<host>.secrets.json` contains one host-specific client key.
- `users/seeker/ssh/external.secrets.json` contains the shared default key for
  outbound SSH to external machines.
- `users/seeker/ssh/github.secrets.json` contains the single GitHub key shared by
  the four managed development clients.
- `users/seeker/ssh/admin.secrets.json` retains the existing administrator key and is
  deployed to `DiagonAlley`, `miLaptop`, `nixos-wsl`, `mi15`, and `miPad`.
- `gpu01` receives the four development public keys in `authorized_keys` and
  the shared external and GitHub private keys, but no mesh or administrator
  private key.

Public keys use the `_unencrypted` suffix inside their SOPS documents. They are
not confidential, and keeping them readable lets NixOS and the standalone
gpu01 Home Manager configuration build `authorized_keys` without decrypting a
private key. SOPS still remains the single source for each key pair.

## Codex authentication

`users/seeker/codex-auth.secrets.json` contains the complete Codex
`auth.json`. Home Manager deploys it through sops-nix with mode `0600` on
`miLaptop`, `DiagonAlley`, `devVM`, `nixos-wsl`, `gpu01`, `mi15`, and `miPad`.
The keyless development container deliberately does not import this secret
module.

## Taskwarrior synchronization

`users/seeker/taskwarrior.secrets.yaml` contains the shared TaskChampion
client ID and client-side encryption secret. Home Manager renders them into a
mode `0400` Taskwarrior configuration fragment on `miLaptop` and
`DiagonAlley`. King'sCross reads only the client ID to restrict the sync
server; the encryption secret is not passed to the server process.

`miLaptop` is the primary replica for recurring tasks. `DiagonAlley` disables
recurrence generation to avoid duplicate recurring tasks while retaining full
sync and task editing support.

## Bootstrap

Install the admin identity at
`/persist/home/seeker/.config/sops/age/keys.txt` on `miLaptop` and at
`~/.config/sops/age/keys.txt` on `nixos-wsl`. The miLaptop persistence mount
also exposes its identity at the standard XDG path after boot. Install
`.secrets/age/devVM.txt` at `~/.config/sops/age/keys.txt` inside devVM before
activating a configuration that consumes secrets. Install
`.secrets/age/gpu01.txt` at the same path on gpu01. Keep
`.secrets/age/recovery.txt` offline after confirming that it decrypts the
repository.

Install the dedicated DiagonAlley identity from
`.secrets/age/DiagonAlley.txt` out of band at
`/persist/home/seeker/.config/sops/age/keys.txt` before its first activation.

For nix-on-droid, install `.secrets/age/mi15.txt` at
`~/.config/sops/age/keys.txt` on MI15 and `.secrets/age/miPad.txt` at the same
path on MiPad before the first `nix-on-droid switch`. The flake outputs are
`nixOnDroidConfigurations.mi15` and `nixOnDroidConfigurations.miPad`, so the
device commands are:

```bash
nix-on-droid switch --flake path:/path/to/nixos-config#mi15
nix-on-droid switch --flake path:/path/to/nixos-config#miPad
```

The nix-on-droid environment is configured with the `seeker` username; the
underlying Android app UID remains managed by Android. It does not provide a
system OpenSSH daemon, so these configurations manage outbound SSH client
access only.

Before the first activation on an existing `miLaptop`, copy the old
`/persist/home/seeker/age/keys` identity to
`/persist/home/seeker/.config/sops/age/keys.txt`, owned by `seeker` with mode
`0600`. The system reads this backing path before regular local filesystems and
user persistence mounts are available during activation.

See `docs/devvm-maintenance.md` for the devVM bootstrap, update, verification,
and rollback workflow.

Register the value of `public_key_unencrypted` from
`users/seeker/ssh/github.secrets.json` as the one GitHub authentication key.
Register the value from `users/seeker/ssh/external.secrets.json` on external
machines; the external key is intentionally separate from the GitHub key.
The gpu01 Home Manager activation takes ownership of `~/.ssh/authorized_keys`
and atomically installs a user-owned regular file containing the administrator
key plus the three development client keys. It deliberately does not use a Nix
store symlink because the cluster's shared store ownership fails OpenSSH
`StrictModes`. Confirm that no separately managed cluster key must be retained
before the first activation.

After changing recipients in `.sops.yaml`, update an existing document with:

```bash
sops updatekeys -y path/to/file.secrets.yaml
```
