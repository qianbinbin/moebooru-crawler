#!/usr/bin/env sh

NUM=

USAGE=$(
  cat <<-END
Usage: moebooru-crawler URL [ -n NUM, --num=NUM ]

  -n NUM, --num=NUM         print NUM links of images,
                            or print all if NUM is '0'
END
)

error() { echo "$@" >&2; }

_exit() {
  error "$USAGE"
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
  -n | --num)
    [ -n "$2" ] || _exit
    NUM="$2"
    shift 2
    ;;
  -n=* | --num=*)
    NUM="${1#*=}"
    shift
    ;;
  -*)
    _exit
    ;;
  *)
    [ -z "$URL" ] || _exit
    URL="$1"
    shift
    ;;
  esac
done

if [ -n "$NUM" ]; then
  [ "$NUM" -ge 0 ] 2>/dev/null || _exit
fi
[ -n "$URL" ] || _exit

get_links() {
  content=$(curl -fsSL "$1")
  echo "$content" | grep -o 'file_url="[^"]*' | grep -o 'http[^"]*'
}

if echo "$URL" | grep -qs '?'; then
  path=${URL%%\?*}.xml
  query=${URL#*\?}
else
  path="$URL.xml"
  query=
fi

links=

if [ -z "$NUM" ]; then
  url="$path"
  [ -n "$query" ] && url="$url?$query"
  links=$(get_links "$url")
else
  query=$(echo "$query" | sed "s/&\?page=[0-9]*//g")
  [ -n "$query" ] && query="$query&"
  page=1
  while [ "$NUM" -eq 0 ] || [ "$(echo "$links" | wc -w)" -lt "$NUM" ]; do
    p="page=$page"
    url="$path?$query$p"
    _links=$(get_links "$url")
    [ "$(echo "$_links" | wc -w)" -eq 0 ] && break
    links="$links $_links"
    : $((page = page + 1))
  done
  links=$(echo "$links" | xargs -n 1)
  [ "$NUM" -eq 0 ] || links=$(echo "$links" | head -n "$NUM")
fi

echo "$links"
