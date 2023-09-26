#!/bin/bash

# Generate list of git repositories on local machine
exluded_paths=("$HOME/Library" "$HOME/Documents")
IFS=$'\n' read -r -d '' -a local_git_file_paths < <( find $HOME -type d -name ".git" && printf '\0' ) 

# Iterate over the list
for git_file_path in "${local_git_file_paths[@]}";
    do
        directory_path=$(awk '{ sub(/\/.git.*/, ""); print }' <<< "$git_file_path")
        git_directory=""

        # Fix directory_path if it contains spaces
        if [[ $directory_path == *" "* ]]; then
            git_directory=$(printf %q "$directory_path")
        else
            git_directory="$directory_path"
        fi
        # Change directory to current directory
        eval cd "$git_directory"

        # Check what the current branch is
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        # Find the origin/HEAD branch name 
        remote_branches=$(command git branch -r)
        master_branch=$(echo "$remote_branches" | sed -n 's/.*-> origin\/\([^[:space:]]*\).*/\1/p')

        # Compare the current branch & origin/HEAD branch
        if [[ "$current_branch" == "$master_branch" ]];
        then
            # if they match, run a git pull
            echo -e "$git_directory is currently checked out to the origin head branch $current_branch"
            git pull; 
        else
            # if they don't match, checkout to origin/HEAD branch and run a git pull, then check back out to feature branch
            echo -e "Expected current_branch in $git_directory to be $master_branch but instead is $current_branch."
            git checkout $master_branch
            git pull
            git checkout $current_branch
        fi
done



# TO TEST:
# #!/bin/bash

# # Define the starting directory for the search
# start_directory="$HOME"

# # Function to check if a directory is accessible
# is_accessible() {
#   local dir="$1"
#   [ -d "$dir" ] && [ -r "$dir" ]
# }

# # Initialize an empty array
# local_git_file_paths=()

# # Iterate over directories and check for accessibility
# while IFS= read -r -d '' dir; do
#   if is_accessible "$dir"; then
#     local_git_file_paths+=("$dir")
#   else
#     echo "Permission denied or not a directory: $dir"
#   fi
# done < <(find "$start_directory" -type d -name ".git" -print0)

# # Now, you have the accessible directories in the local_git_file_paths array
# # You can use it as needed
# for path in "${local_git_file_paths[@]}"; do
#   echo "Accessible directory: $path"
# done
