#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
DOCS_DIR="$SCRIPT_DIR/../../docs"

classes() {
  find "$DOCS_DIR" -name "*.html" | while read -r FILE; do
    cat $FILE | grep 'class="' | while read -r LINE; do
      # Remove everything up to and including 'class="'
      CLASSES="${LINE#*class=\"}"
      # Remove everything from the first closing quote onwards
      CLASSES="${CLASSES%%\"*}"

      for CLASS in $CLASSES; do
        echo "$CLASS"
      done
    done
  done
}

classes | sort -u > "$SCRIPT_DIR/classes.txt"
