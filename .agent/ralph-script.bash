#!/bin/bash

while true; do
  codex exec "
  Execute next TODO story in docs/expeditions/execution.md.
  Stop after one story.
  Commit when complete.
  "

  if ! grep -q "status: todo" docs/expeditions/execution.md; then
    echo "All stories complete."
    break
  fi
done