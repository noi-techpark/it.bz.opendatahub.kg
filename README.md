<!--
SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>

SPDX-License-Identifier: CC0-1.0
-->

We will be using `https://kg.opendatahub.com/` as the base URI below. Replace it if necessary.

# Installation

For testing purposes, you can add a host mapping if you are running on localhost:
```
127.0.0.1 kg.opendatahub.com
```
to `/etc/hosts` (on Linux) or `C:\Windows\System32\Drivers\etc\hosts` (on Windows).

# Usage

The default setup provides a plain HTTP service. In order to enable HTTPS, apply the `docker-compose.override.https.yml` by copying it to `docker-compose.override.yml` before running the services.

  1. Create an `.env` file and use it to configure the base URI as well as owner metadata. You can use `.env_sample` as a template.
  2. Run the services:
     ```
     docker-compose up --build
     ```
  3. Open https://kg.opendatahub.com/

_:warning: The very first page load can take a while (or even result in `504 Bad Gateway`) while RDF ontologies and XSLT stylesheets are being loaded into memory._

HTTP server's (which is the `nginx` service) port within the Docker network is 8080.

# Configuration

* Base URI is configured in the `.env` file
* OpenDataHub SPARQL endpoint is configured as
  * `ENDPOINT` build argument for the `linkeddatahub` service
  * `ENDPOINT` environment variable for the `processor` service

# Reset datasets

Kill the services and remove volumes:
```
docker-compose down -v
```