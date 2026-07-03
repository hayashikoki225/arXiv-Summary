# How to set up an auto feeder
Validaded with macOS Sequoia 15.6.

### Prerequisite
**Claude code CLI** or **ChatGPT Codex CLI** installed in your local machine
- Claude code: `curl -fsSL https://claude.ai/install.sh | bash`, then launch and authenticate.
- ChatGPT Codex: `curl -fsSL https://chatgpt.com/codex/install.sh | bash`, then launch and authenticate.

### Step1. Prepare a prompt script and example
- Specify the backend and model to use ([summarize.sh](./summarize.sh))
- Customize the PROMPT to fit to your interests, detailness, expertise etc. ([summarize.sh](./summarize.sh))
- Edit the example files for format preference: [hep-ex,quant-ph]/example.md  
  You may also just describe in the PROMPT).

### Step2: Set up a crontab
e.g. Run 9pm everyday, output stdout/stderr only for the latest update:
```
crontab -e
0 21 * * * ABSPATH_TO_REPO/summarize.sh > SOMEWHERE/summarize.log 2>&1
```
Change `ABSPATH_TO_REPO` and `SOMEWHERE` to something appropriate.
