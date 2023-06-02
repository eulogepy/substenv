#!/usr/bin/env bash
# Copyright (c) 2023 Faisan Euloge TIE
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

##
#    A wrapper script around envsubst utility which adds extra functionnalities like:
#      - Interactive variable discorvery and assignment
#      - etc.
###

# Set script related variables
script_name=$(basename "$0" .sh)
script_version="0.1.0"

##
# Error handling
###
error(){
  # shellcheck disable=SC2319 
  local last_exit_status=$?
  local parent_lineno="$1"
  local message="${2:-ERROR: Unkwown.}"
  local code="${3:-$last_exit_status}"

  # Send standard output to standard error
  exec 1>&2

  # Output error message and exit with status 1
  echo "ERROR (near line ${parent_lineno}): ${message}; exiting with status ${code}."
  exit 1
}

##
# Display version information
###
version_info(){
  echo "$script_name $script_version"
  exit 0
}

##
# Display Usage info
###
usage_info(){
  # Blank spacer of same length than 'Usage: $script_name'. Use to harmonize output indentation
  local blnk; blnk=$(echo "Usage: $script_name" | sed 's/./ /g')

  echo "Usage: $script_name [OPTIONS] [SHELL-FORMAT]"
  echo -e "$blnk [-h|--help] [-V|--version] [-v|--variables] [-i|--interactive] [SHELL-FORMAT]"
  echo -e "$blnk [-i|--interactive] [SHELL-FORMAT]"
  echo -e "$blnk [-v|--variables] [SHELL-FORMAT]"
  echo -e "$blnk [-h|--help]"
  echo -e "$blnk [-V|--version]"
}

##
# Wrapper for usage_info() sending the output to he standard error.
# Used to send usage info as error message when the script is invoked with wrong args
###
usage(){
  local message="${1:-'ERROR: Something on your command line did not pass the muster.'}"
  # Send standard output to standard error
  exec 1>&2
  echo -e "$message"
  usage_info
  exit 1
}

##
# Display Help
###
help(){
  usage_info

  cat <<"EOF"  
  Substitutes the values of environment variables.

  OPTIONS

  Operation mode:
    -i, --interactive           Prompt for a value for each variable discovered in the standard input, 
                                prior to performing substitution. Cannot be used in conjonction with 
                                -v or --variable switch.
    -v, --variables             Output the variables occurring in SHELL-FORMAT or in the input content, if any.
                                Cannot be used in conjonction with -i or --interactive switch.

  Informative output:
    -h, --help                  display this help and exit
    -V, --version               output version information and exit

  In normal operation mode, standard input is copied to standard output,
  with references to environment variables of the form $VARIABLE or ${VARIABLE}
  being replaced with the corresponding values.  If a SHELL-FORMAT is given,
  only those environment variables that are referenced in SHELL-FORMAT are
  substituted; otherwise all environment variables references occurring in
  standard input are substituted.

  When --variables is used, the output consists of the environment variables that are referenced
  either in SHELL-FORMAT if provided or in standard input, one per line.
EOF
  exit 0
}

##
# Parse command line args using getopt utility
# Need $@ as argument to get args passed to the script
###
parse_args(){
  # Separately initializing parsed_args prevents getopt's exit status to be overwritten by local's
  local parsed_args=""

  # Get a standardize set of options by parsing the command line options using getopt utility
  if ! parsed_args=$(getopt -n "$script_name" -o hVvi --long help,version,variables,interactive -- "$@"); then
    # Exit with error if getopt parsing somewhat failed
    usage "ERROR: Somthing went wrong while parsing arguments [${parsed_args}]."
  fi
  
  # Output the args as parsed by getopt utility
  echo "$parsed_args"
}

## 
# Discovers variables contained in the argument and 
# outputs an array containing the discovered variable names
###
discover_variables() {
  local input="$1"
  local variables=()

  while IFS= read -r line; do
    
    #TODO: Better comment skipping so than inline comments get skipped as well as comment lines
    # Skip comment lines starting with #
    if [[ $line =~ ^[[:space:]]*# ]]; then
      continue
    fi
    
    # Match $variable or ${variable} patterns
    while [[ $line =~ \$\{?([A-Za-z_][A-Za-z0-9_]*)\}? ]]; do
      match="${BASH_REMATCH[0]}"
      var="${BASH_REMATCH[1]}"
      line=${line/"$match"/""}

      variables+=( "$var" )
    done
  done <  <(printf '%s\n' "$input")

  # Remove duplicates and store unique variables
  variables=( $(echo "${variables[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

  echo "${variables[@]}"
}

## 
# Sets variables respectively named after the arguments 
# and assigned from user inputs
###
prompt_for_values() {

  # Stores arguments in a local array variable
  local variables=( "$@" )

  # Iterates over the array variable, assigning a loop variable ($var) with each element successively
  for var in "${variables[@]}"; do

    # Prompts for a value aimed at assigning a variable named after the current value of $var.
    # Indirect expansion (like ${!var}) is used to display the current value of the variable if it's already set
    # </dev/tty enforces reading from the terminal instead of Stdin. Otherwize the user won't be prompted
    read -r -p "Enter the value for $var [${!var}]: " value < /dev/tty

    # Sets the variable named from the current value of $var and assigned with the user input
    # Existing variable value is only overwritten with non-empty user input
    eval "export $var=\"${value:-\$$var}\""

  done
}

##### MAIN SCRIPT LOGIC

# Capture input from stdin if available
read -t 0 && input=$(cat)

# Parse command line args using getopt utility
eval set -- "$(parse_args "$@")"

# Process command line options out of the parsed args
flags=""
legacy_flags=()
while :; do
  case "$1" in
    -i|--interactive)
      [[ "$flags" = *-v* ]] && error "$LINENO" "Flags -i and -v are mutually exclusive." 1
      flags+="$1"
      shift ;;
    -v|--variables)
      [[ "$flags" = *-i* ]] && error "$LINENO" "Flags -i and -v are mutually exclusive." 1
      flags+="$1"
      legacy_flags+=( "$1" )
      shift ;;
    -V|--version)
      # Show version info and exit the script.
      version_info ;;
    -h|--help)
      # Show help and exit the script.
      help ;;
    --)
      # End of the arguments. Break out of the while loop.
      shift; break ;;
    *)
      usage "ERROR: Invalid option: $1"
      ;;
  esac
done

# Exit with usage error if more than one argument remain after processing the options
if [[ $# -gt 1 ]]; then
  shift
  usage "ERROR: Unsupported extra argument(s): $*"
fi

# The only extra argument should SHELL_FORMAT which is expanded to the input if empty
shell_format="${1:-$input}"

# Check/enforce command line semantic concistency
if [[ "$flags" == *-v* ]]; then
  # Fail if SHELL_FORMAT expanded to input is empty. SHELL_FORMAT is mandatory in variables mode.
  [[ -z "$shell_format" ]] && usage "ERROR: Missing both SHELL_FORMAT argument and input."
else
  # Fail if input is empty. An input is mandatory in substitution mode (which is the default).
  [[ -z "$input" ]] && usage "ERROR: Missing input."
fi

# Implement interactive feature if command line is flaged accordingly
if [[ "$flags" == *-i* ]]; then
  # Dicover variables from the standard input content
  discovered_variables=( $(discover_variables "$input") )

  # Prompt the user for values for the discovered variables
  prompt_for_values "${discovered_variables[@]}"
fi

# Perform envsubst processing
envsubst_result=$(envsubst "${legacy_flags[@]}" "$shell_format" <<< "$input")
envsubst_exit_status=$?
envsubst_lineno="$((LINENO - 2))"

# Handle envsubst error
[[ "$envsubst_exit_status" -eq 0 ]] || error "$envsubst_lineno" "$envsubst_result" "$envsubst_exit_status"

# Output envsubst result
echo "$envsubst_result"
