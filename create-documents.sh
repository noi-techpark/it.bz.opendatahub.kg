#!/bin/bash

[ -z "$SCRIPT_ROOT" ] && echo "Need to set SCRIPT_ROOT" && exit 1;

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
  echo "Usage:   $0" '$base $cert_pem_file $cert_password [$request_base]' >&2
  echo "Example: $0" 'https://linkeddatahub.com/atomgraph/app/ ../../../certs/martynas.localhost.pem Password' >&2
  echo "Note: special characters such as $ need to be escaped in passwords!" >&2
  exit 1
fi

base="$1"
cert_pem_file="$(realpath -s "$2")"
cert_password="$3"

if [ -n "$4" ]; then
    request_base="$4"
else
    request_base="$base"
fi

pwd=$(realpath -s "$PWD")

pushd . && cd "$SCRIPT_ROOT"

select_lodging_businesses=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select lodging businesses" \
--slug select-lodging-businesses \
--query-file "$pwd/queries/select-lodging-businesses.rq" \
--service "${base}services/open-data-hub/#this" \
"${request_base}service")

lodging_businesses_doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Lodging businesses" \
--slug "lodging-businesses" \
--container "$base" \
"${request_base}service")

select_lodging_businesses_content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${lodging_businesses_doc}#content" \
--first "${select_lodging_businesses}#this" \
"$lodging_businesses_doc")

echo -e "<${lodging_businesses_doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${lodging_businesses_doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$lodging_businesses_doc"


select_events=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select events" \
--slug select-events \
--query-file "$pwd/queries/select-events.rq" \
--service "${base}services/open-data-hub/#this" \
"${request_base}service")

events_doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Events" \
--slug "events" \
--container "$base" \
"${request_base}service")

select_events_content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${events_doc}#content" \
--first "${select_events}#this" \
"$events_doc")

echo -e "<${events_doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${events_doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$events_doc"


select_food_establishments=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select food establishments" \
--slug select-food-establishments \
--query-file "$pwd/queries/select-food-establishments.rq" \
--service "${base}services/open-data-hub/#this" \
"${request_base}service")

food_establishments_doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Food establishments" \
--slug "food-establishments" \
--container "$base" \
"${request_base}service")

select_food_establishments_content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${food_establishments_doc}#content" \
--first "${select_food_establishments}#this" \
"$food_establishments_doc")

echo -e "<${food_establishments_doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${food_establishments_doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$food_establishments_doc"


select_municipalities=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select municipalities" \
--slug select-municipalities \
--query-file "$pwd/queries/select-municipalities.rq" \
--service "${base}services/open-data-hub/#this" \
"${request_base}service")

municipalities_doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Municipalities" \
--slug "municipalities" \
--container "$base" \
"${request_base}service")

select_municipalities_content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${municipalities_doc}#content" \
--first "${select_municipalities}#this" \
"$municipalities_doc")

echo -e "<${municipalities_doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${municipalities_doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$municipalities_doc"


select_ski_resorts=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select ski resorts" \
--slug select-ski-resorts \
--query-file "$pwd/queries/select-ski-resorts.rq" \
--service "${base}services/open-data-hub/#this" \
"${request_base}service")

ski_resorts_doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Ski resorts" \
--slug "ski-resorts" \
--container "$base" \
"${request_base}service")

select_ski_resorts_content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${ski_resorts_doc}#content" \
--first "${select_ski_resorts}#this" \
"$ski_resorts_doc")

echo -e "<${ski_resorts_doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${ski_resorts_doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$ski_resorts_doc"

popd