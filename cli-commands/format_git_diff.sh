#!/bin/bash

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
