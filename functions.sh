#!/bin/bash

function awsto() {
  unset AWS_VAULT && aws-vault exec $1
}
