#!/usr/bin/env bash
# Excelsior INSTA-DOCKER Script — updated for Debian
export TERM=xterm-256color

echo "$(tput setaf 45)                     ____ _  _ ____ ____ _    ____ _ ____ ____ "
echo "$(tput setaf 45)                     |___  \/  |    |___ |    [__  | |  | |__/ "
echo "$(tput setaf 45)                     |___ _/\_ |___ |___ |___ ___] | |__| |  \ "
echo "$(tput setaf 7)"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)  *                          NEAR INSTANT DOCKER SUITE                                 *"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)                        Debian INSTA-DOCKER Script $(date +%B\ %Y)                     "
echo ""

loading_icon() {
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local loading_animation=( ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ )
    echo -n "${loading_message} "
    tput civis
    trap "tput cnorm" EXIT
    while [ "${load_interval}" -ne "${elapsed}" ]; do
        for frame in "${loading_animation[@]}" ; do
            printf "%s\b" "${frame}"
            sleep 0.2
        done
        elapsed=$(( elapsed + 1 ))
    done
    printf " \b\n"
}

echo "Hey $USER, let's get started. Update, install prereqs, and keyrings"
sudo apt-get update -y
loading_icon 10 "Updating package lists"

sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

# Debian-specific GPG key and repo (not Ubuntu)
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Add the Docker repository to Apt sources:"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
loading_icon 10 "Refreshing with Docker repo"

echo "Installing Docker CE and Compose..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-compose

loading_icon 60 "Installing Docker suite"

sudo usermod -aG docker "$USER"
echo "Done. Re-entering shell as $USER with docker group applied."
exec su -l "$USER"