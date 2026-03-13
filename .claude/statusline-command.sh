#!/bin/sh
# Claude Code status line - two-line layout with model, git branch, and context bar
# Dieses file muss in <homedir>/.claude/ liegen. Dann sagt man claude einfach mit /statusline, dass man es verwenden will.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")
model_id=$(echo "$input" | jq -r '.model.id // .model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# ANSI colors (use printf to ensure escape sequences are interpreted by /bin/sh)
GREEN=$(printf '\033[0;32m')
CYAN=$(printf '\033[0;36m')
YELLOW=$(printf '\033[0;33m')
DIM=$(printf '\033[2m')
RESET=$(printf '\033[0m')

# Extract short model name (Opus, Sonnet, Haiku, etc.) from model ID
model_short=""
if [ -n "$model_id" ]; then
  case "$model_id" in
    *[Oo]pus*)   model_short="Opus" ;;
    *[Ss]onnet*) model_short="Sonnet" ;;
    *[Hh]aiku*)  model_short="Haiku" ;;
    *)
      # Fallback: use display name or raw id, capitalize first letter
      model_short=$(echo "$model_id" | sed 's/.*\///' | awk '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}; print}')
      ;;
  esac
fi

# ANSI red for git dirty indicator
RED=$(printf '\033[0;31m')

# Git branch and dirty status (skip optional locks to avoid conflicts)
git_branch=""
git_dirty=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_branch="$branch"
  fi
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  if [ -n "$porcelain" ]; then
    git_dirty="${RED}✗${RESET}"
  else
    git_dirty="${GREEN}✓${RESET}"
  fi
fi

# --- Line 1: [Model]  📁  dir  |  🌿  branch ---
line1=""
if [ -n "$model_short" ]; then
  line1="${CYAN}[${model_short}]${RESET}"
fi
line1="${line1}  📁  ${dir}"
if [ -n "$git_branch" ]; then
  line1="${line1}  ${DIM}|${RESET}  🌿  ${git_branch}  ${git_dirty}"
fi

# --- Line 2: progress bar  pct% ---

# Progress bar (12 chars wide)
bar=""
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  bar_width=12
  filled=$(( used_int * bar_width / 100 ))
  empty=$(( bar_width - filled ))
  filled_bar=""
  i=0
  while [ $i -lt $filled ]; do
    filled_bar="${filled_bar}█"
    i=$(( i + 1 ))
  done
  empty_bar=""
  i=0
  while [ $i -lt $empty ]; do
    empty_bar="${empty_bar}░"
    i=$(( i + 1 ))
  done
  # Threshold-based bar color: green < 70%, yellow 70-89%, red 90%+
  if [ "$used_int" -ge 90 ]; then
    bar_color="$RED"
  elif [ "$used_int" -ge 70 ]; then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi
  bar="${bar_color}${filled_bar}${RESET}${DIM}${empty_bar}${RESET}  ${used_int}%"
fi

# Format cost as $0.08
cost_str=""
if [ -n "$cost_usd" ]; then
  cost_formatted=$(printf "%.2f" "$cost_usd")
  cost_str="${YELLOW}\$${cost_formatted}${RESET}"
fi

# Format duration as Xm Ys
duration_str=""
if [ -n "$duration_ms" ]; then
  duration_s=$(( ${duration_ms%.*} / 1000 ))
  dur_min=$(( duration_s / 60 ))
  dur_sec=$(( duration_s % 60 ))
  duration_str="${DIM}⏱ ${dur_min}m ${dur_sec}s${RESET}"
fi

# Assemble line 2
line2=""
if [ -n "$bar" ]; then
  line2="${bar}"
fi
if [ -n "$cost_str" ]; then
  line2="${line2}  ${DIM}|${RESET}  ${cost_str}"
fi
if [ -n "$duration_str" ]; then
  line2="${line2}  ${DIM}|${RESET}  ${duration_str}"
fi

printf "%s\n" "$line1"
if [ -n "$line2" ]; then
  printf "%s\n" "$line2"
fi
