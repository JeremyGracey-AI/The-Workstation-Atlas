# Lecture 1 — The shell

Runnable practice for [lecture 1: the shell](https://missing.csail.mit.edu/2020/course-shell/).

`practice.sh` builds a throwaway sandbox of files, walks you through ten drills, and grades
you on the **output** your command produces — not on how you wrote it. Any command that
produces the right result is accepted. The sandbox is deleted when the script exits, and
nothing outside it is read or written.

## Run it

```bash
cd lecture01-shell
./practice.sh          # guided: you type each command, it checks your answer
./practice.sh --demo   # demo: runs every reference command and shows its output
./practice.sh -n 7     # just drill 7
./practice.sh --help   # usage
```

At the guided prompt: `hint`, `answer`, `skip`, `quit`.

Set `NO_COLOR=1` to strip ANSI colors (useful when piping to a file).

## What the drills cover

| # | Topic | Idea being drilled |
|---|---|---|
| 1 | Composability | Pipes let you combine programs no single GUI app can combine |
| 2 | Parsing and quoting | The shell splits on whitespace; quote or escape args with spaces |
| 3 | Reading the manual | `man` and `--help` are how you learn any command |
| 4 | Navigation | `cd`, `pwd`, absolute vs relative, `.` and `..` |
| 5 | PATH resolution | The shell searches `$PATH`; `which` shows what actually runs |
| 6 | sort, uniq, head | `uniq -c` only collapses *adjacent* lines — sort first |
| 7 | grep | Regex search, `-r` to walk directories |
| 8 | sed | Programmatic find-and-replace with `s///g` |
| 9 | find | Locate by name, type, age, size |
| 10 | awk | Column extraction from structured text |

Then a capstone that chains five of them into one line: the top 3 client IPs in a log file.

## Two macOS gotchas the script calls out

**BSD `sed -i` needs an argument.** On macOS:

```bash
sed -i '' 's/old/new/g' file.txt    # BSD sed — the '' is the backup suffix
sed -i 's/old/new/g' file.txt       # GNU sed (Linux, or gsed after: brew install gnu-sed)
```

Write the GNU form on a Mac and you get a cryptic "invalid command code" or, worse, a
file named after your substitution.

**`cd` is a shell built-in, not a program.** `which cd` finds nothing. A script can't
change your interactive shell's working directory — it runs in a child process that exits.
`type cd` tells you what kind of thing a name refers to; `which` only looks at `$PATH`.

## Compatibility

Written for bash 3.2, which is what macOS still ships as `/bin/bash`. No associative
arrays, no `mapfile`, no GNU-only flags in the reference answers.
