#!/usr/bin/env bash
# Re-runnable: pulls portfolio images from the Squarespace CDN into assets/img/.
# Uses ?format=original — the hero images are full-bleed, so they need the
# largest source available (1920px wide, and no larger than the 1500w variant).
# The CDN stays public even though the site itself has expired.
set -u
BASE="https://images.squarespace-cdn.com/content/v1/6820cc1cc1da504f823c9b08"
OUT="$(dirname "$0")/assets/img"
mkdir -p "$OUT"

# local-name <TAB> cdn-path
MAP=$(cat <<'MAPEOF'
wayfarers-guild	d62edfcb-c80d-45f2-a2aa-83e85d676162/Wayfarer%27s+guild+splash.png
reap-what-you-sew	5dbb9251-22ce-42c1-80df-8da977d2b96c/RWYS.PNG
ribbit-romance	d3c171d4-f61e-4fe5-92b3-0366ec8f2504/RR+ss+2.png
bubble-fish	7349934b-7922-4400-a835-73dd81f2e1c6/BF+ss.png
orchards-orchard	b44bc882-7b8e-45cc-95be-200d49904684/OOSS.png
dissertation-corridor	28167d3e-64aa-475c-92e4-7840bd61d2a5/corridor+considered+ss.png
dissertation-pathfirst	e5e47cbe-1401-4fa9-8a07-b87e2abd8a99/pathfirst+ss.png
dissertation-random	885fb757-0dc9-4de8-bde8-29b782df8aa5/random+ss.png
checklist-main	c4a44813-a7f3-46ce-a437-f8a7d753bb64/Checklist.png
checklist-custom	f2edcd21-ac81-469d-8323-057e3e2fa34f/CustomList2.png
checklist-premade	d14ea78f-3514-421c-b73a-ac4cd171659b/Pre+made+list.png
joe-orchard	d685b92f-7c49-470d-9a00-214a3578f609/Portfolio+pic.jpg
MAPEOF
)

printf "%-24s %-6s %-10s %s\n" NAME HTTP BYTES FILE
while IFS=$'\t' read -r name path; do
  [ -z "${name:-}" ] && continue
  url="$BASE/$path?format=original"
  hdr=$(curl -sS -D - -o "$OUT/.tmp" -w "%{http_code}" \
        -H 'Accept: image/webp,image/png,image/jpeg,*/*' "$url" 2>/dev/null)
  code="${hdr##*$'\n'}"
  ctype=$(printf '%s' "$hdr" | tr -d '\r' | grep -i '^content-type:' | tail -1 | awk '{print $2}')
  case "$ctype" in
    image/webp) ext=webp ;; image/png) ext=png ;;
    image/jpeg) ext=jpg ;;  *) ext=bin ;;
  esac
  if [ "$code" = "200" ]; then
    mv "$OUT/.tmp" "$OUT/$name.$ext"
    printf "%-24s %-6s %-10s %s\n" "$name" "$code" "$(wc -c < "$OUT/$name.$ext")" "$name.$ext"
  else
    rm -f "$OUT/.tmp"
    printf "%-24s %-6s %-10s %s\n" "$name" "$code" "-" "FAILED"
  fi
done <<< "$MAP"
