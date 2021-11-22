#!/bin/bash

if [ "$#" -ne 12 ]; then
  echo "Usage:   $0" '$out_folder $base_uri $owner_given_name $owner_family_name $owner_org_unit $owner_organization $owner_locality $owner_state_or_province $owner_country_name $owner_cert_pwd $secretary_cert_pwd $validity' >&2
  exit 1
fi

out_folder="$1"
base_uri="$2"

printf "### Output folder: %s\n" "$out_folder"

owner_alias="owner"
owner_keystore="${out_folder}/owner/keystore.p12"
owner_given_name="$3"
owner_family_name="$4"
owner_org_unit="$5"
owner_organization="$6"
owner_locality="$7"
owner_state_or_province="$8"
owner_country_name="$9"
owner_cert_pwd="${10}"
owner_cert="${out_folder}/owner/cert.pem"
owner_public_key="${out_folder}/owner/public.pem"

secretary_alias="secretary"
secretary_keystore="${out_folder}/secretary/keystore.p12"
secretary_cert="${out_folder}/secretary/cert.pem"
secretary_cert_pwd="${11}"
secretary_cert_dname="CN=LDH, OU=LDH, O=AtomGraph, L=Copenhagen, ST=Denmark, C=DK"

validity="${12}"

printf "\n### Base URI: %s\n" "$base_uri"

### OWNER CERT ###

owner_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]') # lowercase
owner_uri="${base_uri}admin/acl/agents/${owner_uuid}/#this"

printf "\n### Owner's WebID URI: %s\n" "$owner_uri"

owner_cert_dname="CN=${owner_given_name} ${owner_family_name}, OU=${owner_org_unit}, O=${owner_organization}, L=${owner_locality}, ST=${owner_state_or_province}, C=${owner_country_name}"
printf "\n### Owner WebID certificate's DName attributes: %s\n" "$owner_cert_dname"

mkdir -p "$out_folder"/owner

keytool \
    -genkeypair \
    -alias "$owner_alias" \
    -keyalg RSA \
    -storetype PKCS12 \
    -keystore "$owner_keystore" \
    -storepass "$owner_cert_pwd" \
    -keypass "$owner_cert_pwd" \
    -dname "$owner_cert_dname" \
    -ext "SAN=uri:${owner_uri}" \
    -validity "$validity"

# convert owner's certificate to PEM

openssl \
    pkcs12 \
    -in "$owner_keystore" \
    -passin pass:"$owner_cert_pwd" \
    -out "$owner_cert" \
    -passout pass:"$owner_cert_pwd"

# convert owner's public key to PEM

openssl \
    pkcs12 \
    -in "$owner_keystore" \
    -passin pass:"$owner_cert_pwd" \
    -nokeys \
    -out "$owner_public_key"

### SECRETARY CERT ###

mkdir -p "$out_folder"/secretary

secretary_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]') # lowercase
secretary_uri="${base_uri}admin/acl/agents/${secretary_uuid}/#this"

printf "\n### Secretary's WebID URI: %s\n" "$secretary_uri"

printf "\n### Secretary WebID certificate's DName attributes: %s\n" "$secretary_cert_dname"

keytool \
    -genkeypair \
    -alias "$secretary_alias" \
    -keyalg RSA \
    -storetype PKCS12 \
    -keystore "$secretary_keystore" \
    -storepass "$secretary_cert_pwd" \
    -keypass "$secretary_cert_pwd" \
    -dname "$secretary_cert_dname" \
    -ext "SAN=uri:${secretary_uri}" \
    -validity "$validity"

# convert secretary's certificate to PEM

openssl \
    pkcs12 \
    -in "$secretary_keystore" \
    -passin pass:"$secretary_cert_pwd" \
    -out "$secretary_cert" \
    -passout pass:"$secretary_cert_pwd"