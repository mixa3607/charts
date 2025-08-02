export __CHART__="fan-control"
export __CHART_DESCRIPTION__="no"
export __USER__="mixa3607"
export __IMAGE_REPO__="apps/ark-fan-control"

find . -type f ! -name init.sh | while read FILE; do
  echo "Processing file $FILE"
  env | grep "__.*__=.*" | while read RULE; do
    SED_PATTERN="$(echo "$RULE" | sed -E 's|^(.*)=(.*)$|s@\1@\2@g|1')"
    sed -i "$SED_PATTERN" "$FILE"
  done
done
