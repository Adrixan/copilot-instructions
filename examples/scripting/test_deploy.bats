#!/usr/bin/env bats
# Tests for deploy.sh — run: bats test_deploy.bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/deploy.sh"
  ARTIFACT="$(mktemp)"
  echo "payload" >"$ARTIFACT"
}

teardown() {
  rm -f "$ARTIFACT"
}

@test "shows usage with --help" {
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "fails without artifact argument" {
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"artifact path is required"* ]]
}

@test "rejects unknown environment" {
  run bash "$SCRIPT" --env qa "$ARTIFACT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"env must be"* ]]
}

@test "rejects missing artifact file" {
  run bash "$SCRIPT" --env staging /nonexistent/file
  [ "$status" -ne 0 ]
  [[ "$output" == *"artifact not found"* ]]
}
