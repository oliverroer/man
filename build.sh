#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
RAW_DIR="$SCRIPT_DIR/raw"
DOCS_DIR="$SCRIPT_DIR/docs"
MAN_DIR="$DOCS_DIR/man"
STYLES_DIR="$SCRIPT_DIR/styles"

mkdir -p "$DOCS_DIR"

exportraw() {
  docker run --volume "$SCRIPT_DIR":/work --rm -it ubuntu bash /work/export.sh
}

font_geist() {
  echo '<link rel="preconnect" href="https://fonts.googleapis.com">'
  echo '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
  echo '<link href="https://fonts.googleapis.com/css2?family=Geist:wght@100..900&display=swap" rel="stylesheet">'
}

font_geist_mono() {
  echo '<link rel="preconnect" href="https://fonts.googleapis.com">'
  echo '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
  echo '<link href="https://fonts.googleapis.com/css2?family=Geist+Mono:wght@100..900&family=Geist:wght@100..900&display=swap" rel="stylesheet">'
}

font_fira_mono() {
  echo '<link rel="preconnect" href="https://fonts.googleapis.com">'
  echo '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="">'
  echo '<link href="https://fonts.googleapis.com/css2?family=Fira+Mono:wght@400;500;700&amp;display=swap" rel="stylesheet">'
}

htmlhead() {
  local TITLE="$1"

  echo '<html lang="en-US">'  
  echo '<head>'
  echo '<meta charset="utf-8" />'
  echo '<meta name="viewport" content="width=device-width,initial-scale=1" />'
  echo "<title>${TITLE}</title>"
  font_geist
  font_geist_mono
  font_fira_mono
  echo '<link href="/man/index.css" rel="stylesheet" />'
  echo '</head>'
  
  echo '<body style="overscroll-behavior-x: auto">'
  echo '<main>'
}

htmlfoot() {
  echo '</main>'
  echo '</body>'
  echo '</html>'
}

genhtml() {
  local SOURCE="$1"
  local SECTION="$2"
  local NAME="$3"

  htmlhead "${NAME} (${SECTION})"
  mandoc -Thtml -O fragment "$SOURCE"
  htmlfoot
}

parsename() {
  local SOURCE="$1"

  SECTION_FILE="${SOURCE##*raw/man}"

  SECTION="${SECTION_FILE%%/*}"
  FILE="${SECTION_FILE#*/}"
  UNTYPED_NAME="${FILE%.gz}"
  NAME="${UNTYPED_NAME%%.*}"
  
  echo "$SECTION $NAME"
}

postprocess() {
  rm -rf "$MAN_DIR"
  mkdir -p "$MAN_DIR"

  find "$RAW_DIR" -type f -name "*.gz" | while read -r SOURCE; do
    while read -r SECTION NAME; do
      echo "Processing $NAME ($SECTION)..."
      mkdir -p "$MAN_DIR/$SECTION"
      genhtml "$SOURCE" "$SECTION" "$NAME" > "$MAN_DIR/$SECTION/$NAME.html"
    done <<< "$(parsename "$SOURCE")"
  done
}

index_section() {
  local SECTION="$1"
  local TITLE="$2"

  local SECTION_DIR="$MAN_DIR/$SECTION"

  echo '<details>'
  echo "<summary>[$SECTION] $TITLE</summary>"
  echo "<ul>"

  find "$SECTION_DIR" -type f -name "*.html" | sort -u | while read -r FILE; do
    BASE_NAME="${FILE##*/}"
    NAME="${BASE_NAME%.html}"
    printf '<li><a href="/man/man/%s/%s">%s</a></li>' "$SECTION" "$BASE_NAME" "$NAME"
  done

  echo '</ul>'
  echo '</details>'
}

index() {
  htmlhead "MAN"

  index_section "1" "User Commands"
  index_section "2" "System Calls"
  index_section "3" "Library Functions"
  index_section "4" "Special Files"
  index_section "5" "File Formats"
  index_section "6" "Games"
  index_section "7" "Miscellaneous"
  index_section "8" "System Administration Commands"
  
  htmlfoot
}

css() {
  cat \
    "$STYLES_DIR/reset.css" \
    "$STYLES_DIR/style.css" \
    > "$DOCS_DIR/index.css"
}


#exportraw
#postprocess
css
index > "$DOCS_DIR/index.html"
