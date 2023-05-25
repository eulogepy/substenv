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
scan_input_file() {
  local input="$1"
  local variables=()

  # One liner for variable discovery using envsubst with the -v|--variable switch
  variables=($(envsubst $input -v | sort -u | tr '\n' ' '))

  echo "${variables[@]}"
}

## ____ Prompt the user for values for the discovered variables ____
# Takes an array of discovered variables and prompts the user to enter values for each variable. 
# Each entered value is assigned to the corresponding variable
prompt_user_for_values() {
  local variables=("$@")

  # Iterate over the discovered variables array and pick each variable name into the $var loop variable
  for var in "${variables[@]}"; do

    # Prompt for a value for the current variable picked into $var
    read -p "Enter the value for $var [${!var}]: " value

    # Assign the user input to the variable picked into $var.
    # Overwrite the existing value only if user input is not empty
    eval "$var=\"${value:-\$$var}\""

  done
}

##### Main script logic

# Check if command-line arguments are provided
if [[ $# -lt 2 ]]; then
  echo "Error: Missing argument(s)! any of input and output file name is not provided." >&2
  exit 1
fi

# Store standard input data into $input
input=$(cat)

# Scanning input file for variables
discovered_variables=($(scan_input "$input"))

# Prompting the user for values for the discovered variables
prompt_user_for_values "${discovered_variables[@]}"

# Generate the output from $input by performing variable substitution using envsubst 
echo $input | envsubst 
