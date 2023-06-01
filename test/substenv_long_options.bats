#!/usr/bin/env bats
##
# BATS tests for substenv script
#
# Tags description
#    uc            Use case
#      :success         Successfull execution flow
#      :failure         Failing execution flow
#      :d-mod           Default mode, variable substition in input
#      :v-mod           Variables mode, variables listing
#      :i-mod           Interactive mode, user is promted for variables' values before performing substitution 
#      :arg             Arg based operation mode (SHELL_FORMAT)
#      :stdin           Stdin based operation mode (STDIN)
#      :file            File based input/output
#      :short-opt       Using short options flavour like -v
#      :long-opt        Using long options flavour like -v
#      :var-excl        Implement variable exclusion feature
#      :info            Relating to information display
###


# File level setup
setup_file() {

    load 'test_helper/common-setup'
    _common_setup_file

    echo "Testing $SCRIPT_NAME with long options flavour ..." >&3
    echo >&3
}

# Test level setup
setup(){
    #TODO: Figure out how to effectively load the helpers for all the tests once for keeps
    load 'test_helper/common-setup'
    _common_setup
}

# File level cleanup
teardown_file() { 
  
  # $input_file target input file in the current test file context, if any
  local input_file="${BATS_FILE_TMPDIR}/${INPUT_FILE_BASENAME}"

  # Remove input file in the current test file context, if any
  if [[ -e "${input_file}" ]]; then
    rm -f "${input_file}"
  fi

  # Acknowledgement test suite completion
  #echo -e "\nTest file for ${BATS_TEST_FILENAME##*/} is completed." >&3
  echo -e "\nTesting $SCRIPT_NAME with long options flavour completed." >&3
}

# Test level cleanup
teardown() {
  # Remove output file specific current test, if any.
  if [[ -e "$OUTPUT_FILE" ]]; then
    rm -f "$OUTPUT_FILE"
  fi
}

# bats test_tags=uc:long-opt,uc:success,uc:v-mod,uc:arg
@test 'Should list all variables from SHELL_FORMAT arg.' {
    run substenv.sh --variables "$SHELL_FORMAT"
    assert_success
    assert_output <<< "FOO BAR FOO"
}

# bats test_tags=uc:long-opt,uc:success,uc:v-mod,uc:stdin
@test 'Should list all variables from Stdin content.' {
    run substenv.sh --variables <<< "$STDIN"
    assert_success
    assert_output <<< "FOO BAR FOO"
}

#TODO: Figure out a way to test interactive mode. Consider utilities like expect/sexpect/empty
# bats test_tags=uc:long-opt,uc:success,uc:d-mod,uc:stdin,uc:i-mod
@test 'Should check basic interactive mode.' {
    skip "Upcoming: Interactive mode testing"
    run substenv.sh --interactive <<< "$STDIN"
    assert_output 'Please deal with Willy and his accomplices and again with Willy'
    [ "$status" -eq 0 ]
}

# bats test_tags=uc:long-opt,uc:success,uc:d-mod,uc:stdin,uc:i-mod,uc:var-excl
@test 'Should check interactive mode with variable exclusions.' {
    skip "Upcoming"
    run substenv.sh --interactive <<< "$STDIN"
    assert_success
    assert_output 'Please deal with Willy and his accomplices and again with Willy'
}

# bats test_tags=uc:long-opt,uc:success,uc:info
@test 'Should output help content and exit sucessfully' {
    run substenv.sh --help
    assert_success
    assert_output --partial "Usage: ${SCRIPT_NAME} [OPTIONS] [SHELL-FORMAT]"
}

# bats test_tags=uc:long-opt,uc:success,uc:info
@test 'Should version information and exit sucessfully' {
    run substenv.sh --version
    assert_success
    assert_output --regexp "^${SCRIPT_NAME}[[:space:]]*[[:digit:]]*[.][[:digit:]]*[.][[:digit:]]*.*$"
}

# bats test_tags=uc:long-opt,uc:failure,uc:stdin,uc:v-mod,uc:i-mod
@test 'Should fail and complain about flags -i and -v mutual exlusion' {
    run substenv.sh --variables --interactive <<< "$STDIN"
    assert_failure
    assert_output --partial 'Flags -i and -v are mutually exclusive'
}

# bats test_tags=uc:long-opt,uc:failure,uc:stdin
@test 'Should fail and complain against an invalid option' {
    run substenv.sh --option <<< "$STDIN"
    assert_failure
    assert_output --partial 'Invalid option'
}

# bats test_tags=uc:long-opt,uc:failure
@test 'Should fail and complain against missing both argument and input' {
    run substenv.sh --variables
    assert_failure
    assert_output --partial 'Missing both SHELL_FORMAT argument and input'
}

