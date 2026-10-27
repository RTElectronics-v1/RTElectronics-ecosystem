#!/usr/bin/env bash
# install.sh — installs brand-ui-system where the agent can find it, then
# scaffolds a new project and proves it builds.
#
# Usage:
#   bash install.sh <target-dir> [options]
#
# Options:
#   --from <path|git-url>   source of the skill (default: this script's skill root)
#   --scope user|project|both   where to install the skill (default: user)
#                               user    -> $HOME/.agents/skills/brand-ui-system
#                               project -> <target>/.agents/skills/brand-ui-system
#                               both    -> user for discovery, project for reproducibility
#   --agents <list>         comma list: agents,pi,claude,codex,gemini,copilot,all
#                           symlinks the canonical copy into each agent's skills dir
#   --no-scaffold           only install and link; do not create a project
#   --skip-verify           scaffold only, no npm install / build
#   --force                 replace a real directory at a link path
#
# Exit codes: 0 ok, 1 failed step, 2 bad usage.

set -euo pipefail

usage() {
  sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

TARGET=""
FROM=""
SCOPE="user"
AGENTS=""
SCAFFOLD=1
VERIFY=1
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="${2:-}"; shift 2 ;;
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --agents) AGENTS="${2:-}"; shift 2 ;;
    --no-scaffold) SCAFFOLD=0; shift ;;
    --skip-verify) VERIFY=0; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) TARGET="$1"; shift ;;
  esac
done

[ -n "$TARGET" ] || { if [ "$SCAFFOLD" -eq 0 ]; then TARGET="$(pwd)"; else usage; fi; }
case "$SCOPE" in user|project|both) ;; *) echo "bad --scope: $SCOPE" >&2; exit 2 ;; esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# BRAND_HOME exists so the installer can be tested against a fake home.
HOME_DIR="${BRAND_HOME:-$HOME}"
CANONICAL="${BRAND_SKILL_HOME:-$HOME_DIR/.agents/skills}/brand-ui-system"

declare -A AGENT_DIR=(
  [agents]=".agents/skills"
  [pi]=".pi/agent/skills"
  [claude]=".claude/skills"
  [codex]=".codex/skills"
  [gemini]=".gemini/skills"
  [copilot]=".copilot/skills"
)

step() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

# ── 1. resolve the skill source ─────────────────────────────────────────────
step "Resolving the skill"
if [ -n "$FROM" ]; then
  if git ls-remote "$FROM" >/dev/null 2>&1; then
    CLONE_DIR="$(mktemp -d)"
    git clone --depth 1 --quiet "$FROM" "$CLONE_DIR"
    # A repo may host several skills: the skill root can be the repo root or one level down.
    if [ -f "$CLONE_DIR/SKILL.md" ]; then
      SKILL_SRC="$CLONE_DIR"
    elif [ -f "$CLONE_DIR/brand-ui-system/SKILL.md" ]; then
      SKILL_SRC="$CLONE_DIR/brand-ui-system"
    else
      SKILL_SRC="$CLONE_DIR"
    fi
    echo "  cloned $FROM"
  elif [ -d "$FROM" ]; then
    if [ -f "$FROM/SKILL.md" ]; then
      SKILL_SRC="$(cd "$FROM" && pwd)"
    else
      SKILL_SRC="$(cd "$FROM/brand-ui-system" 2>/dev/null && pwd)" || SKILL_SRC="$(cd "$FROM" && pwd)"
    fi
    echo "  using local path $SKILL_SRC"
  else
    echo "  cannot resolve --from: $FROM" >&2
    exit 1
  fi
else
  SKILL_SRC="$SKILL_ROOT"
  echo "  using bundled source $SKILL_SRC"
fi

[ -f "$SKILL_SRC/SKILL.md" ] || { echo "  $SKILL_SRC is not a brand-ui-system skill" >&2; exit 1; }

# ── 2. install where the agent discovers it ─────────────────────────────────
install_to() {
  local dest="$1"
  if [ "$(cd "$(dirname "$dest")" 2>/dev/null && pwd -P)/$(basename "$dest")" = "$(cd "$SKILL_SRC" && pwd -P)" ]; then
    echo "  already at $dest (source), skipped"
    return
  fi
  # A symlink here belongs to the user (dotfiles, another checkout): replace the
  # link, never wipe the directory it points at.
  if [ -L "$dest" ]; then
    rm -f "$dest"
  fi
  mkdir -p "$dest"
  rm -rf "$dest"/*
  cp -R "$SKILL_SRC"/. "$dest"/
  echo "  installed -> $dest"
}

# ── 2b. validate the target before writing anything into it ─────────────────
if [ "$SCAFFOLD" -eq 1 ] && [ -f "$TARGET/package.json" ] && [ "$FORCE" -ne 1 ]; then
  echo "brand-ui-system: $TARGET already has a package.json; re-run with --force to overwrite, or pick another folder" >&2
  exit 1
fi

case "$SCOPE" in
  user)
    step "Installing the skill (user scope, for discovery)"
    install_to "$CANONICAL"
    ;;
  project)
    step "Installing the skill (project scope, for reproducibility)"
    install_to "$TARGET/.agents/skills/brand-ui-system"
    if [ -n "$AGENTS" ]; then
      step "Installing the canonical copy (required by --agents)"
      install_to "$CANONICAL"
    fi
    ;;
  both)
    step "Installing the skill (user scope, for discovery)"
    install_to "$CANONICAL"
    step "Installing the skill (project scope, for reproducibility)"
    install_to "$TARGET/.agents/skills/brand-ui-system"
    ;;
esac

# ── 3. link the canonical copy into every requested agent ───────────────────
if [ -n "$AGENTS" ]; then
  case "$AGENTS" in
    all) AGENT_LIST="agents pi claude codex gemini copilot" ;;
    *) AGENT_LIST="$(printf '%s' "$AGENTS" | tr ',' ' ')" ;;
  esac

  step "Linking into agents: $AGENT_LIST"
  for name in $AGENT_LIST; do
    rel="${AGENT_DIR[$name]:-}"
    if [ -z "$rel" ]; then
      echo "  unknown agent: $name (valid: agents pi claude codex gemini copilot)" >&2
      exit 2
    fi
    dir="$HOME_DIR/$rel"
    link="$dir/brand-ui-system"
    mkdir -p "$dir"

    if [ "$link" = "$CANONICAL" ]; then
      echo "  $name -> canonical, no link needed"
      continue
    fi

    if [ -e "$link" ] && [ ! -L "$link" ]; then
      if [ "$FORCE" -ne 1 ]; then
        echo "  $name -> $link exists and is not a link; skipped (use --force to replace)"
        continue
      fi
    fi
    rm -rf "$link" 2>/dev/null || true

    # MSYS `ln -s` silently COPIES when native symlinks are off, so each attempt
    # must start from a clean path and be verified, not trusted.
    linked=0
    if ln -s "$CANONICAL" "$link" 2>/dev/null && [ -L "$link" ]; then
      echo "  $name -> $link"
      linked=1
    fi
    if [ "$linked" -eq 0 ]; then
      rm -rf "$link" 2>/dev/null || true
      if command -v cygpath >/dev/null 2>&1 && cmd //c mklink //J "$(cygpath -w "$link")" "$(cygpath -w "$CANONICAL")" >/dev/null 2>&1; then
        echo "  $name -> $link (junction)"
        linked=1
      fi
    fi
    if [ "$linked" -eq 0 ]; then
      rm -rf "$link" 2>/dev/null || true
      cp -R "$CANONICAL" "$link"
      echo "  $name -> $link (copied; neither symlink nor junction available)"
    fi
  done
fi

# ── 4. scaffold the project from the installed copy ─────────────────────────
INSTALLED="$TARGET/.agents/skills/brand-ui-system"
[ -d "$INSTALLED" ] || INSTALLED="$CANONICAL"

if [ "$SCAFFOLD" -eq 1 ]; then
  step "Scaffolding $TARGET"
  bash "$INSTALLED/assets/bootstrap/scaffold.sh" "$TARGET"
  cd "$TARGET"
fi

# ── 4. dependencies and gate ────────────────────────────────────────────────
if [ "$SCAFFOLD" -eq 1 ] && [ "$VERIFY" -eq 1 ]; then
  if ! command -v npm >/dev/null 2>&1; then
    step "npm not found"
    echo "  install Node 18.20 / 20.3 / 22+ and run: npm install && npm run verify" >&2
    exit 1
  fi

  step "Installing dependencies"
  npm install --no-audit --no-fund | tail -3

  step "Verifying the scaffold (astro check + build)"
  npm run verify

  step "Brand lint"
  node "$INSTALLED/assets/brand-lint.mjs" src --quiet
fi

# ── 5. handoff ──────────────────────────────────────────────────────────────
cat <<EOF

$(printf '\033[1m✔ ready\033[0m')

Next step, in a new agent session with cwd = $TARGET:

  Read $INSTALLED/SKILL.md and follow its contract.
  Build <your feature>.

The skill is discoverable globally at:
  $CANONICAL/SKILL.md
EOF
