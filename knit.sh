#!/bin/bash
# Knit every .Rmd under Practicals/ to .html alongside its source.
# Each .Rmd is rendered with its own directory as the working directory,
# so relative paths inside the notebook (e.g. data/foo.txt) resolve correctly.
#
# Usage:
#   ./knit.sh              # knit all .Rmd files
#   ./knit.sh path/to.Rmd  # knit a single file

set -u
cd "$(dirname "$0")"

knit_one() {
    local rmd="$1"
    echo "==> $rmd"
    Rscript -e "rmarkdown::render('$(basename "$rmd")', output_dir='.', quiet=TRUE)" \
        2>&1 | sed "s|^|    |"
}

if [ $# -gt 0 ]; then
    targets=("$@")
else
    mapfile -t targets < <(find Practicals -name '*.Rmd' | sort)
fi

failed=0
for rmd in "${targets[@]}"; do
    (cd "$(dirname "$rmd")" && knit_one "$(basename "$rmd")") || failed=$((failed + 1))
done

if [ "$failed" -gt 0 ]; then
    echo "$failed file(s) failed to knit" >&2
    exit 1
fi
