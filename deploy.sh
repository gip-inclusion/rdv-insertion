#!/bin/bash

# Script for merging any changes in `staging` to `main` branch.
# Since we're using CD, this triggers a deploy on the `production`
# environment as well.
# ---------------------------------------------------------------

# Make sure we fail and exit if an error is encountered
set -e

# Prints text with colour based on the message's importance level
print_text () {
  if [ "$2" == "info" ]
  then
      COLOR="96m"
  elif [ "$2" == "success" ]
  then
      COLOR="92m"
  elif [ "$2" == "warning" ]
  then
      COLOR="93m"
  elif [ "$2" == "danger" ]
  then
      COLOR="91m"
  else
      COLOR="0m"
  fi

  STARTCOLOR="\e[$COLOR"
  ENDCOLOR="\e[0m"

  printf "$STARTCOLOR%b$ENDCOLOR$ENDCHARACTER" "$1";
}

# Exits the script after printing a warning message
exit_with_message () {
  print_text "$1\n" "warning"
  exit 1
}

print_text "\nRDV-Insertion: Merge and deploy\n" "info"
print_text "------------------------\n\n"

# Gets the current branch by looking for `*` character
# - `s/` is for substitution
# - `/p` prints the result
current_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

# Make sure that we are on staging branch
print_text "Branch check: "
if [ $current_branch != "staging" ]
then
    print_text "Failed\n" "danger"
    exit_with_message "To be able to deploy you need to be on the 'staging' branch. Aborting."
else
    print_text "OK\n" "success"
fi

print_text "\n"

# Get the git status
# - `porcelain` flag returns the output in an easy to parse format for scripts
st=$(git status --porcelain 2> /dev/null)

# Make sure that the status is clean
print_text "Git status check: "
if [[ "$st" != "" ]];
then
    print_text "Failed\n" "danger"
    exit_with_message "To be able to deploy, 'git status' should be clean. Aborting."
else
    print_text "OK\n" "success"
fi

print_text "\n"

git pull -r origin staging
print_text "Pulling latest 'staging' changes: "
print_text "OK\n" "success"

print_text "\n"

# Pushing to main
git checkout main
print_text "Moving to 'main': "
print_text "OK\n" "success"

print_text "\n"

git pull origin main
print_text "Pulling latest 'main' changes: "
print_text "OK\n" "success"

print_text "\n"

git_log_output=$(git log main..staging)

echo "Voici ce qui va être déployé en production :"
echo "--------------------------------------------"
echo "$git_log_output"
echo "--------------------------------------------"

read -p "Souhaitez-vous toujours déployer ? (y/n): " deploy_choice

if [ "$deploy_choice" == "y" ]; then
  git merge --ff-only staging
  print_text "Merging 'staging' changes: "
  print_text "OK\n" "success"

  print_text "\n"

  git push origin main
  print_text "Pushing to 'main': "
  print_text "OK\n" "success"

  print_text "\n"

  git checkout staging
  print_text "All done!\n" "success"
  print_text "Scalingo will take care of starting the deployment.\n" "info"
else
  git checkout staging
  echo "Déploiement annulé"
  exit 1
fi

