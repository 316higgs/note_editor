#!/usr/bin/env bash
set -euo pipefail

ARTICLE_DIR="articles/drafting/article_006"
ARTICLE_FILE="01_初版.docx"
REVISION=1
REVISION_SUFFIX="$(printf "v%02d" "$REVISION")"

# 出力モード: "gpt"（全文埋め込み）または "claude"（slim版）
# 使い方:
#   bash run/prepare_revision_prompt.sh          # gptモード（デフォルト）
#   MODE=claude bash run/prepare_revision_prompt.sh  # claudeモード
# MODE="${MODE:-gpt}"
MODE="claude"

if [ "$MODE" = "claude" ]; then
  OUTPUT="$ARTICLE_DIR/claude_revision_prompt_${REVISION_SUFFIX}.md"
else
  OUTPUT="$ARTICLE_DIR/gpt_revision_prompt_${REVISION_SUFFIX}.md"
fi

python scripts/prepare_revision_prompt.py \
  --article "$ARTICLE_DIR/$ARTICLE_FILE" \
  --policy datasets/editorial_rules/editorial_policy.md \
  --author personas/author/author_character.md \
  --reader personas/reader/persona_character.md \
  --revision-round "$REVISION" \
  --mode "$MODE" \
  --output "$OUTPUT"

# Claude Codeモードの場合のみ校正まで実行
if [ "$MODE" = "claude" ]; then
  RESULT_FILE="$ARTICLE_DIR/$(printf "%02d" "$REVISION")_${REVISION}次校正_claude.md"
  claude "$(cat "$OUTPUT")" > "$RESULT_FILE"
  echo "[OK] 校正完了: $RESULT_FILE"
fi