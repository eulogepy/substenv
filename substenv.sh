#!/usr/bin/env bash

####
# This script scans the input file to discover variables, 
# then Prompt the user for values for the discovered variables which are
# and finally Generate the output file by substituting variables
# in the input file using envsubst utility
#
#
#####


# ____ Scan the input file to discover variables ____
# Scans the input file and extracts variables
# by searching for patterns like $variable or ${variable}. 
# The discovered variables ar stored in an array.
discover_variables() {
  local input="$1"
  local variables=()

  while IFS= read -r line; do
    
    # Skip comment lines starting with #
    if [[ $line =~ ^[[:space:]]*# ]]; then
      continue
    fi
    
    # Match $variable or ${variable} patterns
    while [[ $line =~ \$\{?([A-Za-z_][A-Za-z0-9_]*)\}? ]]; do
      match="${BASH_REMATCH[0]}"
      var="${BASH_REMATCH[1]}"
      line=${line/"$match"/""}

      variables+=("$var")
    done
  done <  <(printf '%s\n' "$input")

  # Remove duplicates and store unique variables
  variables=($(echo "${variables[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

  echo "${variables[@]}"
}

## ____ Prompt the user for values for the discovered variables ____
# Takes an array of discovered variables and prompts the user to enter values for each variable. 
# Each entered value is assigned to the corresponding variable
prompt_for_values() {
  local variables=("$@")

  # Iterate over the discovered variables array and pick each variable name into the $var loop variable
  for var in "${variables[@]}"; do

    # Prompt for a value for the current variable picked into $var
    read -p "Enter the value for $var [${!var}]: " value < /dev/tty

    # Assign the user input to the variable picked into $var.
    # Overwrite the existing value only if user input is not empty
    eval "export $var=\"${value:-\$$var}\""

  done
}

##### MAIN SCRIPT LOGIC

# Store standard input data into $input
input=$(cat)

# Scanning input file for variables
discovered_variables=($(discover_variables "$input"))

# Prompting the user for values for the discovered variables
prompt_for_values "${discovered_variables[@]}"

# Generate the output from $input by performing variable substitution using envsubst 
envsubst <<< "$input" 
