#!/bin/bash

# Prompt user to create a new token
echo "Please go to the following URL to create a new Personal Access Token: {url_here}"
echo "After you've created the token, please paste it here."

# Read the new token
read -rp 'Token: ' new_token
echo

# Identify the shell configuration file and command to source it
if [[ $MSYSTEM == *"MINGW"* ]]; then
	if [[ -f "${HOME}/.bashrc" ]]; then
		shell_rc="${HOME}/.bashrc"
		source_cmd=". ${HOME}/.bashrc"
	elif [[ -f "${HOME}/.bash_profile" ]]; then
		shell_rc="${HOME}/.bash_profile"
		source_cmd=". ${HOME}/.bash_profile"
	elif [[ -f "${HOME}/.profile" ]]; then
		shell_rc="${HOME}/.profile"
		source_cmd=". ${HOME}/.profile"
	else
		echo "Couldn't find a shell profile to update."
		exit 1
	fi
else
	if [[ $SHELL == *"zsh"* ]]; then
		shell_rc="${HOME}/.zshrc"
		source_cmd="source ${HOME}/.zshrc"
	elif [[ $SHELL == *"bash"* ]]; then
		shell_rc="${HOME}/.bashrc"
		source_cmd=". ${HOME}/.bashrc"
	else
		echo "Unsupported shell."
		exit 1
	fi
fi

# Check if NPM_TOKEN is already set, and if so, replace it. If not, add it.
if grep -q 'export NPM_TOKEN=' "${shell_rc}"; then
	# The token already exists, so replace it
	sed -i.bak "s/export NPM_TOKEN=.*/export NPM_TOKEN=${new_token}/" "${shell_rc}"
else
	# The token doesn't exist, so add it.
	echo "export NPM_TOKEN=${new_token}" >>"${shell_rc}"
fi

# Source the shell rc file
eval "${source_cmd}"

echo "Token update complete. The new token has been sourced to the current shell."
echo "shell_rc: ${shell_rc}"
echo "source_cmd: ${source_cmd}"
