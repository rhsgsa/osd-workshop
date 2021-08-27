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


### Changes from the source material

#### Deployment

* Step 2 - Are we using a shared cluster or will each participant get their own cluster? If it's a shared cluster we'll need to create a separate project per user

* Step 7
	* Route host will be different
	* We should prefix the URL with `http://` because the route is not setup for `https` - or better yet, modify the `Route` for a `Redirect` insecure policy


#### ConfigMaps, Secrets, Env Var

* Step 3 - `ENV_TOY_CONFIGMAP` env variable is not defined in the deployment yaml


#### Networking

* Step 2 - Service DNS name may need to change if we are using a different project per user


#### Logging

* The links given at the start of the lab are broken - the OSD docs don't seem to contain any information on logging anymore

* Step 5
	* We will need to setup logging if running the lab on an RHPDS cluster
	* Kibana is no longer accessible through Monitoring > Logging - we have to use the application launcher instead

* Step 6 - The filter doesn't work because the log message's `level` is `unknown`


#### S2I Deployments

* Step 2 - We will have to create this project ahead of time for each user if using a shared cluster

* Step 8 - Need to change `dc` to `deploy` and need to remove `.spec.strategy.rollingUpdate`:

		oc patch deploy/ostoy --type=json -p '[{"op":"remove", "path":"/spec/strategy/rollingUpdate"},{"op":"replace", "path":"/spec/strategy/type", "value":"Recreate"}]'

* Step 9 - Need to change `dc` to `deploy`

* Step 10 - Change all references to `deploymentconfig` and `dc` to `deploy`


#### S2I Webhooks for CICD

* Step 5 - Webhook fails because Github does not recognize RHPDS cluster's Let's Encrypt certificate; we may have to disable SSL verification in the webhook for this step to work


#### Autoscaling

* Step 1
	* Need to add a note to tell participants to switch back to the `ostoy` project (step 5 checks resources in `ostoy` instead of `ostoy-s2i`
	* Need to change `dc` to `deploy`

* Step 5
	* Need to insert the proper Grafana URL
	* Dashboard folder structure is different from those shown in the screenshots