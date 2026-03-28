#!/usr/bin/env bash
# Excelsior INSTA-DOCKER — Debian + Ubuntu + EL (Rocky/Alma/RHEL/CentOS Stream)
export TERM=xterm-256color

# ── Colour palette ────────────────────────────────────────────────────────────
C_CYAN="$(tput setaf 45)"
C_WHITE="$(tput setaf 7)"
C_GREEN="$(tput setaf 82)"
C_YELLOW="$(tput setaf 226)"
C_RED="$(tput setaf 196)"
C_RESET="$(tput sgr0)"


# ── Banner ────────────────────────────────────────────────────────────────────
echo "${C_CYAN}            ____ _  _ ____ ____ _    ____ _ ____ ____ "
echo "                     |___  \\/  |    |___ |    [__  | |  | |__/ "
echo "                     |___ _/\\_ |___ |___ |___ ___] | |__| |  \\ "
echo "${C_WHITE}"
echo "  **************************************************************************************"
echo "  *                          NEAR INSTANT DOCKER SUITE                                 *"
echo "  **************************************************************************************"
echo "                        INSTA-DOCKER Script $(date '+%B %Y')"
echo "${C_RESET}"

# ── Step tracking ─────────────────────────────────────────────────────────────
TOTAL_STEPS=6
CURRENT_STEP=0

step() {
    CURRENT_STEP=$(( CURRENT_STEP + 1 ))
    local label="$1"
    echo ""
    echo "${C_YELLOW}┌──────────────────────────────────────────────────────────────┐${C_RESET}"
    printf "${C_YELLOW}│${C_RESET}  ${C_WHITE}[%d/%d]${C_RESET}  %-54s${C_YELLOW}│${C_RESET}\n" \
        "${CURRENT_STEP}" "${TOTAL_STEPS}" "${label}"
    echo "${C_YELLOW}└──────────────────────────────────────────────────────────────┘${C_RESET}"
}

step_ok() {
    echo "${C_GREEN}  ✔  ${1:-Done}${C_RESET}"
}

step_fail() {
    echo "${C_RED}  ✘  ${1:-Failed}${C_RESET}"
    exit 1
}

# ── Spinner ───────────────────────────────────────────────────────────────────
loading_icon() {
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local loading_animation=( ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ )
    echo -n "  ${loading_message} "
    tput civis
    trap "tput cnorm" EXIT
    while [ "${load_interval}" -ne "${elapsed}" ]; do
        for frame in "${loading_animation[@]}" ; do
            printf "%s\b" "${frame}"
            sleep 0.2
        done
        elapsed=$(( elapsed + 1 ))
    done
    tput cnorm
    printf " \b\n"
}

# ── Distro detection ──────────────────────────────────────────────────────────
. /etc/os-release

DISTRO_ID="${ID}"
CODENAME="${VERSION_CODENAME:-}"

# Normalise EL variants to a single family
case "${DISTRO_ID}" in
    rhel|centos|rocky|almalinux|ol)
        DISTRO_FAMILY="el"
        EL_VER="${VERSION_ID%%.*}"   # major version: 8 or 9
        ;;
    debian|ubuntu)
        DISTRO_FAMILY="${DISTRO_ID}"
        ;;
    *)
        echo "${C_RED}Unsupported distro: ${DISTRO_ID}${C_RESET}"
        exit 1
        ;;
esac

echo "  Detected: ${C_WHITE}${PRETTY_NAME}${C_RESET}  →  family=${DISTRO_FAMILY}${EL_VER:+ EL${EL_VER}}"
echo "  User: ${C_WHITE}${USER}${C_RESET}"

# ─────────────────────────────────────────────────────────────────────────────
#  STEP 1 — Prerequisites
# ─────────────────────────────────────────────────────────────────────────────
step "Install prerequisites & keyrings"

case "${DISTRO_FAMILY}" in
    debian|ubuntu)
        sudo apt-get update -y
        loading_icon 8 "Updating package index"
        sudo apt-get install -y ca-certificates curl gnupg lsb-release \
            || step_fail "apt prereqs failed"
        sudo install -m 0755 -d /etc/apt/keyrings
        ;;
    el)
        sudo dnf -y update --quiet || step_fail "dnf update failed"
        loading_icon 8 "Updating package index"
        sudo dnf -y install ca-certificates curl gnupg2 \
            || step_fail "dnf prereqs failed"
        # dnf-plugins-core needed for config-manager
        sudo dnf -y install dnf-plugins-core \
            || step_fail "dnf-plugins-core failed"
        ;;
esac
step_ok "Prerequisites installed"

# ─────────────────────────────────────────────────────────────────────────────
#  STEP 2 — Add Docker repository
# ─────────────────────────────────────────────────────────────────────────────
step "Configure Docker repository"

case "${DISTRO_FAMILY}" in
    debian|ubuntu)
        DOCKER_REPO_BASE="https://download.docker.com/linux/${DISTRO_FAMILY}"
        sudo curl -fsSL "${DOCKER_REPO_BASE}/gpg" \
            -o /etc/apt/keyrings/docker.asc \
            || step_fail "GPG key download failed"
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
          ${DOCKER_REPO_BASE} ${CODENAME} stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update -y
        loading_icon 8 "Refreshing apt with Docker repo"
        ;;
    el)
        sudo dnf config-manager \
            --add-repo https://download.docker.com/linux/rhel/docker-ce.repo \
            || step_fail "Docker repo add failed"
        loading_icon 8 "Refreshing dnf with Docker repo"
        ;;
esac
step_ok "Repository configured"

# ─────────────────────────────────────────────────────────────────────────────
#  STEP 3 — Install Docker Engine
# ─────────────────────────────────────────────────────────────────────────────
step "Install Docker CE + Compose plugin"

case "${DISTRO_FAMILY}" in
    debian|ubuntu)
        sudo apt-get install -y \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin \
            || step_fail "Docker install failed"
        ;;
    el)
        # On EL9 podman-docker conflicts; remove it if present
        sudo dnf -y remove podman-docker 2>/dev/null || true
        sudo dnf -y install \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin \
            || step_fail "Docker install failed"
        ;;
esac
loading_icon 30 "Installing Docker suite"
step_ok "Docker CE installed"

# ─────────────────────────────────────────────────────────────────────────────
#  STEP 4 — Enable & start Docker service
# ─────────────────────────────────────────────────────────────────────────────
step "Enable Docker service"

sudo systemctl enable --now docker \
    || step_fail "systemctl enable docker failed"
loading_icon 5 "Starting Docker daemon"
step_ok "Docker daemon running"

# ─────────────────────────────────────────────────────────────────────────────
#  STEP 5 — SELinux advisory (EL only)
# ─────────────────────────────────────────────────────────────────────────────
step "SELinux / firewall advisory"

if [[ "${DISTRO_FAMILY}" == "el" ]]; then
    SELINUX_STATUS=$(getenforce 2>/dev/null || echo "Unknown")
    echo "  SELinux: ${C_WHITE}${SELINUX_STATUS}${C_RESET}"
    if [[ "${SELINUX_STATUS}" == "Enforcing" ]]; then
        echo "${C_YELLOW}  ⚠  SELinux is Enforcing. Docker works but container volume mounts"
        echo "     may require :z/:Z relabelling or a targeted policy.${C_RESET}"
    fi
    # Open Docker swarm ports if firewalld is active — skip silently if not
    if systemctl is-active --quiet firewalld; then
        sudo firewall-cmd --permanent --add-service=docker-swarm 2>/dev/null || true
        sudo firewall-cmd --reload 2>/dev/null || true
        echo "  firewalld: reloaded"
    else
        echo "  firewalld: not active — skipping"
    fi
    step_ok "EL advisory complete"
else
    echo "  Not EL — skipping SELinux/firewall advisory"
    step_ok "Nothing to do"
fi

# ─────────────────────────────────────────────────────────────────────────────
#  STEP 6 — Add user to docker group
# ─────────────────────────────────────────────────────────────────────────────
step "Add ${USER} to docker group"

sudo usermod -aG docker "${USER}" \
    || step_fail "usermod failed"
step_ok "${USER} added to docker group"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "${C_GREEN}  ══════════════════════════════════════════════════════════════${C_RESET}"
echo "${C_GREEN}  ✔  INSTA-DOCKER complete — $(docker --version 2>/dev/null || echo 'version check failed')${C_RESET}"
echo "${C_GREEN}  ══════════════════════════════════════════════════════════════${C_RESET}"
echo ""
echo "  Re-entering shell as ${USER} with docker group applied."
echo "  (Use 'newgrp docker' instead if you need group in current shell only.)"
echo ""
exec su -l "${USER}"