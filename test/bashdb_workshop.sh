#!/usr/bin/env bash
# Copyright (c) 2023 Faisan Euloge TIE
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

remove_from_path() {
    # Store arguments as dependency names in a local array variable
    local dependencies=( "$@" )

    # Get full paths of which and sed utilities so that they can still be used in the long form (i.e /usr/bin/sed )
    # in the event their respective paths get removed from PATH along with dependencies's
    local which_cmd="$(which which)"
    local sed_cmd="$(which sed)"
    
    # Backup the pristine value of PATH
    local PRISTINE_PATH="$PATH"

    # For each substenv required dependency, 
    for dep in "${dependencies[@]}"; do
      # As long as an occurrence of that very dependency is resolved from PATH
      while dep_path="$(eval "$which_cmd $dep")"; do
        # Get the location of that occurence of the dependency
        dep_basepath="${dep_path%/*}"
        # Build a sed expression which can escape every regex special char in that location
        sed_patternize_path_expr='s/([.+?^([|\\${}/])/\\\1/g'

        # Build a sed expression which can remove every occurrence of that location from PATH
        sed_rm_path_expr="s/$(eval "${sed_cmd} -Ee '${sed_patternize_path_expr}' <<< '${dep_basepath}'")//g"
        
        # Get a new value for PATH which is cleaned up of that dependency location
        PATH="$(eval "${sed_cmd} -Ee '${sed_rm_path_expr}' <<< '${PATH}'")"
      done

      # If the dependency is still in PATH, output the pristine value of PATH and return a failure status
      if eval "$which_cmd $dep"; then
        echo "$PRISTINE_PATH"
        return 1
      fi
    done

    # Output a new value for PATH which no more contain any location to any of the substenv required dependencies
    echo "$PATH"
}

dependencies=( "envsubst" "getopt" )

remove_from_path "${dependencies[@]}"