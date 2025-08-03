if [ "$__CHART__" == "" ]; then
  export __CHART__="$(basename $PWD)"
fi
if [ "$__CHART_DESCRIPTION__" == "" ]; then
  export __CHART_DESCRIPTION__="CHART_DESCRIPTION"
fi
if [ "$__USER__" == "" ]; then
  export __USER__="mixa3607"
fi
if [ "$__IMAGE_REPO__" == "" ]; then
  export __IMAGE_REPO__="ghcr.io/$__USER__/charts/$__CHART__"
fi

find . -type f ! -name init.sh | while read FILE; do
  echo "Processing file $FILE"
  env | grep "__.*__=.*" | while read RULE; do
    SED_PATTERN="$(echo "$RULE" | sed -E 's|^(.*)=(.*)$|s@\1@\2@g|1')"
    sed -i "$SED_PATTERN" "$FILE"
  done
done
