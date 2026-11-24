#!/usr/bin/env bash
# Tests for dadbod_sync.lua and dadbod_migrate.lua on throwaway files (fake credentials).
#   bash scripts/dadbod_sync_test.sh
set -uo pipefail

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export XDG_CONFIG_HOME=$tmp/config PGSERVICEFILE=$tmp/pg_service.conf
mkdir -p "$XDG_CONFIG_HOME/dadbod"
conn=$XDG_CONFIG_HOME/dadbod/connections.yaml
fails=0

sync() { nvim --clean -l "$here/dadbod_sync.lua" >"$tmp/out" 2>&1; echo $? >"$tmp/code"; }
migrate() { nvim --clean -l "$here/dadbod_migrate.lua" >"$tmp/out" 2>&1; echo $? >"$tmp/code"; }
check() { # description, command
    if eval "$2"; then printf 'ok   %s\n' "$1"; else printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); sed 's/^/     /' "$tmp/out"; fi
}
section() { awk -v s="[$1]" '$0 == s { found = 1 } found && /^$/ { exit } found' "$PGSERVICEFILE"; }
# marker lines just above a section
markers() { awk -v s="[$1]" '/^# dadbod: / { m = m $0 "\n"; next } $0 == s { printf "%s", m; exit } { m = "" }' "$PGSERVICEFILE"; }

cat >"$conn" <<'EOF'
# comment
short: postgresql://u:p%40ss@db.example.com/app
ro_tunnel:
  url: postgresql://u:pw@localhost:15433/{{dbname}}
  tunnel:
    kube: data/svc/postgres:5433
    context: arn:aws:eks:eu-west-1:123:cluster/x
same_port_same_target:
  url: postgresql://other:pw@localhost:15433/app
  tunnel: { kube: data/svc/postgres:5433, context: "arn:aws:eks:eu-west-1:123:cluster/x" }
rw_tunnel:
  url: postgresql://u:pw@localhost:15434/app
  rw: true
  tunnel: { kube: ns/sts/pg-0, context: prod-ctx }
local:
  url: "postgresql://u:p#w@localhost:5432/app"
  rw: true
port_clash:
  url: postgresql://u:pw@localhost:15433/app
  tunnel: { kube: other/svc/postgres, context: test-ctx }
tunnel_5432:
  url: postgresql://u:pw@localhost:5432/app
  tunnel: { kube: ns/svc/pg, context: c }
tunnel_remote_host:
  url: postgresql://u:pw@db.example.com:15435/app
  tunnel: { kube: ns/svc/pg, context: c }
no_context:
  url: postgresql://u:pw@localhost:15436/app
  tunnel: { kube: ns/svc/pg }
bad_kube:
  url: postgresql://u:pw@localhost:15437/app
  tunnel: { kube: "ns/svc/pg; rm -rf ~", context: c }
typo:
  url: postgresql://u:pw@localhost/app
  read_write: true
rw_string:
  url: postgresql://u:pw@localhost/app
  rw: "yes"
EOF
sync
check "sync exits 2 when connections are skipped" '[ "$(cat "$tmp/code")" = 2 ]'
check "short form works, read-only" 'section short | grep -q "^options=.*default_transaction_read_only=on" && [ -z "$(markers short)" ]'
check "tunnel marker written" '[ "$(markers ro_tunnel)" = "# dadbod: tunnel kube arn:aws:eks:eu-west-1:123:cluster/x data svc/postgres 15433 5433" ]'
check "same port, same target allowed" 'markers same_port_same_target | grep -q "tunnel kube"'
check "rw + tunnel: both markers, remote port default 5432" '[ "$(markers rw_tunnel)" = "# dadbod: tunnel kube prod-ctx ns sts/pg-0 15434 5432
# dadbod: read-write" ]'
check "password with # in quoted url" 'grep -q "p#w" "$XDG_CONFIG_HOME/dadbod/pgpass.d/local"'
check "local is read-write" 'markers local | grep -q read-write'
for n in port_clash tunnel_5432 tunnel_remote_host no_context bad_kube typo rw_string; do
    check "$n skipped" 'grep -q "skipped $n:" "$tmp/out" && [ -z "$(section $n)" ]'
done
check "output has no passwords" '! grep -qE "pw|p#w|p%40ss" "$tmp/out"'

# old one-line tags: sync refuses and changes nothing
cp "$PGSERVICEFILE" "$tmp/before"
cat >"$conn" <<'EOF'
local: postgresql://u:pw@localhost:5432/app  # rw
EOF
sync
check "old tags refused" '[ "$(cat "$tmp/code")" = 1 ] && grep -q dadbod_migrate "$tmp/out" && cmp -s "$PGSERVICEFILE" "$tmp/before"'

# broken YAML: refused, error shows no file content
printf 'a:\n  url: "postgresql://u:secretpw@h/db\n' >"$conn"
sync
check "broken yaml refused without content" '[ "$(cat "$tmp/code")" = 1 ] && ! grep -q secretpw "$tmp/out" && cmp -s "$PGSERVICEFILE" "$tmp/before"'

# migration from the one-line format
cat >"$conn" <<'EOF'
# One "name: url" per line, no quoting. {{dbname}} = pick the database when connecting.
# Saving syncs ~/.pg_service.conf (read-only for tools like pgro); end a line with "# rw" to allow writes.
# local: postgresql://user:pass@localhost:5432/{{dbname}}  # rw
# my own note
local: postgresql://u:p"w\x#1@localhost:5432/{{dbname}}  # rw
remote_prod: postgresql://u:pw@localhost:15433/db  # kube=data/svc/pg:5433 ctx=prod-ctx
no_ctx: postgresql://u:pw@localhost:15434/db  # kube=data/svc/pg
plain: postgresql://u:pw@db.example.com/db
odd: postgresql://u:pw@db.example.com/db  # rw foo=bar
EOF
cp "$conn" "$tmp/old"
migrate
check "migration succeeds" '[ "$(cat "$tmp/code")" = 0 ]'
check "migration output has no passwords" '! grep -qE "pw|p\"w" "$tmp/out"'
check "migration warns about kube= without ctx=" 'grep -q "no_ctx" "$tmp/out"'
check "backup kept, mode 600" 'b=$(ls "$XDG_CONFIG_HOME"/dadbod/connections.yaml.bak-*) && cmp -s "$b" "$tmp/old" && [ "$(stat -c %a "$conn")" = 600 ]'
check "own comment kept, old header dropped" 'grep -q "^# my own note" "$conn" && ! grep -q "no quoting" "$conn"'
check "url round-trips" '[ "$(yq ".local.url" "$conn")" = "postgresql://u:p\"w\\x#1@localhost:5432/{{dbname}}" ]'
check "rw and tunnel converted" '[ "$(yq ".local.rw" "$conn")" = true ] && [ "$(yq ".remote_prod.tunnel.kube + \" \" + .remote_prod.tunnel.context" "$conn")" = "data/svc/pg:5433 prod-ctx" ]'
check "unknown tags kept as a comment" 'grep -q "foo=bar" "$conn"'
migrate
check "second migration refused" '[ "$(cat "$tmp/code")" = 1 ]'
sync
check "sync after migration: only no_ctx skipped" '[ "$(grep -c skipped "$tmp/out")" = 1 ] && grep -q "skipped no_ctx" "$tmp/out" && markers remote_prod | grep -q "tunnel kube prod-ctx data svc/pg 15433 5433"'

echo
[ $fails -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
