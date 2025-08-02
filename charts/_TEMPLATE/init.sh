export __CHART__="CHART"
export __CHART_DESCRIPTION__="CHART_DESCRIPTION"
export __USER__="USER"
export __IMAGE_REPO__="IMAGE_REPO"

find . -type f ! -name init.sh | while read FILE; do
  echo "Processing file $FILE"
  env | grep "__.*__=.*" | while read RULE; do
    SED_PATTERN="$(echo "$RULE" | sed -E 's|^(.*)=(.*)$|s@\1@\2@g|1')"
    sed -i "$SED_PATTERN" "$FILE"
  done
done
