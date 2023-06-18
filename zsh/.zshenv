# Does a git pull for every subdir in a directory.
# Handy for making sure a bunch of repos are up-to-date with one command.
git-pull-dirs() {
    # Get all directories. This is not recursive, so we only go one level deep.
    for d in */ ; do
        # Change to the current dir.
        cd "$d"
        echo ""
        echo "checking $d..."
        # If there's a .git directory in here, this is a repo, so...
        if [[ -d ".git" ]]; then
            # ...switch to main if we're not already using it...
            if [[ $(git branch --show-current) != $(git_main_branch) ]]; then
                git switch $(git_main_branch)
            fi
            # ...then pull everything.
            git pull --all
        else
            echo "$d is not a git repo"
        fi
        # CD up one level so we can do it again for the next dir.
        cd ..
    done
}
