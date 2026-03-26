#!/usr/bin/env bash

while read -r d; do
  git_dir=$(dirname "$d")
  echo -e "\n# ${git_dir}"
  cd "${git_dir}"
  rm .pre-commit-config.yaml
  ln -s ~/github.com/devopscoop/dotfiles/3uzbcqje/.pre-commit-config.yaml
  grep -q .pre-commit-config.yaml .gitignore || echo '.pre-commit-config.yaml' >> .gitignore
  # git add -A
  # git status
  # git commit -m ...
  # git pull-all-main
  # git push-all-branches
  pre-commit install
done < <(find ~/codeberg.org/ ~/gitlab.com/ ~/github.com/ ~/git/ ~/aur.archlinux.org/ -type d -name ".terraform" -prune -o -type d -name ".git" -print)
