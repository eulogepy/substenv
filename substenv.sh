#!/usr/bin/env bash

####
# This is a wrapper script for envsubst utility which adds extra functionnalities like:
#        - Interactive variable discorvery and assignment
# Todo   - Variable exclusion and escaping mechanisms(ingore unset variables, ignore explicit list of variables, ...)
#        - etc.
#####

## 
# Discovers variables contained in the argument and 
# outputs an array containing the discovered variable names
###
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

## 
# Sets variables respectively named after the arguments 
# and assigned from user inputs
###
prompt_for_values() {

  # Stores arguments in a local array variable
  local variables=("$@")

  # Iterates over the array variable, assigning a loop variable ($var) with each element successively
  for var in "${variables[@]}"; do

    # Prompts for a value aimed at assigning a variable named after the current value of $var.
    # Indirect expansion (like ${!var}) is used to display the current value of the variable if it's already set
    # </dev/tty enforces reading from the terminal instead of Stdin. Otherwize the user won't be prompted
    read -p "Enter the value for $var [${!var}]: " value < /dev/tty

    # Sets the variable named from the current value of $var and assigned with the user input
    # Existing variable value is only overwritten with non-empty user input
    eval "export $var=\"${value:-\$$var}\""

  done
}

##### MAIN SCRIPT LOGIC

#TODO: Enhance by handling commmand line args, at least those supported by envsubst

# Capture standard input content
input=$(cat)

# Dicover variables from the standard input content
discovered_variables=($(discover_variables "$input"))

# Prompt the user for values for the discovered variables
prompt_for_values "${discovered_variables[@]}"

# Generate the output from the input content by performing variable substitution using envsubst utility
#envsubst < <(echo "$input") # Process substitution flavor
envsubst <<< "$input" # Here-String flavor
