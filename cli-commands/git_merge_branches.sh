#!/bin/bash

set -e

# Colors for better visibility
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if a branch exists in the repository
function check_branch_exists {
	local branch="$1"
	if ! git show-ref --verify --quiet "refs/heads/$branch"; then
		echo -e "${RED}Error: The branch ($branch) does not exist.${NC}"
		exit 1
	fi
}

# Update the specified branch with the latest changes from the remote repository
function update_branch {
	local branch="$1"
	echo -e "${GREEN}Checking out branch: $branch${NC}"
	if ! git checkout "$branch"; then
		echo -e "${RED}Error: Unable to checkout branch ($branch).${NC}"
		exit 1
	fi

	echo -e "${GREEN}Pulling latest changes for branch: $branch${NC}"
	if ! git pull origin "$branch"; then
		echo -e "${RED}Error: Unable to fetch and merge changes from the remote repository into branch ($branch).${NC}"
		exit 1
	fi
}

# Merge source branch into target branch
function git_merge_branches {
	echo -e "${GREEN}Starting git_merge_branches function${NC}"

	# Check if the required number of arguments is provided
	if [ "$#" -lt 1 ]; then
		echo -e "${RED}Usage: git_merge_branches <source_branch> [target_branch]${NC}"
		exit 1
	fi

	# Store branch names
	local source_branch="$1"
	local target_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
	echo -e "${GREEN}Source branch: $source_branch${NC}"
	echo -e "${GREEN}Target branch: $target_branch${NC}"

	# Check if both branches exist
	echo -e "${GREEN}Checking if both branches exist${NC}"
	check_branch_exists "$source_branch"
	check_branch_exists "$target_branch"

	# Update source branch
	echo -e "${GREEN}Updating source branch: $source_branch${NC}"
	update_branch "$source_branch"

	# Checkout and update target branch
	echo -e "${GREEN}Updating target branch: $target_branch${NC}"
	update_branch "$target_branch"

	# Perform merge
	echo -e "${GREEN}Merging $source_branch into $target_branch${NC}"
	if git merge --no-edit "$source_branch"; then
		if git diff --quiet; then
			echo -e "${GREEN}Branches are already up-to-date. No merge necessary.${NC}"
		else
			echo -e "${GREEN}Merge successful. Pushing to remote repository.${NC}"
			if ! git push origin "$target_branch"; then
				echo -e "${RED}Error: Unable to push the merged changes to the remote repository.${NC}"
				exit 1
			fi
			echo -e "${GREEN}Merge of $source_branch into $target_branch completed successfully, and changes were pushed to the remote repository.${NC}"
		fi
	else
		echo -e "${RED}Merge conflict detected! Please resolve conflicts and then commit the result.${NC}"
		exit 1
	fi

	# Pause the script before exiting
	read -r -p "Press any key to continue..."
}

# Execute the function with provided arguments
git_merge_branches "$@"
