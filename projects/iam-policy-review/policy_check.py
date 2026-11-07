#!/usr/bin/env python3
"""Quick IAM policy checker: flags wildcards and missing conditions.

Usage:
    python3 policy_check.py policy.json

This is a first-pass review aid, not a full policy evaluation. It flags
the findings that appear in almost every IAM review: wildcard actions,
service-wide actions, wildcard resources, and statements with no
condition. A clean run means these specific problems are absent; it
does not prove the policy is right for the workload.
"""

import json
import sys


def as_list(value):
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


def check(path):
    with open(path) as handle:
        policy = json.load(handle)
    findings = []
    for index, statement in enumerate(as_list(policy.get("Statement"))):
        sid = statement.get("Sid", f"statement {index + 1}")
        for action in as_list(statement.get("Action")):
            if action == "*":
                findings.append(f"[{sid}] Action is a full wildcard (*): grants every action in every service")
            elif action.endswith(":*"):
                findings.append(f"[{sid}] Action {action} grants every action in one service")
        for resource in as_list(statement.get("Resource")):
            if resource == "*":
                findings.append(f"[{sid}] Resource is a full wildcard (*): applies to every resource in the account")
        if "Condition" not in statement:
            findings.append(f"[{sid}] No Condition element: consider source, MFA, or encryption conditions where the workload allows")
    print(f"Policy: {path}")
    if findings:
        print(f"Findings: {len(findings)}")
        for finding in findings:
            print(f"  - {finding}")
    else:
        print("Findings: none from this check")
    return 1 if any("wildcard" in f for f in findings) else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 policy_check.py <policy.json>")
        sys.exit(2)
    sys.exit(check(sys.argv[1]))
