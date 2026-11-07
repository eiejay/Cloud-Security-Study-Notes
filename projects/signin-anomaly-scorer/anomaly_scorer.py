#!/usr/bin/env python3
"""Sign-in anomaly scorer: learn each user's normal, then score the rest.

Usage:
    python3 anomaly_scorer.py signins.csv

Every cloud tenant already records these rows. The trick is not
collecting them, it is reading them like an analyst: build each user's
baseline (their usual cities, their usual hours), then score every
sign-in for how far it strays. Points come with reasons, because a
score nobody can explain is a score nobody acts on.
"""

import csv
import sys
from collections import defaultdict
from datetime import datetime

REVIEW_AT = 40
INVESTIGATE_AT = 70


def parse_time(raw):
    return datetime.strptime(raw, "%Y-%m-%d %H:%M")


def score_signins(rows):
    cities = defaultdict(set)
    hours = defaultdict(set)
    for row in rows:
        cities[row["user"]].add(row["city"])
        hours[row["user"]].add(parse_time(row["time"]).hour)
    scored = []
    for row in rows:
        user = row["user"]
        hour = parse_time(row["time"]).hour
        home = max(
            cities[user],
            key=lambda c: sum(1 for r in rows if r["user"] == user and r["city"] == c),
        )
        points = 0
        reasons = []
        if row["city"] != home:
            points += 45
            reasons.append(f"away from home city {home}")
        typical = hours[user]
        if typical and all(abs(hour - h) > 3 and abs(hour - h) < 21 for h in typical):
            points += 30
            reasons.append(f"hour {hour:02d}:00 is far outside this user's pattern")
        if row["device_known"] == "no":
            points += 20
            reasons.append("unrecognized device")
        if row["result"] == "failure":
            points += 10
            reasons.append("failed attempt")
        scored.append((points, row, reasons))
    return scored


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 anomaly_scorer.py <signins.csv>")
        return 2
    with open(sys.argv[1], newline="") as handle:
        rows = list(csv.DictReader(handle))
    scored = score_signins(rows)
    flagged = [item for item in scored if item[0] >= REVIEW_AT]
    flagged.sort(key=lambda item: item[0], reverse=True)
    print(f"Sign-ins scored: {len(rows)}  Flagged for review: {len(flagged)}")
    for points, row, reasons in flagged:
        verdict = "INVESTIGATE" if points >= INVESTIGATE_AT else "REVIEW"
        print(f"\n{points:>3} pts  {verdict}  {row['user']}  {row['time']}  {row['city']}  {row['result']}")
        for reason in reasons:
            print(f"        - {reason}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
