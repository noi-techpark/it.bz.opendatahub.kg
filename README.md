  We will be using `https://kg.opendatahub.bz.it/` as the base URI below. Replace it if necessary.

# Installation

  1. Add a host mapping if you are running on localhost:
     ```
     127.0.0.1 kg.opendatahub.bz.it
     ```
     to `/etc/hosts` (on Linux) or `C:\Windows\System32\Drivers\etc\hosts` (on Windows).
  2. Clone this repository with submodules:
     ```
     git clone --recursive git@github.com:AtomGraph/OpenDataHub.git
     ```
     or if you have cloned it already
     ```
     git submodule update --remote
     ```
     This should add a `linkeddatahub` folder with the submodule.

# Usage

  1. Create an `.env` file and use it to configure the base URI as well as owner metadata. You can use `.env_sample` as a template.
  2. Setup client certificates (insert your own passwords, they need to be at least _6 characters long_):
     ```
     ./linkeddatahub/scripts/setup.sh .env ./ssl $owner_cert_pwd $secretary_cert_pwd 36500
     ```
     WebID URIs in the client certifcates are relative to the base URI and have to be regenerated if the base URI changes.
  3. Run the services:
     ```
     docker-compose up --build
     ```
  4. [Install Jena](https://jena.apache.org/documentation/tools/) and configure it:
     - `export JENA_HOME=the directory you downloaded Jena to`
     - `export PATH=$PATH:"$JENA_HOME"/bin`
  5. Declare the variable `SCRIPT_ROOT`:
     - `export SCRIPT_ROOT=linkeddatahub/scripts/`
  5. Create documents (authenticated as the owner):
     ```
     ./install.sh https://kg.opendatahub.bz.it/ https://sparql.opendatahub.testingmachine.eu/sparql ./ssl/owner/cert.pem $owner_cert_pwd
     ```
  6. Open https://kg.opendatahub.bz.it/

_:warning: The very first page load can take a while (or even result in `504 Bad Gateway`) while RDF ontologies and XSLT stylesheets are being loaded into memory._

# Configuration

* Base URI is configured in the `.env` file
* OpenDataHub SPARQL endpoint is:
  * configured as the `ENDPOINT` environment variable for the `processor` service
  * passed as the `$endpoint` argument to the `install.sh` script (step #5 above)
* The server's TLS certificate (e.g. LetsEncrypt) can be mounted into the `nginx` container and specified in its `/etc/nginx/nginx.conf` config file

# Reset datasets

  1. Kill the services and remove volumes:
     ```
     docker-compose down -v
     ```
  2. Remove mounted files:
     ```
     sudo rm -rf data uploads
     ```
