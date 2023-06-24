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

# Completely removes all containers, images, and builder cache files.
docker-purge() {
    docker container prune -f
    docker image prune -f -a
    docker builder prune -f
}

# Gets a list of tags from Docker Hub
dockerhub-tags() {
    if ! [[ "$#" -eq 2 || "$#" -eq 3 ]]; then
        printf "ERROR: missing required args\n\n"
        printf "usage: dockerhub-tags repo_name image_name <filter>\n\n"
        printf "   repo_name    required   ex. 'apache' (use 'library' for images w/no prefix)\n"
        printf "   image_name   required   ex. 'airflow'\n"
        printf "   filter       optional   ex. 'python-3'\n"
        return 1
    fi

    # Get count of results
    local count size pages remainder url
    size=100
    count=$(curl -s "https://hub.docker.com/v2/namespaces/${1}/repositories/${2}/tags?page_size=${size}" | jq -r '.count')
    pages=$(expr $count / $size)
    remainder=$(expr $count % $size)
    if [[ $remainder > 0 ]]; then
        pages=$(expr $pages + 1)
    fi

    echo "Fetching ${size} items per page for ${pages} pages..."
    for page in {1..$pages}
    do
        url="https://hub.docker.com/v2/namespaces/${1}/repositories/${2}/tags?page=${page}"
        if [[ -z "$3" ]]; then
            curl -s "${url}" | jq -r '.results[].name'
        else
            curl -s "${url}" | jq -r '.results[].name' | grep -i "${3}"
        fi
    done
}
