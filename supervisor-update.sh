#!/usr/bin/bash

set -o errexit -o pipefail

#####################
# Variables to change
#####################

# The supervisor version to update to, for example:
# TAG="v9.0.1"
TAG=""

# The API key or session token, create one  on your Preferences page,
# which is at https://dashboard.balena-cloud.com/preferences/access-tokens
# for the regular Balena Cloud
API_KEY=""

# The API endpoint to interact with. The default is the regular Balena Cloud
API_ENDPOINT="https://api.balena-cloud.com"

##################
# End of variables
##################

UUID=$1

if [ -z "${TAG}" ]; then
  echo "Please set TAG=vX.Y.Z supervisor version (e.g TAG=v9.0.1), and include the initial 'v'!"
  exit 1
elif [ -z "${API_KEY}" ]; then
  echo "Please set your API_KEY variable in the update script with your APi key or session token!"
  exit 2
elif [ -z "${API_ENDPOINT}" ]; then
  echo "Please set your API_ENDPINT in the update script!"
  exit 3
elif [ -z "${UUID}" ]; then
  echo "Please provide a device UUID as an argument to this script!"
  exit 4
fi

main() {
  local uuid=$1
  local device device_id device_type supervisor_id
  device=$(curl --silent -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${API_KEY}" "${API_ENDPOINT}/v4/device?\$filter=uuid%20eq%20'${uuid}'&\$select=id,device_type")
  device_id=$(echo "${device}" | jq -e -r '.d[0].id')
  echo "Device ID: ${device_id}"
  device_type=$(echo "${device}" | jq -e -r '.d[0].device_type')
  supervisor_id=$(curl --silent -X GET "${API_ENDPOINT}/v4/supervisor_release?\$select=id,image_name&\$filter=((device_type%20eq%20'$device_type')%20and%20(supervisor_version%20eq%20'$TAG'))&apikey=${API_KEY}" | jq -e -r '.d[0].id')
  echo "Extracted supervisor ID: ${supervisor_id}"
  if [ -n "${supervisor_id}" ]; then
    if curl --silent -X PATCH -H "Authorization: Bearer ${API_KEY}" -H 'Content-Type: application/json' "${API_ENDPOINT}/v4/device(${device_id})" --data-binary "{\"should_be_managed_by__supervisor_release\": \"${supervisor_id}\"}" > /dev/null ; then
      echo "DONE"
    else
      echo "FAIL: supervisor update in the API did not succeed"
      exit 11
    fi
  fi
}

main "${UUID}"
