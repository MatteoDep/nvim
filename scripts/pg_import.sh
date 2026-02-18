#!/bin/sh
set -eu

URL="$1"
TABLE_NAME="$2"
FILE_NAME="$3"

export PGPASSFILE="$(pwd)/.pgpass"

printf "$URL\n" | sed -E 's/^([a-z:]+):\/\/(.+):(.+)@(.+):(.+)\/(\w+)(\?.*)?$/\4:\5:\6:\2:\3/' | tee "$PGPASSFILE"
chmod 600 "$PGPASSFILE"

URL=$(printf "$URL\n" | sed -E 's/^([a-z:]+:\/\/)(.+):(.+)@(.+):(.+)\/(\w+)(\?.*)?$/\1\2@\4:\5\/\6\7/')
echo "$URL"

cat "$FILE_NAME" | psql "$URL" -c "COPY $TABLE_NAME FROM STDIN CSV HEADER"
