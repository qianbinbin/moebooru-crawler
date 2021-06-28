#!/bin/bash

DIR=
NUM=0
URLS_ONLY=false
MAX_PROCS=8


################################################################################
# PARSE ARGS

usage() {
  echo "Usage: moebooru-crawler URL [ -d | --dir DIR ]
                            [ -n | --num NUM ]
                            [ -u | --urls-only ]
                            [ -p | --max-procs PROCS ]"
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n moebooru-crawler -o d:n:up: --long dir:,num:,urls-only,max-procs: -- "$@")

VALID_ARGUMENTS=$?
[ "$VALID_ARGUMENTS" != 0 ] && usage

eval set -- "$PARSED_ARGUMENTS"
while :; do
  case "$1" in
    -d | --dir)        DIR="$2"         ; shift 2 ;;
    -n | --num)        NUM="$2"         ; shift 2 ;;
    -u | --urls-only)  URLS_ONLY=true   ; shift   ;;
    -p | --max-procs)  MAX_PROCS="$2"   ; shift 2 ;;
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

[ "$URLS_ONLY" = true ] && echo "$links" && exit 0


################################################################################
# DOWNLOAD FILES

if [ "$DIR" ] ; then
  [ ! -d "$DIR" ] && mkdir -p "$DIR"
  cd  "$DIR" || exit 1
fi

dir=$(sed "s/[^A-Za-z0-9\._-]/_/g" <<< "${URL#*://}")
[ "$NUM" -gt 0 ] && dir+="-$NUM"

[ ! -d "$dir" ] && mkdir "$dir"
cd "$dir" || exit 1

# do not use buggy curl --parallel
echo "$links" | xargs -n 1 -P "$MAX_PROCS" -I {} bash -c 'curl -fsSL --retry 4 -O "{}" || echo "failed to download: {}" 1>&2'