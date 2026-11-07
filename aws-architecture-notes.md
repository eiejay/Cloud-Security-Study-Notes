# AWS Architecture Notes

## Shared responsibility

AWS secures the cloud itself: facilities, hardware, the virtualization layer. The customer secures what they put in it: data, identities, configurations, patching of guest systems. Nearly every public AWS breach story is a customer-side configuration, not an AWS failure. That split decides where study time goes.

## IAM

- The root user is for account setup and a short list of tasks only. MFA on it, then stop using it.
- People get roles and groups, never shared accounts and never embedded long-term keys in code.
- Least privilege in practice: start with no access, add the exact actions a task needs, prefer managed policies as a base and scope down from real usage (IAM Access Analyzer shows what was actually used).
- Wildcard actions on wildcard resources are the finding in almost every IAM review. See the IAM Policy Review project in this repository.

## VPC design

- Public subnets hold load balancers and NAT gateways. Application and database subnets are private.
- Security groups are stateful and per resource; network ACLs are stateless and per subnet. Day to day work happens in security groups.
- Flow logs on. When something odd happens, the first question is always where the traffic went.

## S3 security

- Block Public Access stays on at the account level. Exceptions are deliberate, documented, and rare.
- Bucket policies and object ACLs are separate layers; check both before concluding a bucket is private.
- Default encryption on, versioning on for anything that matters, access logging on.

## Logging and detection

- CloudTrail in every region, log file validation on, logs shipped to a separate, locked-down account or bucket when the environment is serious.
- GuardDuty turns CloudTrail, DNS, and flow data into findings. Enable it; the cost of not knowing is higher.
- The review rhythm: findings weekly, IAM review monthly, root and break-glass credentials checked every time anything changes.
