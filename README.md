# assume-role IAM Switch Role (with MFA)

The script assumes an IAM cross account switch role which is MFA enabled. Generates temporary STS credentials which are exported, as well as echo'd out.

Pre-req:
The AWS CLI has been installed locally, and an MFA enabled cross account IAM switch role has been configured between two AWS accounts

To Use:
- Update the `SWITCH_ROLE_ARN` and `AWS_PROFILE` variables in the script
- Dot source the script:
```. ./assume-mfa-role.sh <mfa-token>```