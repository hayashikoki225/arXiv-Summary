#!/bin/bash
set -euo pipefail

export PATH="/Users/hayashikoki/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DATE=$(date +%Y-%m-%d)

# Skip on weekends: arXiv does not announce new papers on Sat/Sun.
# date +%u => 1=Mon ... 6=Sat, 7=Sun
DOW=$(date +%u)
if [ "${DOW}" -ge 6 ]; then
    echo "Weekend (day ${DOW}): no arXiv update. Skipping."
    exit 0
fi

# AI backend selection: "claude" or "codex"
BACKEND="codex" # "codex"

# Model selection (claude only, codex will auto-select the model)
CLAUDE_MODEL="claude-opus-4-8" # "claude-opus-4-8, claude-sonnet-4-8" etc.

# Function to call AI
call_ai() {
    local prompt="$1"
    local output="$2"
    
    if [ "${BACKEND}" = "claude" ]; then
        claude --model "${CLAUDE_MODEL}" --verbose --print "${prompt}" > "${output}"

    elif [ "${BACKEND}" = "codex" ]; then
        local log_file
        log_file="$(mktemp "${TMPDIR:-/tmp}/codex-summary.XXXXXX.log")"

        if ! codex exec \
            -c tools.web_search=true \
            --cd "$(pwd)" \
            --sandbox workspace-write \
            --output-last-message "${output}" \
            "${prompt}" > "${log_file}" 2>&1; then
            echo "Codex failed. Log: ${log_file}" >&2
            return 1
        fi

	# Check the consumed tokens
        local tokens_used
        tokens_used="$(awk '/^tokens used$/ { getline; print; found=1 } END { exit found ? 0 : 1 }' "${log_file}" || true)"
        if [ -n "${tokens_used}" ]; then
            echo "Codex tokens used: ${tokens_used}"
        fi
        rm -f "${log_file}"

    else
        echo "Unknown backend: ${BACKEND}" >&2
        exit 1
    fi
}

#for CATEGORY in hep-ex quant-ph; do
for CATEGORY in hep-ex; do
    OUTPUT=${CATEGORY}/${DATE}.md
    echo "Fetching ${CATEGORY} with ${BACKEND}..."
    
    PROMPT="
    Please generate a summary of new arXiv papers under the ${CATEGORY} category in Japanese.
    Go through https://arxiv.org/list/${CATEGORY}/new, pick up upto 10 papers to summarize.
    Please reference the format of ${CATEGORY}/example.md in this repo.
    Please arrange them in order of interest.
    I am mostly expert in Neutrino. so feel free to do aggressively for neutrino but more introduction is appreciated for other physics target.
    For hep-ex, focus particularly on novel techniques/ideas, and neutrino experiment.
    Please cosider the information below:
    - I am interested in beyond standard model such as GUT, Drak matter, SUSY, and Majorana neutrino.

    IMPORTANT:
    Do not edit, create, or write any files directly.
    Do not write to ${OUTPUT} yourself.
    Return the final Japanese summary as your final answer only.
    Your final answer must be the markdown content of the summary itself.
    Do not include any completion report.
    Do not say that you generated, saved, wrote, or verified a file.
    Do not mention ${OUTPUT} or any file path."
    
    call_ai "${PROMPT}" "${OUTPUT}"
    echo "Saved: ${OUTPUT}"
done


# Push to git 
git add .
git commit -m "arXiv daily summary ${DATE} [${BACKEND}]"
GIT_SSH_COMMAND="ssh -i /Users/hayashikoki/.ssh/id_github_cron -o IdentitiesOnly=yes -o BatchMode=yes" git push
echo "Done!"
