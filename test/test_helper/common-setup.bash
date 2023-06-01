#!/usr/bin/env bash

# Common setup function to be called in setup_file() functions
_common_setup_file() {

  PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )" 
  export PROJECT_ROOT
  export PATH="$PROJECT_ROOT/src:/usr/local/opt/gnu-getopt/bin:/usr/local/bin:$PATH"
  export SCRIPT_NAME="${SCRIPT_NAME:-substenv}"
  export SHELL_FORMAT="Please deal with \$FOO and \$BAR and again with \$FOO"
  export STDIN="Please deal with \$FOO and \$BAR and again with \$FOO"
  export INPUT_FILE="${INPUT_FILE:-${BATS_FILE_TMPDIR}/${INPUT_FILE_BASENAME:-input_file.txt}}"
  export FOO="Willy"
  export BAR="his accomplices"

  # Create the input file at the appropriate location if none exists yet or if the existing one is empty
  if [[ ! -e "$INPUT_FILE" || $(< "$INPUT_FILE") = "" ]]; then
    echo "Please deal with \$FOO and \$BAR and again with \$FOO." > "$INPUT_FILE"
  fi
}

# Common setup function to be called in setup() functions
_common_setup() {

  # Load needed helpers
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-file/load'

  # Expand to a distinct filename for each and every test in the calling test file or suite
  export OUTPUT_FILE="${OUTPUT_DIR:-BATS_FILE_TMPDIR}/output_file_${BATS_SUITE_TEST_NUMBER}.txt"
}