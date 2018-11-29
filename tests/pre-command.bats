#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
#export AWS_STUB_DEBUG=/dev/tty
#export JQ_STUB_DEBUG=/dev/tty
#export TR_STUB_DEBUG=/dev/tty

setup()
{
  export BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT="acloud:a-output:aregion"
}

teardown() {
  unset BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT
}

@test "Command runs without errors" {
  stub aws \
    "cloudformation describe-stacks --stack-name acloud --region aregion : cat tests/results.json"
  stub jq \
    "'.Stacks[].Outputs[] | select(.OutputKey == \"a-output\") | .OutputValue' : echo look_at_me"

  run "$PWD/hooks/pre-command"
  assert_success
  assert_output "Set ACLOUD_A_OUTPUT to LOOK_AT_ME"

  unstub aws
  unstub jq
}

@test "Command runs errors when no options provided" {
  unset BUILDKITE_PLUGIN_CLOUDFORMATION_OUTPUT_OUTPUT

  run "$PWD/hooks/pre-command"
  assert_failure
  assert_output --partial "🚨: You must supply at least one output to find"
}
