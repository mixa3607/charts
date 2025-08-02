#!/bin/bash
set -e

function pack-push-remove {
  local REGISTRY="$1"
  local CHART_NAME="$(yq '.name' Chart.yaml -r)"
  local CHART_VER="$(yq '.version' Chart.yaml -r)"
  if helm pull "oci://$REGISTRY/$CHART_NAME" --version "$CHART_VER" 2> /dev/null; then
    echo "Chart $CHART_NAME with version $CHART_VER exist. Skip"
    rm "$CHART_NAME-$CHART_VER.tgz"
    return 0
  fi
  helm package .
  helm push "$CHART_NAME-$CHART_VER.tgz" "oci://$REGISTRY"
  rm "$CHART_NAME-$CHART_VER.tgz"
}

function update-all {
  local REGISTRY="$1"
  find -mindepth 1 -maxdepth 1 -type d ! -name '_*' | while read DIR; do
    pushd "$DIR"
    pack-push-remove "$REGISTRY"
    popd
  done
}

update-all "$1"
