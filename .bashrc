# --- directory bookmarks ---
BOOKMARK_FILE="$HOME/.dir_bookmarks"

bookmark() {
  local path title exists dest tmpfile found
  [[ -f "$BOOKMARK_FILE" ]] || touch "$BOOKMARK_FILE"

  # list bookmarks
  if [[ "$1" == "ls" ]]; then
    local titles=()
    while IFS='|' read -r t d; do
      [[ -n "$t" ]] && titles+=("$t")
    done < "$BOOKMARK_FILE"
    # print each title on its own line
    [[ ${#titles[@]} -gt 0 ]] && printf '%s\n' "${titles[@]}"
    return
  fi

  # remove bookmark
  if [[ "$1" == "rm" ]]; then
    local name="$2"
    if [[ -z "$name" ]]; then
      echo "[ERROR] - missing bookmark name"
      return 1
    fi

    found=0
    tmpfile="$(mktemp)"
    while IFS='|' read -r t d; do
      if [[ "$t" == "$name" ]]; then
        found=1
        continue
      fi
      [[ -n "$t" ]] && printf '%s|%s\n' "$t" "$d" >> "$tmpfile"
    done < "$BOOKMARK_FILE"
    mv "$tmpfile" "$BOOKMARK_FILE"

    if (( found )); then
      echo "[SUCCESS] - $name removed"
    else
      echo "[ERROR] - $name doesn't exist"
      return 1
    fi
    return
  fi

  # no arg = bookmark current directory
  if [[ -z "$1" ]]; then
    path="$PWD"
  else
    path="$1"
  fi

  # if arg is an existing directory -> create bookmark for that directory
  if [[ -d "$path" ]]; then
    # Use builtin cd in a subshell so we don't capture any custom cd/ls output
    path="$(
      builtin cd -- "$path" 2>/dev/null || exit 1
      pwd
    )" || {
      echo "[ERROR] - could not resolve directory: $path"
      return 1
    }

    while :; do
      printf "[Bookmark Title]: "
      read -r title

      # spaces not allowed
      if [[ "$title" == *" "* ]]; then
        echo "[ERROR] - bookmark $title has spaces"
        continue
      fi

      # empty -> just reprompt
      [[ -z "$title" ]] && continue

      # check if title already exists
      exists=0
      while IFS='|' read -r t d; do
        if [[ "$t" == "$title" ]]; then
          exists=1
          break
        fi
      done < "$BOOKMARK_FILE"

      if (( exists )); then
        echo "[ERROR] - bookmark $title already exists"
        continue
      fi

      printf '%s|%s\n' "$title" "$path" >> "$BOOKMARK_FILE"
      echo "[SUCCESS] - bookmark $title has been created"
      break
    done
    return
  fi

  # otherwise: treat arg as bookmark title to jump to
  title="$1"
  dest=""
  while IFS='|' read -r t d; do
    if [[ "$t" == "$title" ]]; then
      dest="$d"
      break
    fi
  done < "$BOOKMARK_FILE"

  if [[ -z "$dest" ]]; then
    echo "[ERROR] - $title doesn't exist"
    return 1
  fi

  cd "$dest" || {
    echo "[ERROR] - failed to cd into $dest"
    return 1
  }
}

alias bm=bookmark
