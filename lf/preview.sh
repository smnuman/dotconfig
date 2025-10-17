#!/usr/bin/env bash
# Simple file preview for lf
case "$1" in
  *.tar|*.gz|*.zip|*.rar) tar tvf "$1" 2>/dev/null || unzip -l "$1" ;;
  *.jpg|*.png|*.gif|*.webp) chafa "$1" --format=symbols ;;
  *) bat --style=plain --color=always "$1" 2>/dev/null || head "$1" ;;
esac
