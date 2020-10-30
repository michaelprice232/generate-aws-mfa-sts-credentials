#!/bin/bash

###
### Script to generate AWS STS temporary credentials which are MFA enabled. Dot source the output of the script, after passing it a valid MFA token
### Usage: . ./assume-mfa-role.sh <mfa-token>
###
### Pre-req: an AWS profile is created, as per AWS_PROFILE variable below, with valid AWS credentials to the base account. jq & AWS CLI are installed
###

set -e

# IAM switch role to assume
SWITCH_ROLE_ARN='arn:aws:iam::<account>:role/<role>'

# AWS profile which holds the credentials of the root account (which we are switching from)
export AWS_PROFILE='<profile-name>'

# Session duration - must be <= the max allowed for the role
SESSION_DURATION=3600     # 1 hours

# Retrieve the MFA token as a parameter
MFA_TOKEN=${1?"Please enter the MFA_TOKEN. Usage: $0 <MFA_TOKEN>"}

# Unset any existing AWS CLI ENVARS to avoid it overridding any CLI Commands
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

# Set CLI defaults
AWS_DEFAULT_REGION='eu-west-1'
AWS_DEFAULT_OUTPUT='json'


# Retrieve the username & MFA ARN from the IAM credentials
IAM_USER_ARN=$(aws sts get-caller-identity | jq -r '.Arn')
USERNAME=$(cut -d '/' -f2 <<< "${IAM_USER_ARN}")
MFA_SERIAL_ARN=$(aws iam list-mfa-devices --user-name "${USERNAME}" | jq -r '.MFADevices[0].SerialNumber')

# Assume the switch role, passing the MFA token
RESPONSE=$(aws sts assume-role --role-arn "${SWITCH_ROLE_ARN}" --role-session-name "${USERNAME}-switch-role-session" --duration-seconds  "${SESSION_DURATION}" --serial-number "${MFA_SERIAL_ARN}" --token-code "${MFA_TOKEN}")
AWS_ACCESS_KEY_ID=$(echo "${RESPONSE}" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "${RESPONSE}" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "${RESPONSE}" | jq -r '.Credentials.SessionToken')

# Export the temporary (MFA enabled) STS credentials
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
export AWS_DEFAULT_REGION

unset RESPONSE
unset MFA_SERIAL_ARN
unset USERNAME
unset IAM_USER_ARN
unset AWS_DEFAULT_OUTPUT
unset MFA_TOKEN
unset SESSION_DURATION
unset AWS_PROFILE
unset SWITCH_ROLE_ARN
