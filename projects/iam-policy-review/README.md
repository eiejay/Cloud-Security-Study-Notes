# IAM Policy Review

A worked example of the most common cloud security task: taking an over-permissive IAM policy apart and rewriting it to least privilege. The workload is fictional: a reporting job that reads two S3 buckets and writes results to a third.

## The policy as found

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": "*"
        }
      ]
    }

## What is wrong with it

1. s3:* grants every S3 action: delete buckets, change policies, disable logging. A reporting job needs to read and write objects, nothing more.
2. Resource * covers every bucket in the account, including backups and the log archive. One compromised credential reaches everything.
3. There is no condition: no source restriction, no encryption requirement, nothing.

This shape of policy is how small incidents become account-wide ones.

## The rewrite

    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "ReadSourceBuckets",
          "Effect": "Allow",
          "Action": ["s3:GetObject", "s3:ListBucket"],
          "Resource": [
            "arn:aws:s3:::reports-in-a",
            "arn:aws:s3:::reports-in-a/*",
            "arn:aws:s3:::reports-in-b",
            "arn:aws:s3:::reports-in-b/*"
          ]
        },
        {
          "Sid": "WriteResultsOnly",
          "Effect": "Allow",
          "Action": ["s3:PutObject"],
          "Resource": ["arn:aws:s3:::reports-out/*"]
        }
      ]
    }

## What changed and why

- Actions narrowed from s3:* to the three calls the job actually makes: GetObject and ListBucket to read, PutObject to write.
- Resources narrowed from * to the three named buckets, with bucket-level and object-level ARNs separated correctly: ListBucket applies to the bucket ARN, GetObject and PutObject to the object ARNs. Mixing those up is the classic cause of a least-privilege policy that silently does nothing.
- Delete is gone entirely. If the job ever needs it, that is a new review, not a wildcard waiting in place.

## Review method, reusable

1. List what the workload actually did in the last 90 days (CloudTrail or Access Analyzer).
2. Diff that list against what the policy allows. The diff is the finding.
3. Rewrite to the used actions and the named resources.
4. Test in a non-production account first: a least-privilege policy that breaks the job at 2 AM is its own incident.
5. Set a review date. Workloads drift; last year's least privilege is this year's wildcard in disguise.
