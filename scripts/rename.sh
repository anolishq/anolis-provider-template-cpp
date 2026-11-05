#!/usr/bin/env bash
# Rename this provider after "Use this template".
#
#   scripts/rename.sh <kind>
#
# <kind> names the provider: the binary becomes anolis-provider-<kind>, which is
# also what install.sh and machine profiles call it. It uses a-z, 0-9 and -,
# starting with a letter. Every tracked file that names the provider is
# rewritten. Review the result with `git diff --stat` and commit it.
set -euo pipefail

kind="${1:-}"
if ! [[ "$kind" =~ ^[a-z][a-z0-9-]*$ ]] || [[ "$kind" == *- ]]; then
  echo "usage: $0 <kind>   (a-z, 0-9 and -, starting with a letter, e.g. bme280-lab)" >&2
  exit 2
fi
cd "$(git rev-parse --show-toplevel)"

# The current name comes from vcpkg.json, not from this script, so the script
# renames from whatever the provider is called now: the template's name the
# first time, the provider's own name after that.
old_dash="$(sed -n 's/^  "name": "\(anolis-provider-[a-z0-9-]*\)",$/\1/p' vcpkg.json | head -n 1)"
if [ -z "$old_dash" ]; then
  echo "vcpkg.json has no name of the form anolis-provider-<kind>" >&2
  exit 2
fi
old_snake="${old_dash//-/_}"
new_dash="anolis-provider-${kind}"
new_snake="anolis_provider_${kind//-/_}"
self="scripts/rename.sh"

if [ "$new_dash" = "$old_dash" ]; then
  echo "already named $old_dash" >&2
  exit 2
fi

# File contents.
git ls-files -z | while IFS= read -r -d '' f; do
  [ "$f" = "$self" ] && continue
  if grep -qF -e "$old_dash" -e "$old_snake" -- "$f"; then
    sed -i -e "s/${old_dash}/${new_dash}/g" -e "s/${old_snake}/${new_snake}/g" -- "$f"
  fi
done

echo "Renamed to ${new_dash}. Next:"
echo "  - change .github/CODEOWNERS to your account, and the README's title and text"
echo "  - replace the heater in src/provider.cpp with your device"
echo "  - just build && just test"
