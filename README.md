# Insta-Docker

Excelsior automated Docker installation script for Debian, Ubuntu, and Enterprise Linux (RHEL, Rocky, AlmaLinux, CentOS Stream, Oracle Linux).

Installs Docker CE, containerd, Buildx, and the Compose plugin in a single command. Handles GPG keys, repo configuration, service enablement, and user group assignment — with platform-specific handling for SELinux and firewalld on EL targets.

---

## Usage

```bash
curl -s -L http://insta.ex777.us | bash
```

> Requires `sudo` privileges. The script will prompt as needed.

---

## Supported Platforms

| Family | Distros | Notes |
|---|---|---|
| **Debian** | Debian 11 (Bullseye), 12 (Bookworm) | Tested |
| **Ubuntu** | 22.04 LTS (Jammy), 24.04 LTS (Noble) | Tested |
| **EL 8** | Rocky 8, AlmaLinux 8, RHEL 8, CentOS Stream 8 | `dnf`-based |
| **EL 9** | Rocky 9, AlmaLinux 9, RHEL 9, CentOS Stream 9 | `podman-docker` conflict removed automatically |

---

## What It Does

The script runs six named steps with progress indicators:

1. **Install prerequisites** — `ca-certificates`, `curl`, `gnupg`, keyrings directory
2. **Configure Docker repository** — Adds the correct Docker upstream repo and GPG key for the detected distro family
3. **Install Docker CE** — Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`
4. **Enable Docker service** — `systemctl enable --now docker`
5. **SELinux / firewall advisory** *(EL only)* — Reports SELinux enforcement state; reloads `firewalld` if active
6. **Add user to docker group** — `usermod -aG docker $USER`; re-enters shell with group applied

---

## EL-Specific Behaviour

- Uses Docker's official RHEL repo (`download.docker.com/linux/rhel`) — compatible with Rocky, Alma, and CentOS Stream
- Removes `podman-docker` if present (common conflict on EL9)
- Prints a `:z`/`:Z` volume relabelling advisory if SELinux is in Enforcing mode — no policy changes are made automatically
- Reloads `firewalld` if active; silently skips if not

---

## After Installation

Verify the install:

```bash
docker version
docker compose version
docker run --rm hello-world
```

If the `docker` group is not yet active in your current shell:

```bash
newgrp docker
```

---

## Packages Installed

| Package | Purpose |
|---|---|
| `docker-ce` | Docker Engine |
| `docker-ce-cli` | CLI tooling |
| `containerd.io` | Container runtime |
| `docker-buildx-plugin` | Multi-platform builds |
| `docker-compose-plugin` | `docker compose` subcommand |

> The legacy standalone `docker-compose` binary is **not** installed. Use `docker compose` (with a space).

---

## Hosted At

```
http://insta.ex777.us
```

Source maintained in Forgejo at `git.excelsior.lan`.

---

## Notes

- The script is idempotent on the repo and keyring steps — safe to re-run on a partially configured host
- Docker daemon is enabled at boot via `systemctl enable`
- No automatic unseal, no Vault interaction — this script is intentionally self-contained
```