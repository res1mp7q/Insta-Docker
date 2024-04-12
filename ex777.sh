#!/bin/sh
stty -echo

# Excelsior INSTA-DOCKER Script January 2024

export TERM=xterm-256color
echo "$(tput setaf 45)                     ____ _  _ ____ ____ _    ____ _ ____ ____ "
echo "$(tput setaf 45)                     |___  \/  |    |___ |    [__  | |  | |__/ "
echo "$(tput setaf 45)                     |___ _/\_ |___ |___ |___ ___] | |__| |  \ "
echo "$(tput setaf 7)"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)  *                                POT NOODLE RULZ                                     *"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)                        Debian Image INSTA-CONFIGURATOR Script APRIL 2024               "
echo ""

#configure sudo user and get new password and ssh key

read -p 'Enter the user/service account: ' user1
stty -echo
printf "Password: "
read user1password
stty echo
printf "\n"

printf user1

while true; do
    read -p "Is everything correct?" yesno
    case $yesno in
        [Yy]* ) 
            echo "You chose wisely"
        ;;
        [Nn]* ) 
            echo "Try again then"
            exit
        ;;
        * ) echo "Make up yo mind!";;
    esac
done


# Add Docker's official GPG key:
echo "Hey $USER, let's get started. Update, install prereqs, and keyrings"


sudo apt-get update
function loading_icon() {
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local loading_animation=( ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ )

    echo -n "${loading_message} "

    # This part is to make the cursor not blink
    # on top of the animation while it lasts
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

loading_icon 60 "Updating"


sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Add the repository to Apt sources:"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get update
function loading_icon() {
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local loading_animation=( ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ )

    echo -n "${loading_message} "

    # This part is to make the cursor not blink
    # on top of the animation while it lasts
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

loading_icon 60 "And finally, install docker-ce and compose"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

