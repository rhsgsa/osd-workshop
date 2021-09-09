# OSD Workshop

## Overview

This deploys on OpenShift 4.7.

This project installs and configures the following:

1. OpenShift projects for each user

1. Lab instructions using homeroom-dashboard

1. Get A Username


## Installation

To install,

1. Login to OpenShift as an admin user using `oc login`

1. Set the number of users to provision for in `config.sh`

1. Run `make deploy`

Once everything has been deployed, you can

* run `make homeroom` to open a browser to the lab instructions

* run `make gau` to open a browser to get-a-username

	* The password in get-a-username is defined as `GAU_ACCESS_TOKEN` in `config.sh`
	* If you wish to access the admin UI, go to the `/admin` URI - the admin password is defined as `GAU_ADMIN_PASSWORD` in `config.sh`


## Uninstall

To uninstall, run `make clean`.


## Running Locally

To run this on a local docker instance

* Start a container with `./scripts/run-dashboard-local.sh`
* You can access the lab material on <http://localhost:8080>
* Changes to the workshop material should be reflected with a page reload (without requiring a container restart)


## References

* [Workshop content layout](https://github.com/openshift-homeroom/lab-workshop-content)
* The lab material was taken from [here](https://github.com/openshift-cs/osdworkshop/tree/master/OSD4)
