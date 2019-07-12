#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
#export AWS_STUB_DEBUG=/dev/tty
#export JQ_STUB_DEBUG=/dev/tty
#export TR_STUB_DEBUG=/dev/tty

setup()
{
  export BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT_0="acloud:a-output:aregion"
  export BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT_1="bcloud:b-output:bregion"
  export BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT_2="ccloud:c-output:cregion"
}

@test "Command runs without errors" {
  stub aws \
    "cloudformation describe-stacks --stack-name acloud --region aregion : cat tests/aresults.json" \
    "cloudformation describe-stacks --stack-name bcloud --region bregion : cat tests/bresults.json" \
    "cloudformation describe-stacks --stack-name ccloud --region cregion : cat tests/cresults.json"
  stub jq \
    "-r '.Stacks[].Outputs[] | select(.OutputKey == \"a-output\") | .OutputValue' : echo look_at_me" \
    "-r '.Stacks[].Outputs[] | select(.OutputKey == \"b-output\") | .OutputValue' : echo look_at_b" \
    "-r '.Stacks[].Outputs[] | select(.OutputKey == \"c-output\") | .OutputValue' : echo look_at_c"

  run "$PWD/hooks/pre-command"
  assert_success
  assert_output --partial "Set ACLOUD_A_OUTPUT to look_at_me"
  assert_output --partial "Set BCLOUD_B_OUTPUT to look_at_b"
  assert_output --partial "Set CCLOUD_C_OUTPUT to look_at_c"

  unstub aws
  unstub jq
}

@test "Command runs errors when no options provided" {
  unset BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT_0
  unset BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT_1
  unset BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT_2

  run "$PWD/hooks/pre-command"
  assert_failure
  assert_output --partial "🚨: You must supply at least one output to find"
}
