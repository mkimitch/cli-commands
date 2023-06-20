#!/bin/bash

function check_branch_exists {
    local branch="$1"
    git show-ref --verify --quiet "refs/heads/$branch"
    local branch_exists=$?
    if [ $branch_exists -ne 0 ]; then
        echo "Error: The branch ($branch) does not exist."
        exit 1
    fi
}

function update_branch {
    local branch="$1"
    git checkout "$branch"
    if [ $? -ne 0 ]; then
        echo "Error: Unable to checkout branch ($branch)."
        exit 1
    fi

    git pull origin "$branch"
    if [ $? -ne 0 ]; then
        echo "Error: Unable to fetch and merge changes from the remote repository into branch ($branch)."
        exit 1
    fi
}

function git_merge_branches {
    # Check if the required number of arguments is provided
    if [ "$#" -lt 1 ]; then
        echo "Usage: git_merge_branches <source_branch> [target_branch]"
        exit 1
    fi

    # Store branch names
    local source_branch="$1"
    local target_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

    # Check if both branches exist
    check_branch_exists "$source_branch" || exit 1
    check_branch_exists "$target_branch" || exit 1

    # Update source branch
    update_branch "$source_branch" || exit 1

    # Checkout and update target branch
    update_branch "$target_branch" || exit 1

    # Perform merge
    git merge "$source_branch"
    local merge_status=$?

    if [ $merge_status -eq 0 ]; then
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
}

# Call the function with command line arguments
git_merge_branches "$1" "$2"
