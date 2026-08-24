#!/usr/bin/env bash
#
# Lint shell scripts in this repository.
#
# Usage:
#   scripts/lint-shell.sh [--all] [--format] [--strict] [file ...]
#
# By default, runs ShellCheck and shell syntax checks on changed shell scripts.
# Use --format to format with shfmt before linting. Use --all for the full tracked
# baseline, or pass files explicitly to lint a smaller set.
set -euo pipefail

usage() {
  # Sliced by SHAPE — every comment or blank line before the first line of
  # code — never by line number. `sed -n '2,9p'` dropped line 10 the moment the
  # header grew past nine lines, and ended --help mid-sentence at "Use --all for
  # the full tracked" with nothing to notice it.
  #
  # `NF == 0` and not `/^[[:space:]]*$/`: a blank line is a record with zero
  # fields under the default FS, which POSIX (awk, DESCRIPTION: "a field is a
  # string of non-<blank> non-<newline> characters") and mawk(1) section 11
  # document in the same terms — so the rule needs no character class at all,
  # and cannot depend on whether a given awk implements them.
  #
  # An earlier version of this comment justified it the other way, claiming mawk
  # does not implement POSIX classes, read out of mawk(1) section 3 listing the
  # metacharacters and naming none. That inference from documentation silence is
  # FALSE: measured on mawk 1.3.4 20260302, `[[:space:]]`, `[[:upper:]]` and
  # `[[:digit:]]` all match. The code was right for a reason that was not.
  awk '
    NR == 1 { next }
    /^#/ { sub(/^# ?/, ""); print; next }
    NF == 0 { print; next }
    { exit }
  ' "$0"
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || die "required tool '$1' is not on PATH"
}

is_shell_file() {
  local path="$1"
  local first_line=""

  [[ -f "$path" ]] || return 1

  case "$path" in
    *.sh)
      return 0
      ;;
  esac

  IFS= read -r first_line <"$path" || true
  [[ "$first_line" =~ ^#!.*[/[:space:]](bash|dash|ksh|sh)([[:space:]]|$) ]]
}

ensure_git_work_tree() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "run this from inside a git work tree, or pass files explicitly"
}

add_shell_file() {
  local path
  local existing

  path="$1"
  if ! is_shell_file "$path"; then
    return 0
  fi

  if [[ "${#files[@]}" -gt 0 ]]; then
    for existing in "${files[@]}"; do
      if [[ "$existing" == "$path" ]]; then
        return 0
      fi
    done
  fi

  files+=("$path")
}

# Reads NUL-delimited paths from `git "$@"` into the file list.
#
# `while … done < <(git …)` looks equivalent and is not: process substitution
# discards git's exit status, and `set -e` never sees it. A failing git closes
# the pipe, the loop reads EOF, collection continues with an empty list, and
# the run ends at "No shell files found." with exit 0 — the gate passes having
# linted nothing, which is the one outcome it must never produce. Measured on
# a repository with a corrupted .git/index: a file carrying a syntax error
# went from exit 1 to exit 0 with no other change.
#
# A temp file keeps the loop out of a subshell, so add_shell_file still
# appends to the caller's array, while git's status stays visible.
add_shell_files_from_git() {
  local listing path

  listing="$(mktemp)" || die "could not create a temporary file"
  if ! git "$@" >"$listing"; then
    rm -f "$listing"
    die "git $* failed — refusing to lint an empty file list"
  fi

  while IFS= read -r -d '' path; do
    add_shell_file "$path"
  done <"$listing"

  rm -f "$listing"
}

collect_all_shell_files() {
  ensure_git_work_tree

  add_shell_files_from_git ls-files -z
}

collect_changed_shell_files() {
  ensure_git_work_tree

  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    add_shell_files_from_git diff --name-only -z --diff-filter=ACMR HEAD
    add_shell_files_from_git diff --cached --name-only -z --diff-filter=ACMR
  else
    collect_all_shell_files
  fi

  add_shell_files_from_git ls-files --others --exclude-standard -z
}

collect_requested_shell_files() {
  local path

  for path in "$@"; do
    add_shell_file "$path"
  done
}

syntax_shell_for() {
  local path="$1"
  local first_line=""

  IFS= read -r first_line <"$path" || true

  case "$first_line" in
    *"/sh"* | *" env sh"* | *"/dash"* | *" env dash"*)
      printf 'sh'
      ;;
    *)
      printf 'bash'
      ;;
  esac
}

run_syntax_checks() {
  local file
  local shell_name

  for file in "$@"; do
    shell_name="$(syntax_shell_for "$file")"
    case "$shell_name" in
      sh)
        sh -n "$file"
        ;;
      bash)
        bash -n "$file"
        ;;
      *)
        die "unsupported shell for syntax check: $shell_name"
        ;;
    esac
  done
}

format=false
strict=false
all=false
requested_files=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      all=true
      ;;
    --format)
      format=true
      ;;
    --strict)
      strict=true
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      requested_files+=("$@")
      break
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      requested_files+=("$1")
      ;;
  esac
  shift
done

require_tool shellcheck
if [[ "$format" == true ]]; then
  require_tool shfmt
fi

files=()
if [[ "${#requested_files[@]}" -gt 0 ]]; then
  collect_requested_shell_files "${requested_files[@]}"
elif [[ "$all" == true ]]; then
  collect_all_shell_files
else
  collect_changed_shell_files
fi

if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No shell files found."
  exit 0
fi

if [[ "$format" == true ]]; then
  echo "Formatting ${#files[@]} shell files"
  shfmt_args=(-i 2 -ci -bn)
  shfmt "${shfmt_args[@]}" -w "${files[@]}"
fi

echo "Linting ${#files[@]} shell files"

shellcheck_args=(--severity=warning --external-sources --source-path=SCRIPTDIR)
if [[ "$strict" == true ]]; then
  shellcheck_args+=("--enable=check-extra-masked-returns,check-set-e-suppressed,quote-safe-variables,deprecate-which,avoid-nullary-conditions")
fi

shellcheck "${shellcheck_args[@]}" "${files[@]}"
run_syntax_checks "${files[@]}"
