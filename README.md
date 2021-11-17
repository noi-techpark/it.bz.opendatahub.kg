  We will be using `https://kg.opendatahub.bz.it/` as the base URI below. Replace it if necessary.

# Installation

For testing purposes, you can add a host mapping if you are running on localhost:
```
127.0.0.1 kg.opendatahub.bz.it
```
to `/etc/hosts` (on Linux) or `C:\Windows\System32\Drivers\etc\hosts` (on Windows).

# Usage

  1. Create an `.env` file and use it to configure the base URI as well as owner metadata. You can use `.env_dev` (plain HTTP) or `.env_prod` (HTTPS with a self-signed server certificate) as templates.
  2. Run the services:
     ```
     docker-compose up --build
     ```
  3. Open https://kg.opendatahub.bz.it/

_:warning: The very first page load can take a while (or even result in `504 Bad Gateway`) while RDF ontologies and XSLT stylesheets are being loaded into memory._

HTTP server's (which is the `nginx` service) port within the Docker network is 8080.

# Configuration

* Base URI is configured in the `.env` file
* OpenDataHub SPARQL endpoint is configured as the `ENDPOINT` environment variable for the `processor` service

# Reset datasets

Kill the services and remove volumes:
```
docker-compose down -v
```