#!/bin/sh
# 重新生成中文衬线子集字体。内容有增改后运行。
# 依赖：pip install fonttools brotli
set -e
SRC_R="${1:-/tmp/NotoSerifSC-Regular.otf}"
SRC_B="${2:-/tmp/NotoSerifSC-Bold.otf}"
[ -f "$SRC_R" ] || curl -sSL -o "$SRC_R" https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-Regular.otf
[ -f "$SRC_B" ] || curl -sSL -o "$SRC_B" https://github.com/notofonts/noto-cjk/raw/main/Serif/SubsetOTF/SC/NotoSerifSC-Bold.otf
python3 - <<'PY' > /tmp/_subset.txt
import re
S=''.join(open(f,encoding='utf-8').read() for f in
          ['academic.html','data.js','sections.js','index.html','README.md'])
c=set(re.findall(r'[㐀-鿿]',S))
c|=set('　、。〃〈〉《》「」『』【】〔〕！＂＃＄％＆＇（）＊＋，－．／：；＜＝＞？＠［＼］＾＿｀｛｜｝～“”‘’—…·￥')
c|=set(chr(i) for i in range(0x20,0x7f))
c|=set('àáâãäåæçèéêëìíîïñòóôõöøùúûüýÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔÕÖØÙÚÛÜÝŸšŠžŽœŒßđĐłŁ')
c|=set('←→↑↓✕✓·•–—‰°±×÷≈≠≤≥§¶©®™†‡′″‹›«»')
c-={'\n','\r','\t'}
print(''.join(sorted(c)),end='')
PY
mkdir -p fonts
for pair in "$SRC_R:Regular" "$SRC_B:Bold"; do
  pyftsubset "${pair%%:*}" --text-file=/tmp/_subset.txt \
    --output-file="fonts/NotoSerifSC-${pair##*:}.subset.woff2" --flavor=woff2 \
    --layout-features="kern,liga,vert,vrt2,locl,ccmp" --no-hinting --desubroutinize \
    --name-IDs="1,2,3,4,6" --name-legacy --notdef-outline --recommended-glyphs
  echo "  ${pair##*:} → $(ls -lh fonts/NotoSerifSC-${pair##*:}.subset.woff2 | awk '{print $5}')"
done
