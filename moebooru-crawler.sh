#!/bin/bash

NUM=0


################################################################################
# PARSE ARGS

usage() {
  echo "Usage: moebooru-crawler URL [ -n | --num NUM ]"
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n moebooru-crawler -o n: --long num: -- "$@")

VALID_ARGUMENTS=$?
[ "$VALID_ARGUMENTS" != 0 ] && usage

eval set -- "$PARSED_ARGUMENTS"
while :; do
  case "$1" in
    -n | --num)        NUM="$2"         ; shift 2 ;;
    --) shift; break ;;
  esac
done

URL="$1"
[ -z "$URL" ] && usage


################################################################################
# FETCH LINKS

get_links() {
  local content
  content=$(curl -fsSL "$1")
  echo "$content" | grep -P -o 'file_url=".*?"' | grep -o 'http[^"]*'
}

IFS="?"; read -ra PARTS <<< "$URL"; unset IFS
path=${PARTS[0]}
path+=".xml"
query=${PARTS[1]}

links=

if [ "$NUM" -le 0 ]; then
  url="$path"
  [ -n "$query" ] && url+="?$query"
  links=$(get_links "$url")
else
  query=$(sed "s/&\?page=[0-9]*//g" <<< "$query")
  [ -n "$query" ] && query+="&"
  page=1
  while [ "$(wc -w <<< "$links")" -lt "$NUM" ]; do
    p="page=$page"
    url="$path?$query$p"
    new_links=$(get_links "$url")
    [ "$(wc -w <<< "$new_links")" -eq 0 ] && break
    links+=" $new_links"
    ((page+=1))
  done
  links=$(xargs -n 1 <<< "$links")
  links=$(head -n "$NUM" <<< "$links")
fi

echo "$links"