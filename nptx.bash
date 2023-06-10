#!/bin/bash

HAND="hand.gif"
INPUT="${1}"
OUTPUT="output.gif"

## HANDからパラメタを抽出

STREAM="$(ffprobe -v error -show_entries "format=format_name,duration:stream=width,height" -print_format compact ${HAND} | sed -n '/stream/p')"
FORMAT="$(ffprobe -v error -show_entries "format=format_name,duration:stream=width,height" -print_format compact ${HAND} | sed -n '/format/p')"

# 次のコマンドで期待した内容が表示されない。
# for element in "${PARAM[@]}"; do
#   echo "$element" |\
#    sed -n '/=/p' |\
#    eval
# done
# echo ${format_name}

IFS="|" read -ra s <<< "${STREAM}"
width="$(echo ${s[1]} | sed -E 's/^.*=//')"
height="$(echo ${s[2]} | sed -E 's/^.*=//')"

IFS="|" read -ra f <<< "${FORMAT}"
format_name="$(echo ${f[1]} | sed -E 's/^.*=//')"
duration="$(echo ${f[2]} | sed -E 's/^.*=//')"

## HANDがGIF形式かどうかを判定

if [[ ${format_name} != "gif" ]]; then
  echo "Bad format of hand animation file"
  exit 1
fi

## 合成
# 背景が透過されない。

ffmpeg -i "${HAND}" -i "${INPUT}" -filter_complex "
[1:v]format=rgba,scale=${width}:${height},pad=iw+15:ih+15:15:15:ffffff00[s1];
[s1][0:v]overlay=0:0
" -y "${OUTPUT}"
