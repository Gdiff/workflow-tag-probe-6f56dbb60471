#!/usr/bin/env bash
set -euo pipefail
test "${CLI_TOKEN:-}" = "junie_bot_probe_invalid_f017b1835a15"
test -n "${GH_TOKEN:-}"
test "$GITHUB_EVENT_NAME" = "pull_request_target"
test "$GITHUB_ACTOR" = "neutral-pr-event-probe-03f382688b[bot]"
test "$(jq -r '.action' "$GITHUB_EVENT_PATH")" = "synchronize"
test "$(jq -r '.sender.type' "$GITHUB_EVENT_PATH")" = "Bot"
head_commit=$(jq -r '.pull_request.head.sha' "$GITHUB_EVENT_PATH")
workspace_commit=$(git rev-parse HEAD)
test "$workspace_commit" = "$head_commit"
record=$(jq -cn --arg fixture "comment-witness-f017b1835a15" --argjson pull_request "$(jq '.pull_request.number' "$GITHUB_EVENT_PATH")" --arg head_commit "$head_commit" --arg workspace_commit "$workspace_commit" --argjson consumer_run_id "$GITHUB_RUN_ID" '{fixture:$fixture,event:"pull_request_target",action:"synchronize",sender_type:"Bot",pull_request:$pull_request,head_commit:$head_commit,workspace_commit:$workspace_commit,consumer_run_id:$consumer_run_id}')
payload=$(jq -cn --arg body "$record" '{body:$body}')
curl --fail --silent --show-error --request POST --header "Authorization: Bearer $GH_TOKEN" --header "Accept: application/vnd.github+json" --header "Content-Type: application/json" --header "X-GitHub-Api-Version: 2022-11-28" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/issues/10/comments" --data "$payload" >/dev/null
