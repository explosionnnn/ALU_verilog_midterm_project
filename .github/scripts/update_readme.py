#!/usr/bin/env python3
"""Auto-update README.md based on the latest commit using an LLM.

Priority for the LLM backend:
  1. OpenAI API  — if OPENAI_API_KEY is set in the environment.
  2. GitHub Models API — otherwise, uses GH_TOKEN / GITHUB_TOKEN with the
     Azure-hosted inference endpoint that GitHub provides to Actions runners.
"""

import os
import subprocess
import sys


# ---------------------------------------------------------------------------
# Git helpers
# ---------------------------------------------------------------------------

MAX_DIFF_LENGTH = 600
MIN_README_LENGTH = 100


def _git(*args: str) -> str:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"WARNING: git {' '.join(args)} exited {result.returncode}: {result.stderr.strip()}")
    return result.stdout.strip()


def get_commit_info() -> tuple[str, str, str, str]:
    sha = os.environ.get("COMMIT_SHA") or _git("rev-parse", "HEAD")
    message = os.environ.get("COMMIT_MESSAGE") or _git("log", "-1", "--pretty=%s")
    author = os.environ.get("PUSHER_NAME") or _git("log", "-1", "--pretty=%an")
    date = _git("log", "-1", "--pretty=%ci")
    return sha, message, author, date


def get_diff_stat() -> str:
    # Handle the very first commit (no parent)
    parent = _git("rev-parse", "--verify", "HEAD~1")
    if not parent:
        return _git("diff", "--stat", "--cached")
    return _git("diff", "HEAD~1", "HEAD", "--stat")


def get_changed_filenames() -> list[str]:
    parent = _git("rev-parse", "--verify", "HEAD~1")
    if not parent:
        return []
    output = _git("diff", "HEAD~1", "HEAD", "--name-only")
    return [f for f in output.splitlines() if f]


def get_file_diff(filepath: str) -> str:
    parent = _git("rev-parse", "--verify", "HEAD~1")
    if not parent:
        return ""
    return _git("diff", "HEAD~1", "HEAD", "--", filepath)


# ---------------------------------------------------------------------------
# File helpers
# ---------------------------------------------------------------------------

def read_file(path: str) -> str:
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    return ""


def write_file(path: str, content: str) -> None:
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(content)


def strip_code_fence(text: str) -> str:
    """Remove markdown code fences that the LLM might wrap around its output."""
    text = text.strip()
    for prefix in ("```markdown", "```md", "```"):
        if text.startswith(prefix):
            text = text[len(prefix):].lstrip("\n")
            break
    if text.endswith("```"):
        text = text[:-3].rstrip()
    return text


# ---------------------------------------------------------------------------
# LLM client
# ---------------------------------------------------------------------------

def build_client():
    """Return an OpenAI-compatible client, preferring OPENAI_API_KEY over GH_TOKEN."""
    from openai import OpenAI  # imported here so missing package gives a clear error

    openai_key = os.environ.get("OPENAI_API_KEY")
    if openai_key:
        print("Using OpenAI API (OPENAI_API_KEY found).")
        return OpenAI(api_key=openai_key), "gpt-4o-mini"

    gh_token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if gh_token:
        print("Using GitHub Models API (GH_TOKEN).")
        return OpenAI(
            base_url="https://models.inference.ai.azure.com",
            api_key=gh_token,
        ), "gpt-4o-mini"

    print("ERROR: No API key found. Set OPENAI_API_KEY, or ensure GH_TOKEN / GITHUB_TOKEN is available.",
          file=sys.stderr)
    sys.exit(1)


def call_llm(client, model: str, prompt: str) -> str:
    response = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=4096,
        temperature=0.3,
    )
    return response.choices[0].message.content.strip()


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

def build_prompt(sha: str, message: str, author: str, date: str,
                 diff_stat: str, changed_files: list[str],
                 diffs_text: str, current_readme: str) -> str:
    sha_short = sha[:8]
    date_short = date[:10] if date else "unknown"

    return f"""You are a technical documentation bot for a Verilog ALU project on GitHub.

Your job: update the project's README.md to reflect the latest commit, then return
the COMPLETE updated README.md — nothing else (no explanation, no code fences).

---
CURRENT README:
{current_readme}

---
LATEST COMMIT:
- SHA:     {sha_short}
- Date:    {date_short}
- Author:  {author}
- Message: {message}

FILES CHANGED:
{diff_stat}

CODE DIFFS (first 600 chars per file):
{diffs_text}

---
RULES:
1. Add a new entry at the TOP of the "## Changelog" section using this exact format:
   ### [{date_short}] — {message} (`{sha_short}`)
   - <one or more bullet points describing what changed>

2. If new RTL functionality was introduced (new operations, modules, or significant
   behavioural changes), update the "## Features" section accordingly.

3. If only documentation, test, or CI files changed, only add the Changelog entry.

4. Never remove any existing content.

5. Return ONLY the full, updated README.md text — no preamble, no code fences.
"""


def main() -> None:
    sha, message, author, date = get_commit_info()
    print(f"Processing commit {sha[:8]}: {message}")

    diff_stat = get_diff_stat()
    changed_files = get_changed_filenames()

    # Build per-file diffs for non-README source files
    diffs = []
    for f in changed_files:
        if f == "README.md":
            continue
        diff = get_file_diff(f)
        if diff:
            diffs.append(f"### {f}\n{diff[:MAX_DIFF_LENGTH]}")

    diffs_text = "\n\n".join(diffs) if diffs else "(no code changes)"
    current_readme = read_file("README.md")

    prompt = build_prompt(sha, message, author, date,
                          diff_stat, changed_files, diffs_text, current_readme)

    client, model = build_client()

    print("Calling LLM…")
    try:
        new_readme = call_llm(client, model, prompt)
    except Exception as exc:
        print(f"ERROR: LLM call failed: {exc}", file=sys.stderr)
        sys.exit(1)

    new_readme = strip_code_fence(new_readme)

    if len(new_readme) < MIN_README_LENGTH:
        print("WARNING: LLM response suspiciously short — aborting README update.")
        sys.exit(0)

    write_file("README.md", new_readme + "\n")
    print("README.md updated successfully.")


if __name__ == "__main__":
    main()
