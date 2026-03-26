#!/usr/bin/env bash
set -euo pipefail

AMI_ID="${1:-}"
PARAMETER_NAME="${2:-}"
REGION="${3:-${AWS_REGION:-${AWS_DEFAULT_REGION:-}}}"

if [[ -z "$AMI_ID" || -z "$PARAMETER_NAME" || -z "$REGION" ]]; then
  echo "usage: ./scripts/publish-ami-parameter.sh <ami-id> <parameter-name> <region>" >&2
  exit 1
fi

aws ssm put-parameter \
  --region "$REGION" \
  --name "$PARAMETER_NAME" \
  --type String \
  --value "$AMI_ID" \
  --overwrite
