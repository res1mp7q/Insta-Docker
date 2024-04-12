#!/bin/sh
stty -echo

# Excelsior INSTA-DOCKER Script January 2024

export TERM=xterm-256color
echo "$(tput setaf 45)                     ____ _  _ ____ ____ _    ____ _ ____ ____ "
echo "$(tput setaf 45)                     |___  \/  |    |___ |    [__  | |  | |__/ "
echo "$(tput setaf 45)                     |___ _/\_ |___ |___ |___ ___] | |__| |  \ "
echo "$(tput setaf 7)"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)  *                Debian Image INSTA-CONFIGURATOR Script APRIL 2024                   *"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)                                      "
echo ""

echo "Okay. we are going to:"
echo "Create a new user,"
echo "set password, "
echo "add an SSH key, "
echo "and configure permissions..."
echo "THEN"
echo "Install docker and compose particulars"

# ** User **

# Function to create a new user, set password, add SSH key, and configure permissions
create_user() {
    # Turn off terminal echo
    stty -echo

    # Take username as input
    read -p "Enter username: " username

    # Turn on terminal echo
    stty echo
    echo

    # Create user with password
    sudo adduser $username

    # Prompt for password and set it
    sudo passwd $username

    # Turn off terminal echo
    stty -echo

    # Take SSH public key as input
    read -p "Enter SSH public key: " ssh_key

    # Turn on terminal echo
    stty echo
    echo

    # Create SSH directory if it doesn't exist
    sudo mkdir -p /home/$username/.ssh

    # Set permissions for ~/.ssh directory and authorized_keys file
    sudo chmod 655 /home/$username/.ssh
    sudo touch /home/$username/.ssh/authorized_keys
    sudo chmod 600 /home/$username/.ssh/authorized_keys

    # Add SSH key to authorized_keys file
    echo "$ssh_key" | sudo tee -a /home/$username/.ssh/authorized_keys > /dev/null

    # Set the new user as a sudoer
    sudo usermod -aG sudo $username

    echo "User '$username' created successfully."
}

# Main script
echo "Creating a new user, setting password, adding SSH key, and configuring permissions..."
create_user


# ****Docker****

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

# **God save the King**

# Function to clear the screen
clear_screen() {
    tput clear
}

# Function to draw the Union Jack flag with colors
draw_flag() {
    tput setaf 7  # Set color to white (W)
    cat << "EOF"
                     _              

    W=====================
      | \:::|  |::://|
      |\ \::|  |::// |
      |\\ \:|  |:// /|
      |:\\ \|  |// /:|
      |::\\_|  |/_/::|
      |              |
EOF
    tput setaf 4  # Set color to blue (B)
    cat << "EOF"
      |_____.  ._____|
EOF
    tput setaf 1  # Set color to red (R)
    cat << "EOF"
      |::/ /|  | \\::|
      |:/ //|  |\ \\:|
      |/ //:|  |:\ \\|
      | //::|  |::\ \|
      |//:::|__|:::\_|
EOF
    tput setaf 3  # Set color to gold
    echo "      God save the King"
    tput sgr0     # Reset color
}

# Function to animate the flag
animate_flag() {
    local delay=0.1

    for ((i = 0; i < 10; i++)); do
        clear_screen
        draw_flag

        # Move the bottom lines down slightly
        for ((j = 0; j < i; j++)); do
            echo
        done

        # Move the top lines up slightly
        for ((j = 0; j < 10 - i; j++)); do
            tput cuu1
        done

        sleep $delay
    done
}

# Main script
animate_flag