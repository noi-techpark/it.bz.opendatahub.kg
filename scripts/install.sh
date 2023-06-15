#!/bin/bash

# SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

[ -z "$SCRIPT_ROOT" ] && echo "Need to set SCRIPT_ROOT" && exit 1;

if [ "$#" -ne 4 ] && [ "$#" -ne 5 ]; then
  echo "Usage:   $0" '$base $endpoint $cert_pem_file $cert_password [$request_base]' >&2
  echo "Example: $0" 'https://kg.opendatahub.com/ https://sparql.opendatahub.testingmachine.eu/sparql ./ssl/owner/cert.pem Password' >&2
  echo "Note: special characters such as $ need to be escaped in passwords!" >&2
  exit 1
fi

base="$1"
endpoint="$2"
cert_pem_file=$(realpath -s "$3")
cert_password="$4"

if [ -n "$5" ]; then
    request_base="$5"
else
    request_base="$base"
fi

pwd="$(realpath -s "$PWD")"

export SCRIPT_ROOT="${pwd}/linkeddatahub/scripts"
echo "SCRIPT_ROOT: $SCRIPT_ROOT"

printf "\n### Creating authorization to make the app public\n\n"

"$SCRIPT_ROOT"/admin/acl/make-public.sh -b "$base" -f "$cert_pem_file" -p "$cert_password" --request-base "$request_base"

printf "\n### Creating documents\n\n"

./create-documents.sh "$base" "$endpoint" "$cert_pem_file" "$cert_password" "$request_base"