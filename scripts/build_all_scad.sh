#!/usr/bin/env bash
set -eu

# Build all .scad files in the repository root into renders/<name>.stl
# Uses options shown in README.md:
# --enable=lazy-union --backend=manifold --enable=roof
# Supports --dry-run to only print commands without executing them.

RENDER_DIR="renders"
OPENSCADEX="openscad"
OPTS=("--enable=lazy-union" "--backend=manifold" "--enable=roof")
DRY_RUN=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run] [--openscad /path/to/openscad]

Finds .scad files in the repository root (not in subdirectories) and runs
openscad <file>.scad -o renders/<file>.stl ${OPTS[*]}

Options:
  --dry-run           Print the commands instead of executing them
  --openscad <path>   Use a specific openscad executable
  -h, --help          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1; shift ;;
    --openscad)
      OPENSCADEX="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

mkdir -p "$RENDER_DIR"

shopt -s nullglob
files=(./*.scad)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .scad files found in repository root."
  exit 0
fi

for f in "${files[@]}"; do
  fname=$(basename -- "$f")
  name="${fname%.scad}"
  out="$RENDER_DIR/${name}.stl"
  cmd=("$OPENSCADEX" "$f" -o "$out" "${OPTS[@]}")

  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s\n' "${cmd[@]}"
  else
    printf 'Running: %s\n' "${cmd[*]}"
    "${cmd[@]}"
  fi
done

[ $DRY_RUN -eq 0 ] && echo "Done. Generated files will be in: $RENDER_DIR"
