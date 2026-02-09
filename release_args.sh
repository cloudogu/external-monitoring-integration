#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# this function will be sourced from release.sh and be called from release_functions.sh
update_versions_modify_files() {
  valuesYAML=k8s/helm/values.yaml
  componentPatchTplYAML=k8s/helm/component-patch-tpl.yaml

  local kubectlImage
  kubectlImage=$(./.bin/yq ".images.kubectl" "${valuesYAML}")
  ./.bin/yq -i ".values.images.kubectl = \"${kubectlImage}\"" "${componentPatchTplYAML}"
}

update_versions_stage_modified_files() {
  valuesYAML=k8s/helm/values.yaml
  componentPatchTplYAML=k8s/helm/component-patch-tpl.yaml

  git add "${componentPatchTplYAML}"
}
