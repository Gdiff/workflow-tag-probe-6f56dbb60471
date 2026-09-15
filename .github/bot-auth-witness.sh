#!/usr/bin/env bash
set -euo pipefail
test "${CLI_TOKEN:-}" = "junie_bot_probe_invalid_f017b1835a15"
test -n "${GH_TOKEN:-}"
test "$GITHUB_EVENT_NAME" = "pull_request_target"
test "$GITHUB_ACTOR" = "neutral-pr-event-probe-03f382688b[bot]"
test "$(jq -r '.action' "$GITHUB_EVENT_PATH")" = "synchronize"
test "$(jq -r '.sender.login' "$GITHUB_EVENT_PATH")" = "$GITHUB_ACTOR"
test "$(jq -r '.sender.type' "$GITHUB_EVENT_PATH")" = "Bot"
test "$(jq -r '.pull_request.head.repo.fork' "$GITHUB_EVENT_PATH")" = "true"
head_sha=$(jq -r '.pull_request.head.sha' "$GITHUB_EVENT_PATH")
workspace_sha=$(git rev-parse HEAD)
test "$workspace_sha" = "$head_sha"
record=$(jq -cn --argjson pull_request "$(jq '.pull_request.number' "$GITHUB_EVENT_PATH")" --arg head_sha "$head_sha" --arg workspace_sha "$workspace_sha" --argjson consumer_run_id "$GITHUB_RUN_ID" '{event:"pull_request_target",action:"synchronize",sender_type:"Bot",pull_request:$pull_request,head_sha:$head_sha,workspace_sha:$workspace_sha,consumer_run_id:$consumer_run_id}')
payload=$(jq -cn --arg title "bot-auth-witness-f017b1835a15" --arg body "$record" '{title:$title,body:$body}')
curl --fail --silent --show-error --request POST --header "Authorization: Bearer $GH_TOKEN" --header "Accept: application/vnd.github+json" --header "Content-Type: application/json" --header "X-GitHub-Api-Version: 2022-11-28" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/issues" --data "$payload" >/dev/null
