#!/usr/bin/env bash

setup_suite() {
  # Export variable relevant at this level
  export SCRIPT_NAME='substenv'
  export INPUT_FILE_BASENAME='input_file.txt'
  export INPUT_FILE="${BATS_SUITE_TMPDIR}/${INPUT_FILE_BASENAME}"
  export OUTPUT_DIR="${BATS_SUITE_TMPDIR}"

  # Create the input file at the appropriate location
  echo "Please deal with \$FOO and \$BAR and again with \$FOO." > "$INPUT_FILE"

  # Acknowledgement test suite starting
  echo -e "\nStating test suite for $SCRIPT_NAME script ..." >&3
}

teardown_suite() {
  # Target input file in BATS_SUITE_TMPDIR only 
  local input_file="${BATS_SUITE_TMPDIR}/${INPUT_FILE_BASENAME}"

  # Remove test suite level input file if any
  if [[ -e "$input_file" ]]; then 
      rm -f "$input_file"
  fi

  # Acknowledgement test suite completion
  echo -e "\nTest suite for $SCRIPT_NAME script is completed." >&3
}