#!/bin/bash

[ -z "$SCRIPT_ROOT" ] && echo "Need to set SCRIPT_ROOT" && exit 1;

if [ "$#" -ne 4 ] && [ "$#" -ne 5 ]; then
  echo "Usage:   $0" '$base $endpoint $cert_pem_file $cert_password [$request_base]' >&2
  echo "Example: $0" 'https://kg.opendatahub.bz.it/ https://sparql.opendatahub.testingmachine.eu/sparql ./ssl/owner/cert.pem Password' >&2
  echo "Note: special characters such as $ need to be escaped in passwords!" >&2
  exit 1
fi

base="$1"
endpoint="$2"
cert_pem_file="$(realpath -s "$3")"
cert_password="$4"

if [ -n "$5" ]; then
    request_base="$5"
else
    request_base="$base"
fi

pwd=$(realpath -s "$PWD")

### SERVICE

pushd . && cd "$SCRIPT_ROOT"

doc=$(./create-generic-service.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Open Data Hub Knowledge Graph Portal" \
--endpoint "$endpoint" \
--slug "open-data-hub" \
 "${request_base}service")

ntriples=$(./get-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--accept 'application/n-triples' \
"$doc")

service=$(echo "$ntriples" | sed -rn "s/<(.*)> <http:\/\/xmlns.com\/foaf\/0.1\/isPrimaryTopicOf> <${doc//\//\\/}> \./\1/p")

popd

### ONTOLOGY

pushd . && cd "$SCRIPT_ROOT/admin/model"

query="${base}admin/model/ontologies/namespace/#SelectContainedPlaces"

./create-select.sh \
-b "${base}admin/" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "$query" \
--label "Select contained places" \
--slug select-contained-places \
--query-file "$pwd/queries/admin/select-contained-places.rq" \
--service "$service" \
"${request_base}admin/model/ontologies/namespace/"

popd

pushd . && cd "$SCRIPT_ROOT"

./create-content.sh \
-b "${base}admin/" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${base}admin/model/ontologies/namespace/#ContainedPlaces" \
--first "$query" \
"${request_base}admin/model/ontologies/namespace/"

popd

### QUERIES

pushd . && cd "$SCRIPT_ROOT"

### lodging businesses

query_doc=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select lodging businesses" \
--slug select-lodging-businesses \
--query-file "$pwd/queries/select-lodging-businesses.rq" \
--service "$service" \
"${request_base}service")

ntriples=$(./get-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--accept 'application/n-triples' \
"$query_doc")

query=$(echo "$ntriples" | sed -rn "s/<(.*)> <http:\/\/xmlns.com\/foaf\/0.1\/isPrimaryTopicOf> <${query_doc//\//\\/}> \./\1/p")

doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Lodging businesses" \
--slug "lodging-businesses" \
--container "$base" \
"${request_base}service")

content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${doc}#content" \
--first "$query" \
"$doc")

echo -e "<${doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$doc"

### events

query_doc=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select events" \
--slug select-events \
--query-file "$pwd/queries/select-events.rq" \
--service "$service" \
"${request_base}service")

ntriples=$(./get-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--accept 'application/n-triples' \
"$query_doc")

query=$(echo "$ntriples" | sed -rn "s/<(.*)> <http:\/\/xmlns.com\/foaf\/0.1\/isPrimaryTopicOf> <${query_doc//\//\\/}> \./\1/p")

doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Events" \
--slug "events" \
--container "$base" \
"${request_base}service")

content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${doc}#content" \
--first "$query" \
"$doc")

echo -e "<${doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$doc"

### food establishments

query_doc=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select food establishments" \
--slug select-food-establishments \
--query-file "$pwd/queries/select-food-establishments.rq" \
--service "$service" \
"${request_base}service")

ntriples=$(./get-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--accept 'application/n-triples' \
"$query_doc")

query=$(echo "$ntriples" | sed -rn "s/<(.*)> <http:\/\/xmlns.com\/foaf\/0.1\/isPrimaryTopicOf> <${query_doc//\//\\/}> \./\1/p")

doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Food establishments" \
--slug "food-establishments" \
--container "$base" \
"${request_base}service")

content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${doc}#content" \
--first "$query" \
"$doc")

echo -e "<${doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$doc"

### municipalities

query_doc=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select municipalities" \
--slug select-municipalities \
--query-file "$pwd/queries/select-municipalities.rq" \
--service "$service" \
"${request_base}service")

ntriples=$(./get-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--accept 'application/n-triples' \
"$query_doc")

query=$(echo "$ntriples" | sed -rn "s/<(.*)> <http:\/\/xmlns.com\/foaf\/0.1\/isPrimaryTopicOf> <${query_doc//\//\\/}> \./\1/p")

doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Municipalities" \
--slug "municipalities" \
--container "$base" \
"${request_base}service")

content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${doc}#content" \
--first "$query" \
"$doc")

echo -e "<${doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$doc"

### ski resorts

query_doc=$(./create-select.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Select ski resorts" \
--slug select-ski-resorts \
--query-file "$pwd/queries/select-ski-resorts.rq" \
--service "$service" \
"${request_base}service")

ntriples=$(./get-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--accept 'application/n-triples' \
"$query_doc")

query=$(echo "$ntriples" | sed -rn "s/<(.*)> <http:\/\/xmlns.com\/foaf\/0.1\/isPrimaryTopicOf> <${query_doc//\//\\/}> \./\1/p")

doc=$(./create-item.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--title "Ski resorts" \
--slug "ski-resorts" \
--container "$base" \
"${request_base}service")

content=$(./create-content.sh \
-b "$base" \
-f "$cert_pem_file" \
-p "$cert_password" \
--uri "${doc}#content" \
--first "$query" \
"$doc")

echo -e "<${doc}> <https://w3id.org/atomgraph/linkeddatahub/domain#content> <${doc}#content> ." \
| turtle --base="$base" \
| ./create-document.sh \
-f "$cert_pem_file" \
-p "$cert_password" \
--content-type 'text/turtle' \
"$doc"

popd