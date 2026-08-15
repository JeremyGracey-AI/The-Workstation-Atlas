# The Workstation Atlas

Working atlas for [MIT's *Missing Semester of Your CS Education*](https://missing.csail.mit.edu/) —
nine lectures cross-referenced against one machine. Grows with the course.

Every blue callout in the atlas is a fact verified on the machine (2026-08-13), not generic
advice. Each page pairs the lecture's concept flow with *on your machine* cross-references and
ends by probing the flow.

## What's here

| Path | What it is |
|---|---|
| [`lecture01-shell/`](lecture01-shell/) | Lecture 1 shell drills as a runnable script — ten graded exercises in a throwaway sandbox, plus a `--demo` mode. |
| [`atlas/`](atlas/) | The atlas itself — an 11-page HTML document, print-laid-out at 11×8.5in. Open it in a browser; print to PDF for the paper copy. **This is the editable master.** |
| [`notebooks/01_python_fundamentals.ipynb`](notebooks/01_python_fundamentals.ipynb) | Ten sections of Python drilling — containers, comprehensions, generators, closures, decorators, context managers, dataclasses, exceptions, `pathlib`, imports. Demo → exercise → auto-graded check. |
| [`notebooks/02_atlas_probes.ipynb`](notebooks/02_atlas_probes.ipynb) | Each atlas page's *"Probe the flow"* question, turned into runnable Python that answers it against this machine. |

## Quickstart

```bash
uv sync                                   # creates .venv (Python 3.14) and installs tooling
uv run python -m ipykernel install --user \
    --name workstation-atlas \
    --display-name "Python 3.14 (workstation-atlas)"
uv run nbstripout --install --attributes .gitattributes   # see "Notebook outputs" below
```

Then open either notebook in Cursor or VS Code. `.vscode/settings.json` points the Python
extension at `.venv`, so the kernel should be pre-selected; if not, pick
**Python 3.14 (workstation-atlas)**.

## The two notebooks

**`01_python_fundamentals.ipynb` — practice.** Each section is three cells: a demo you read and
run, an exercise stubbed with `raise NotImplementedError`, and a check cell that grades it. The
checks *print* ✅ / ❌ / ⬜ rather than asserting, so the notebook runs top to bottom at any stage
of completion. `scoreboard()` at the end tallies the session.

**`02_atlas_probes.ipynb` — investigation.** The atlas asserts things about this desk; this
notebook checks them against the filesystem. Which `$PATH` rung wins a name collision. Whether a
polling shell function reports failure or silently returns 0. How many commit objects a rebase
creates, and what happens to the originals. Which lockfiles are actually committed. Which repos
skip a layer of the quality funnel, and what class of bug that admits.

Everything in `02` is read-only — no writes outside a scratch directory in `/tmp`, no network,
no destructive git. Helpers degrade gracefully when a tool is missing.

## Notebook outputs

**This repo is public**, and `02` prints details about the machine it runs on. Outputs are
therefore scrubbed on the way into git by an [`nbstripout`](https://github.com/kynan/nbstripout)
clean filter, wired through [`.gitattributes`](.gitattributes):

```
*.ipynb filter=nbstripout
```

The filter config lives in `.git/config`, which is per-clone and not committed — so **a fresh
clone must run `uv run nbstripout --install --attributes .gitattributes` before its first
commit.** Verify it is working:

```bash
git add notebooks/
for nb in notebooks/*.ipynb; do
  echo "$nb: $(git show ":$nb" | grep -c '"output_type"') output blobs"   # expect 0
done
```

Check the staged *blob*, not `git diff --cached` — a plain diff also matches this README, which
quotes the string, and will mislead you into thinking outputs leaked.

Markdown cells are untouched, so written answers in the *Your answer* cells are preserved.

## Layout notes

This repo lives at `~/src/github.com/JeremyGracey-AI/The-Workstation-Atlas`, matching the
`<org>/<repo>` clone-root convention documented on the atlas's own Master Map page. It was moved
there on 2026-08-15; `~/src/MOVELOG.md` records the move, and the old path is a compatibility
symlink. `~/Downloads/missing-semester-workstation-atlas.html` is likewise now a symlink into
`atlas/`, so there is exactly one master and no drift.

## Requirements

- [uv](https://docs.astral.sh/uv/) 0.9.17+ — Python 3.14 is fetched automatically if missing
- git 2.23+ (the probes use `git fsck --no-reflogs` and `cat-file --batch-all-objects`)

`pyproject.toml` sets `[tool.uv] exclude-newer = "7 days"`, a dependency cooldown: a freshly
published release is the cheapest supply-chain attack surface there is, so the resolver ignores
anything newer than a week. The trade-off is deliberate — `uv sync` will sometimes pick a slightly
older version than the registry's latest. Remove the line if you ever need a same-day release.

Source: [missing.csail.mit.edu/2026](https://missing.csail.mit.edu/2026)
