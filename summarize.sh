#!/bin/bash
set -euo pipefail  # Force stop in case of errors

DATE=$(date +%Y-%m-%d)

MODEL="claude-opus-4-6"
#MODEL="claude-sonnet-4-6"

# Loop over sub-directories (e.g. hep-ex, quant-ph)
for CATEGORY in hep-ex quant-ph; do
    OUTPUT=${CATEGORY}/${DATE}.md    

    echo "Fetching ${CATEGORY}..."
    claude --model ${MODEL} --verbose --print "
Please generate a summary of new arXiv papers under the ${CATEGORY} category in Japanese. 
Go through https://arxiv.org/list/${CATEGORY}/new, pick up upto 10 papers to summarize.
Please reference the format of ${CATEGORY}/example.md in this repo.

I am mostly expert in LHC/SUSY/dark matter etc. so feel free to do aggressively for hep-ex but more introduction is appreciated for other categories.
For quant-ph, I'm particularly interested in the hardware development and sensing application.
" > "${OUTPUT}"
    
    echo "Saved: ${OUTPUT}"
done

# git push
git add .
git commit -m "arXiv daily summary ${DATE}"
git push

echo "Done!"
