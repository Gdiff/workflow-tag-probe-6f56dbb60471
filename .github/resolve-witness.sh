#!/usr/bin/env bash
set -euo pipefail
test "${CLI_TOKEN:-}" = "junie_fixture_invalid_resolvefc82f999"
test -n "${GH_TOKEN:-}"
test "$(jq -r '.inputs.action // empty' "$GITHUB_EVENT_PATH")" = "resolve-conflicts"
pr_number="$(jq -r '.inputs.prNumber // empty' "$GITHUB_EVENT_PATH")"
test "$pr_number" -ge 1
test -f .resolve-route-marker
grep -qx 'external-fork-route-marker' .resolve-route-marker
workspace_sha="$(git rev-parse HEAD)"
payload="$(
  jq -cn \
    --arg title "resolve-route-witness-resolvefc82f999" \
    --arg pr_number "$pr_number" \
    --arg run_id "$GITHUB_RUN_ID" \
    --arg workspace_sha "$workspace_sha" \
    '{title:$title,body:({pr_number:$pr_number,run_id:$run_id,workspace_sha:$workspace_sha}|tojson)}'
)"
curl --fail --silent --show-error \
  --request POST \
  --header "Authorization: Bearer $GH_TOKEN" \
  --header "Accept: application/vnd.github+json" \
  --header "Content-Type: application/json" \
  "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/issues" \
  --data "$payload" >/dev/null
