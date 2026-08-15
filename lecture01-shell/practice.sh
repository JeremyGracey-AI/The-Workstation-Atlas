#!/usr/bin/env bash
#
# Missing Semester — Lecture 1: the shell
# Runnable practice drills for shell fundamentals and the core text tools.
#
#   ./practice.sh          guided mode: you type each command, it checks your answer
#   ./practice.sh --demo   demo mode: runs every reference command and shows its output
#   ./practice.sh -n 7     run a single drill by number
#   ./practice.sh --help   usage
#
# Everything happens inside a throwaway sandbox directory that is deleted on exit.
# Nothing outside that directory is read or written.

set -uo pipefail

SCRIPT_NAME="$(basename "$0")"
SANDBOX=""
MODE="guided"
ONLY=""

# ----------------------------------------------------------------------------
# output helpers
# ----------------------------------------------------------------------------

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; RED=$'\033[31m'
  YELLOW=$'\033[33m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
else
  BOLD=""; DIM=""; GREEN=""; RED=""; YELLOW=""; CYAN=""; RESET=""
fi

say()   { printf '%s\n' "$*"; }
rule()  { printf '%s\n' "${DIM}------------------------------------------------------------${RESET}"; }
title() { printf '\n%s\n' "${BOLD}$*${RESET}"; }
ok()    { printf '%s\n' "${GREEN}$*${RESET}"; }
bad()   { printf '%s\n' "${RED}$*${RESET}"; }
note()  { printf '%s\n' "${DIM}$*${RESET}"; }
cmd()   { printf '%s\n' "${CYAN}\$ $*${RESET}"; }

usage() {
  cat <<EOF
${BOLD}${SCRIPT_NAME}${RESET} — practice drills for Missing Semester lecture 1 (the shell)

Usage:
  ${SCRIPT_NAME}            guided mode — you type the command, it checks the output
  ${SCRIPT_NAME} --demo     demo mode — run every reference command and show its output
  ${SCRIPT_NAME} -n NUM     run only drill NUM
  ${SCRIPT_NAME} --help     this message

In guided mode, at the prompt you can type:
  hint      show a hint
  answer    reveal the reference command and move on
  skip      move on without revealing
  quit      exit

Answers are graded on ${BOLD}output${RESET}, not on wording — any command that
produces the right result is correct.
EOF
}

# ----------------------------------------------------------------------------
# sandbox
# ----------------------------------------------------------------------------

cleanup() {
  if [ -n "$SANDBOX" ] && [ -d "$SANDBOX" ]; then
    rm -rf "$SANDBOX"
  fi
}
trap cleanup EXIT INT TERM

build_sandbox() {
  SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/missing-semester-l1.XXXXXX")" || {
    bad "Could not create a sandbox directory."; exit 1
  }

  mkdir -p "$SANDBOX/My Photos" "$SANDBOX/data/logs" "$SANDBOX/src/util"

  cat >"$SANDBOX/notes.txt" <<'EOF'
the shell is a textual interface
commands are parsed by whitespace
quote arguments that contain spaces
man pages are the manual
PATH decides what actually runs
EOF

  : >"$SANDBOX/My Photos/beach.jpg"
  : >"$SANDBOX/My Photos/kauai.jpg"

  cat >"$SANDBOX/numbers.txt" <<'EOF'
9
10
2
100
21
EOF

  cat >"$SANDBOX/names.txt" <<'EOF'
grep
awk
grep
sed
grep
awk
find
sed
grep
awk
EOF

  cat >"$SANDBOX/urls.txt" <<'EOF'
http://missing.csail.mit.edu/2020/course-shell/
https://example.com/already-secure
http://example.org/docs
http://localhost:8000/health
EOF

  cat >"$SANDBOX/access.log" <<'EOF'
10.0.0.1 GET /index.html 200 5120
10.0.0.7 GET /style.css 200 2048
10.0.0.1 POST /api/login 401 312
10.0.0.3 GET /index.html 200 5120
10.0.0.1 GET /favicon.ico 404 128
10.0.0.7 GET /api/items 500 96
EOF

  cat >"$SANDBOX/src/main.py" <<'EOF'
def main():
    # TODO: wire up the argument parser
    print("hello")
EOF

  cat >"$SANDBOX/src/util/text.py" <<'EOF'
def slugify(s):
    # TODO: strip punctuation too
    return s.lower().replace(" ", "-")
EOF

  cat >"$SANDBOX/src/README.md" <<'EOF'
# src

Nothing to see here yet.
EOF

  cat >"$SANDBOX/data/logs/app.log" <<'EOF'
INFO  boot complete
ERROR failed to reach cache
INFO  retrying
EOF

  cat >"$SANDBOX/data/logs/error.log" <<'EOF'
ERROR disk full
ERROR disk still full
EOF

  cat >"$SANDBOX/data/logs/old.log" <<'EOF'
INFO  nothing happened
EOF

  cat >"$SANDBOX/data/inventory.csv" <<'EOF'
sku,name,qty
A-1,widget,4
A-2,gizmo,11
EOF
}

show_sandbox() {
  title "Your sandbox"
  note "A temporary directory, deleted when this script exits."
  ( cd "$SANDBOX" && find . | sort | sed 's|^\./||' | grep -v '^\.$' )
  say ""
  note "Every drill runs with this directory as the working directory."
}

# ----------------------------------------------------------------------------
# drills
# ----------------------------------------------------------------------------
# Parallel arrays keep this bash 3.2 compatible, which is what macOS ships.

TOPIC=(); TASK=(); HINT=(); ANSWER=()

add_drill() {
  TOPIC+=("$1"); TASK+=("$2"); HINT+=("$3"); ANSWER+=("$4")
}

add_drill \
  "Composability — pipes" \
  "Count the lines in notes.txt by joining two programs with a pipe." \
  "One program prints the file, the other counts lines: cat ... | wc ..." \
  'cat notes.txt | wc -l'

add_drill \
  "Parsing and quoting" \
  "List what is inside the directory called My Photos. The space is the whole point." \
  'Unquoted, the shell sees two arguments. Try ls "My Photos" or ls My\ Photos' \
  'ls "My Photos"'

add_drill \
  "Reading the manual" \
  "Sort numbers.txt smallest to largest. Plain sort is wrong — it puts 10 before 9." \
  "Run: man sort — and look for the numeric-sort flag." \
  'sort -n numbers.txt'

add_drill \
  "Navigation and relative paths" \
  "From inside the data directory, list ../notes.txt using a relative path." \
  "Chain with &&: cd data && ls <path that goes up one level>" \
  'cd data && ls ../notes.txt'

add_drill \
  "PATH resolution" \
  "Print the full path of the program that actually runs when you type sort." \
  "The command answers the question 'which one of these do I get?'" \
  'which sort'

add_drill \
  "Basics — sort, uniq, head" \
  "Show the three most-used tools in names.txt, most frequent first, with counts." \
  "uniq -c only collapses adjacent lines, so sort first. Then sort again by count (-rn) and take the top 3." \
  'sort names.txt | uniq -c | sort -rn | head -3'

add_drill \
  "grep" \
  "Find every TODO under src, searching subdirectories too. Pipe through sort so the order is stable." \
  "grep needs the recursive flag, then the pattern, then the directory." \
  'grep -r TODO src | sort'

add_drill \
  "sed" \
  "Print urls.txt with every http:// rewritten to https://. Do not modify the file." \
  "s/pattern/replacement/g — but the pattern has slashes in it, so use a different delimiter such as |" \
  'sed "s|http://|https://|g" urls.txt'

add_drill \
  "find" \
  "List every .log file under data, sorted." \
  "find <where> -name <pattern> — quote the pattern so the shell does not expand it first." \
  'find data -name "*.log" | sort'

add_drill \
  "awk" \
  "Print just the status code — the 4th whitespace-separated column — from every line of access.log." \
  "awk '{print \$N}' file, where N is the column number." \
  'awk '\''{print $4}'\'' access.log'

CAPSTONE='awk '\''{print $1}'\'' access.log | sort | uniq -c | sort -rn | head -3'
CAPSTONE_DESC="Top 3 client IPs by request count — five tools, one line, no GUI on earth does this."

# ----------------------------------------------------------------------------
# running and grading
# ----------------------------------------------------------------------------

run_in_sandbox() {
  # Runs a command string in a subshell rooted at the sandbox. stderr is kept
  # so typos are visible; the caller decides what to do with it.
  ( cd "$SANDBOX" && eval "$1" ) 2>&1
}

normalize() {
  # Collapse runs of whitespace and trim, so "  5" and "5" compare equal.
  printf '%s' "$1" | tr -s '[:space:]' ' ' | sed 's/^ //; s/ $//'
}

drill_count() { echo "${#TOPIC[@]}"; }

demo_drill() {
  local i="$1" n expected
  n=$((i + 1))
  title "Drill ${n}/$(drill_count) — ${TOPIC[$i]}"
  say "${TASK[$i]}"
  say ""
  cmd "${ANSWER[$i]}"
  expected="$(run_in_sandbox "${ANSWER[$i]}")"
  if [ -n "$expected" ]; then
    printf '%s\n' "$expected"
  else
    note "(no output)"
  fi
}

guided_drill() {
  local i="$1" n expected reply got tries=0
  n=$((i + 1))
  expected="$(run_in_sandbox "${ANSWER[$i]}")"

  title "Drill ${n}/$(drill_count) — ${TOPIC[$i]}"
  say "${TASK[$i]}"

  while true; do
    printf '\n%s' "${BOLD}\$${RESET} "
    if ! IFS= read -r reply; then
      say ""
      note "Input closed — stopping here."
      return 1
    fi

    case "$reply" in
      "")
        bad "Type a command first."
        continue
        ;;
      hint)
        note "Hint: ${HINT[$i]}"
        continue
        ;;
      answer)
        say "${YELLOW}Reference answer:${RESET}"
        cmd "${ANSWER[$i]}"
        printf '%s\n' "$expected"
        return 0
        ;;
      skip)
        note "Skipped."
        return 0
        ;;
      quit|exit)
        return 1
        ;;
    esac

    got="$(run_in_sandbox "$reply")"

    if [ "$(normalize "$got")" = "$(normalize "$expected")" ]; then
      printf '%s\n' "$got"
      ok "Correct."
      if [ "$reply" != "${ANSWER[$i]}" ]; then
        note "Reference answer was: ${ANSWER[$i]}"
      fi
      return 0
    fi

    tries=$((tries + 1))
    if [ -n "$got" ]; then
      printf '%s\n' "$got"
    else
      note "(no output)"
    fi
    bad "Not the expected output."
    if [ "$tries" -ge 2 ]; then
      note "Hint: ${HINT[$i]}"
      note "Type 'answer' to reveal it, or 'skip' to move on."
    else
      note "Type 'hint' for a nudge."
    fi
  done
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --demo) MODE="demo"; shift ;;
    -n) ONLY="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) bad "Unknown option: $1"; say ""; usage; exit 2 ;;
  esac
done

build_sandbox

total="$(drill_count)"

if [ -n "$ONLY" ]; then
  case "$ONLY" in
    ''|*[!0-9]*) bad "-n needs a number between 1 and $total."; exit 2 ;;
  esac
  if [ "$ONLY" -lt 1 ] || [ "$ONLY" -gt "$total" ]; then
    bad "-n needs a number between 1 and $total."
    exit 2
  fi
fi

title "Missing Semester — lecture 1: the shell"
note "Mode: $MODE   Drills: $total"
show_sandbox

if [ "$MODE" = "guided" ]; then
  say ""
  rule
  note "Type the command that does what each drill asks, then press enter."
  note "Commands run inside the sandbox. 'hint', 'answer', 'skip', 'quit' also work."
  rule
fi

i=0
while [ "$i" -lt "$total" ]; do
  if [ -n "$ONLY" ] && [ "$i" -ne $((ONLY - 1)) ]; then
    i=$((i + 1))
    continue
  fi
  if [ "$MODE" = "demo" ]; then
    demo_drill "$i"
  else
    if ! guided_drill "$i"; then
      say ""
      note "Stopped at drill $((i + 1))."
      exit 0
    fi
  fi
  i=$((i + 1))
done

if [ -z "$ONLY" ]; then
  title "Capstone"
  say "$CAPSTONE_DESC"
  say ""
  cmd "$CAPSTONE"
  run_in_sandbox "$CAPSTONE"

  title "Two things that will bite you on macOS"
  note "1. sed -i takes a mandatory argument on BSD sed: sed -i '' 's/a/b/g' file"
  note "   GNU sed (Linux, or gsed from brew install gnu-sed) wants sed -i 's/a/b/g' file"
  note "2. cd is a shell built-in, so 'which cd' finds nothing and a script cannot"
  note "   change your interactive shell's directory. Use 'type cd' to see the difference."
  say ""
  ok "Done. The sandbox is now deleted."
fi
