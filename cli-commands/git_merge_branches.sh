#!/bin/bash

# Check if the required number of arguments is provided
if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <source_branch> <target_branch>"
	exit 1
fi

# Store branch names
source_branch="$1"
target_branch="$2"

# Check if both branches exist
git show-ref --verify --quiet "refs/heads/$source_branch"
source_exists=$?

git show-ref --verify --quiet "refs/heads/$target_branch"
target_exists=$?

if [ $source_exists -ne 0 ] || [ $target_exists -ne 0 ]; then
	echo "Error: Either the source branch ($source_branch) or the target branch ($target_branch) does not exist."
	exit 1
fi

# Checkout target branch
git checkout "$target_branch"
if [ $? -ne 0 ]; then
	echo "Error: Unable to checkout target branch ($target_branch)."
	exit 1
fi

# Update branches
git fetch
if [ $? -ne 0 ]; then
	echo "Error: Unable to fetch changes."
	exit 1
fi

# Perform merge
git merge "$source_branch"
merge_status=$?

if [ $merge_status -eq 0 ]; then
	echo "Merge of $source_branch into $target_branch completed successfully."

	# Push the merged changes to the remote repository
	git push origin "$target_branch"
	if [ $? -ne 0 ]; then
		echo "Error: Unable to push the merged changes to the remote repository."
		exit 1
	fi

	echo "Merge of $source_branch into $target_branch completed successfully, and changes were pushed to the remote repository."

	exit 0
elif [ $merge_status -eq 1 ]; then
	echo "Merge conflict detected! Please resolve conflicts and then commit the result."
	exit 1
else
	echo "Error: Unable to merge branches."
	exit 1
fi
