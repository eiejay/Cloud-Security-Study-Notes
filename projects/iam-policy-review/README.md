# IAM Policy Review

A worked example of the most common cloud security task: taking an over-permissive IAM policy apart and rewriting it to least privilege. The workload is fictional: a reporting job that reads two S3 buckets and writes results to a third.

## Files

- policy_before.json: the policy as found
- policy_after.json: the least-privilege rewrite
- policy_check.py: a small checker that flags wildcard actions, wildcard resources, and missing conditions in any policy file

## Run the checker

    python3 policy_check.py policy_before.json
    python3 policy_check.py policy_after.json

The before policy returns findings on every line: a service wildcard (s3:*), a full resource wildcard, and no condition. The after policy clears the wildcard findings. The checker is a first-pass aid; it does not prove a policy correct, it proves the common failures absent.

## What was wrong with the original

1. s3:* grants every S3 action: delete buckets, change policies, disable logging. A reporting job needs to read and write objects, nothing more.
2. Resource * covers every bucket in the account, including backups and the log archive. One compromised credential reaches everything.
3. No condition: no source restriction, no encryption requirement, nothing.

This shape of policy is how small incidents become account-wide ones.

## What the rewrite changes

- Actions narrowed from s3:* to the three calls the job actually makes: GetObject and ListBucket to read, PutObject to write.
- Resources narrowed from * to the three named buckets, with bucket-level and object-level ARNs separated correctly: ListBucket applies to the bucket ARN; GetObject and PutObject apply to object ARNs. Mixing those up is the classic cause of a least-privilege policy that silently does nothing.
- Delete is gone entirely. If the job ever needs it, that is a new review, not a wildcard waiting in place.

## Review method, reusable

1. List what the workload actually did in the last 90 days (CloudTrail or Access Analyzer).
2. Diff that list against what the policy allows. The diff is the finding.
3. Rewrite to the used actions and the named resources.
4. Test in a non-production account first: a least-privilege policy that breaks the job at 2 AM is its own incident.
5. Set a review date. Workloads drift; last year's least privilege is this year's wildcard in disguise.
