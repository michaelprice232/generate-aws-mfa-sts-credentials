# assume-role IAM Switch Role (with MFA)

The script assumes an IAM cross account switch role which is MFA enabled. Generates temporary STS credentials which are exported, as well as echo'd out.

Pre-reqs:
1) The AWS CLI & jq have been installed locally
2) MFA enabled cross account IAM switch role has been configured between two AWS accounts

## Usage

- Update the `SWITCH_ROLE_ARN` and `AWS_PROFILE` variables in the script
- Dot source the script:
```
. ./assume-mfa-role.sh <mfa-token>
```