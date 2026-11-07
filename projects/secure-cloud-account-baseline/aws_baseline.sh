#!/usr/bin/env bash
# AWS account baseline runbook.
# REVIEW BEFORE RUNNING. Replace every <PLACEHOLDER> first.
# These commands apply the controls in the baseline checklist for AWS.
# Some steps (root MFA) are console-only and are listed as notes.

set -euo pipefail

ACCOUNT_ID="<ACCOUNT_ID>"
LOG_BUCKET="<LOG_BUCKET_NAME>"       # create this bucket first, in the same account for a simple setup
TRAIL_NAME="account-trail"
REGION="us-east-1"

# 1. Root account: enable MFA in the console (IAM > Users > root is not listed;
#    use Account > Security credentials). There is deliberately no CLI for this.
#    Then stop using root for daily work.

# 2. Account-level S3 Block Public Access: on, all four settings.
aws s3control put-public-access-block \
  --account-id "$ACCOUNT_ID" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# 3. CloudTrail in all regions, with log file validation.
aws cloudtrail create-trail \
  --name "$TRAIL_NAME" \
  --s3-bucket-name "$LOG_BUCKET" \
  --is-multi-region-trail \
  --enable-log-file-validation \
  --region "$REGION"
aws cloudtrail start-logging --name "$TRAIL_NAME" --region "$REGION"

# 4. GuardDuty detector on.
aws guardduty create-detector --enable --region "$REGION"

# 5. A budget with alerts at 50, 80, and 100 percent (adjust the amount).
#    Create the budget in the console or with aws budgets create-budget
#    using a JSON file; thresholds and subscriber emails are account specific.

# 6. Password policy for IAM users: length first.
aws iam update-account-password-policy \
  --minimum-password-length 14 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters \
  --max-password-age 90 \
  --password-reuse-prevention 12

echo "AWS baseline commands complete. Verify each control in the console and file the evidence."
