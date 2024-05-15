#!/bin/bash

# This script checks for differences in your Git repository and formats the output
# for easy copying, particularly useful for code review or sharing diffs.

# Usage:
# 1. To check the difference in the entire repository:
#    ./script_name.sh
# 2. To check the difference in specific files:
#    ./script_name.sh file1 file2 ...

# How to use with Git Commit Composer:
# 1. Run this script to get the formatted diff output.
# 2. Copy the formatted diff.
# 3. Use the copied diff as input to Git Commit Composer to help generate meaningful
#    commit messages based on the actual changes in your code.
# 4. Paste the diff into Git Commit Composer at https://chatgpt.com/g/g-X1aQtWMVw-git-commit-composer
#    to get suggested commit messages.

# Check if any arguments are passed, indicating specific files for git diff
if [ "$#" -gt 0 ]; then
	# If arguments are passed, use them for git diff
	DIFF_OUTPUT=$(git diff -w "$@")
else
	# Otherwise, just do a general git diff -w
	DIFF_OUTPUT=$(git diff -w)
fi

# Check if DIFF_OUTPUT is empty
if [ -z "$DIFF_OUTPUT" ]; then
	echo "No differences found."
else
	# Format and output the diff for easy copying
	echo "\`\`\`diff"
	echo "$DIFF_OUTPUT"
	echo "\`\`\`"
fi
