#!/bin/bash

# Default values
default_keysize=2048
default_keytype="ed25519"
default_filepath="$HOME/.ssh/"
default_host="host"

# Valid key types
valid_keytypes=("rsa" "dsa" "ecdsa" "ed25519")

# Detect the operating system
os=$(uname -s)

# Prompting for user inputs
read -rp "Enter key size [2048]: " keysize
keysize=${keysize:-$default_keysize}
if ! [[ "$keysize" =~ ^[0-9]+$ ]] || [ "$keysize" -le 0 ]; then
	echo "Key size must be a positive integer."
	exit 1
fi

read -rp "Enter key type [ed25519]: " keytype
keytype=${keytype:-$default_keytype}
if [[ ! " ${valid_keytypes[*]} " =~ $keytype ]]; then
	echo "Invalid key type. Valid key types are: ${valid_keytypes[*]}"
	exit 1
fi

read -rp "Enter file path [$HOME/.ssh/]: " filepath
filepath=${filepath:-$default_filepath}

read -rp "Enter the service or server name (e.g., 'github', 'ec2'): " service_name

# Create a default file name using keytype and service_name
default_filename="id_${keytype}_${service_name}"

# Prompt for file name with default value
read -rp "Enter file name [${default_filename}]: " filename

filename=${filename:-$default_filename}

read -rsp "Enter passphrase: " passphrase
echo

read -rp "Enter host [host]: " host
host=${host:-$default_host}

# Create the .ssh directory if it doesn't exist
mkdir -p "$filepath"

# Check if key already exists
if [ -f "${filepath}${filename}" ]; then
	read -rp "Key already exists! Overwrite? (y/n): " overwrite
	if [[ $overwrite =~ ^[Yy]$ ]]; then
		rm -f "${filepath}${filename}"
	else
		echo "Operation cancelled by user."
		exit 1
	fi
fi

# Generate the SSH key
if ! ssh-keygen -t "$keytype" -b "$keysize" -N "$passphrase" -f "${filepath}${filename}"; then
	echo "SSH keygen failed"
	exit 1
fi

# Ask if user wants to add key to ssh-agent
read -rp "Add key to ssh-agent? (y/n): " add_to_agent
if [[ $add_to_agent =~ ^[Yy]$ ]]; then
	# Adding the ssh key to the ssh-agent
	if pgrep -x "ssh-agent" >/dev/null; then
		if ! ssh-add "${filepath}${filename}"; then
			echo "ssh-add failed"
			exit 1
		fi
	else
		if ! eval "$(ssh-agent -s)" || ! ssh-add "${filepath}${filename}"; then
			echo "ssh-add failed"
			exit 1
		fi
	fi
fi

# Copying the public key to the clipboard for user convenience
if [[ "$os" == "Darwin" ]]; then # MacOS
	if ! which pbcopy >/dev/null || ! pbcopy <"${filepath}${filename}.pub"; then
		echo "pbcopy not found. Skipping clipboard copy."
	fi
elif [[ "$os" == "Linux" ]]; then # Linux
	if ! which xclip >/dev/null || ! xclip -sel clip <"${filepath}${filename}.pub"; then
		echo "xclip not found. Skipping clipboard copy."
	fi
elif [[ "$os" == "MINGW"* ]]; then # Windows
	if ! which clip >/dev/null || ! clip <"${filepath}${filename}.pub"; then
		echo "clip not found. Skipping clipboard copy."
	fi
fi

echo "If available, your public key is now in the clipboard. You can paste it into the SSH key field of your target host."

# Adding the key to known hosts
if ping -c 1 "$host" &>/dev/null; then
	if ! ssh-keyscan -H "$host" >>~/.ssh/known_hosts; then
		echo "ssh-keyscan failed"
		exit 1
	fi
else
	echo "Host not reachable. Skipping ssh-keyscan."
fi

echo "SSH Key setup has been completed."
