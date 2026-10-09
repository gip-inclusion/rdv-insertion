# REVIEW.md

How to review a pull request in this repository. The code conventions to check live in `AGENTS.md`;
this file says what a review reports and how each finding is backed.

## Mandate

A finding reports one of three things, in the lines the pull request adds or changes:

- **A correctness defect**: for an input or a state the application can reach, the changed code
  crashes, returns a wrong result, loses or corrupts data, or breaks a flow that worked before.
- **A security problem**: an action reachable without the authorization it needs, data shown to
  someone who should not see it, an injection, a secret written in the code.
- **A departure from a convention written in `AGENTS.md`**, quoting the convention.

Every finding is one the author should fix before merging: a defect you would rate low severity,
other than a departure from a written convention, is a remark for the human reviewers, not a
finding. A sound pull request gets no finding: silence
is the right review for it.

## Precision before recall

Report a defect once the code you read shows it. A suspicion is where to read further: follow the
code it depends on (callers, scopes, callbacks, the gem) until it shows the defect or clears it.

## Back every claim with the code you read

- Before stating what a method, a scope, a callback, a policy or a gem does, open its definition and
  quote the lines your claim rests on, with their file. What a name suggests is a hypothesis: check
  it in the code, or leave it out. The version of each gem is in `Gemfile.lock`.
- When a change removes or alters a guard (a `distinct`, a validation, an authorization, a scope, a
  `where` clause, a transaction), read the code that depends on it before concluding: its callers,
  the policy scopes, the concerns that build on the same query.
- Read the specs the pull request adds or changes: they show what the author intends, and they
  follow the testing conventions of `AGENTS.md`.
- The specs of the pull request pass in CI. A claim that one of them fails, or passes for the
  wrong reason, needs the spec line that shows it; without that line, the claim is a hypothesis to
  leave out.

## Read the intent of the pull request first

The title and description of the pull request come with the diff. A behaviour they ask for is
intended: report it only when it breaks something the description does not account for.

## Leave the rest to the linters and to the human reviewers

Each of these has another owner; keep your findings on the mandate above.

- Formatting, style and naming: RuboCop and ESLint check what can be checked, and names are the
  author's choice.
- Test coverage: review the specs against the testing conventions of `AGENTS.md`; which tests to
  write is the author's decision.
- Refactoring, design, architecture, performance, maintainability, and robustness against states the
  application never reaches: the human reviewers discuss them. When one of them causes a correctness
  or security defect, report that defect.
- Business rules: what the product should do is decided with the team. Report where the code
  contradicts the intent the pull request states.

## One finding per defect

Report each defect once, at the line that introduces it. When the same defect recurs elsewhere, list
the other places in that one finding.

## Re-reviews converge

When reviewing a pull request again, report the defects the new commits introduce. A commit that
answers an earlier finding gets a finding of its own only when it introduces a defect.

## Files left out

Generated files, migrations and lockfiles are left out of the review by `.opencodereview/rule.json`.
Read them as context when a finding needs it.
