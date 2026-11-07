# Sign-In Anomaly Scorer: Learning What Normal Looks Like

Conditional access policies catch the sign-in that breaks a rule. Nobody's rules catch the sign-in that is technically allowed and completely wrong: right password, 3 AM, a city the user has never been in, a device nobody recognizes. I built this scorer to work that gap the way an analyst does: learn each user's normal first, their home city and their hours, then score every sign-in for how far it strays, with the reasons printed next to the points.

## Run it

    python3 anomaly_scorer.py signins.csv

## What I got

    Sign-ins scored: 18  Flagged for review: 4

     75 pts  INVESTIGATE  a.okafor  2026-10-30 03:16  Lagos  failure
            - away from home city Dallas
            - unrecognized device
            - failed attempt

     65 pts  REVIEW  a.okafor  2026-10-30 03:14  Lagos  success

     45 pts  REVIEW  a.okafor  2026-10-31 09:02  Houston  success
            - away from home city Dallas

The sample log tells a story I planted on purpose: a Dallas user, business hours, all week. Then a 3 AM success from Lagos on an unknown device, followed by two failures. Then a Houston trip the next morning, which flags REVIEW and nothing more, because travel is a question, not a verdict. That gap between REVIEW and INVESTIGATE is the whole design: the score sorts the queue, the analyst works it top down.

## Two lessons baked into the sample

- Baseline contamination is real. The scorer learns normal from the same log it judges, so the attacker's 3 AM hour becomes part of the pattern and earns no hour points. Production systems handle this with clean training windows and confirmed incident exclusions. Mine does not yet, and the output shows it if you look.
- A successful sign-in can be the scariest row in the log. The Lagos success scores lower than the failures only because failure adds points; in a real queue I would work it first. Scores advise. They do not decide.

## How it connects to the rest of this repo

The baseline checklist project is prevention: MFA on, legacy auth off, dormant accounts reviewed. This scorer is the detection that assumes prevention leaks, which it does, and it pairs with the IAM policy review the same way: least privilege shrinks what a stolen session can reach, and anomaly scoring tells you which session to look at first.
