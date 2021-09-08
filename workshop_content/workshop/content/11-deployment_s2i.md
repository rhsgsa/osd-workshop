There are multiple methods to deploy applications in OpenShift. Let's explore using the integrated Source-to-Image (S2I) builder. As mentioned in the [concepts](2-concepts.md) section, S2I is a tool for building reproducible, Docker-formatted container images. 

#### 1. Fork the repository
In the next section we will trigger automated builds based on changes to the source code. In order to trigger S2I builds when you push code into your GitHub repo, you’ll need to setup the GitHub webhook.  And in order to setup the webhook, you’ll first need to fork the application into your personal GitHub repository.

<a class="github-button" href="https://github.com/openshift-cs/ostoy/fork" data-icon="octicon-repo-forked" data-size="large" aria-label="Fork openshift-cs/ostoy on GitHub">Fork</a>

> **NOTE:** Going forward you will need to replace any reference to "< username >" in any of the URLs for commands with your own Github username.  So in this example I would always replace "< username >" with "0kashi".

#### 2. Switch project

Switch to a fresh project

```execute
oc project %username%-ostoy-s2i
```

### Steps to Deploy OSToy imperatively using S2I

#### 3. Set the `GIT_USER` environment variable to your github username in the terminal 

Enter the following into the terminal (please replace **`REPLACE_ME`** with your actual github username):

```copy
GIT_USER=REPLACE_ME
```

#### 4. Add Secret to OpenShift
The example emulates a `.env` file and shows how easy it is to move these directly into an OpenShift environment. Files can even be renamed in the Secret.  In your CLI enter the following command:

```execute
oc create -f https://raw.githubusercontent.com/${GIT_USER}/ostoy/master/deployment/yaml/secret.yaml
```

You should see the following:

```shell
secret "ostoy-secret" created
```

#### 5. Add ConfigMap to OpenShift
The example emulates an HAProxy config file, and is typically used for overriding default configurations in an OpenShift application. Files can even be renamed in the ConfigMap.

Enter the following into your CLI

```execute
oc create -f https://raw.githubusercontent.com/${GIT_USER}/ostoy/master/deployment/yaml/configmap.yaml
```

You should see the following:

```shell
configmap "ostoy-config" created
```

#### 6. Deploy the microservice
We deploy the microservice first to ensure that the SERVICE environment variables will be available from the UI application. `--context-dir` is used here to only build the application defined in the `microservice` directory in the git repo. Using the `app` label allows us to ensure the UI application and microservice are both grouped in the OpenShift UI.  

Enter the following into the CLI

```execute
oc new-app https://github.com/${GIT_USER}/ostoy \
  --context-dir=microservice \
  --name=ostoy-microservice \
  --labels=app=ostoy
```

You should see the following:

```shell
Creating resources with label app=ostoy ...
  imagestream "ostoy-microservice" created
  buildconfig "ostoy-microservice" created
  deploymentconfig "ostoy-microservice" created
  service "ostoy-microservice" created
Success
  Build scheduled, use 'oc logs -f bc/ostoy-microservice' to track its progress.
  Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
   'oc expose svc/ostoy-microservice'
  Run 'oc status' to view your app.
```

Enter the following to monitor the status of the build

```execute
oc logs -f buildconfig/ostoy-microservice
```

#### 7. Check the status of the microservice
Before moving onto the next step we should be sure that the microservice was created and is running correctly.  To do this run:

```execute
oc status
```

```shell
In project %username%-ostoy-s2i on server https://api.osd4-demo.abc1.p1.openshiftapps.com:6443

svc/ostoy-microservice - 172.30.119.88:8080
  dc/ostoy-microservice deploys istag/ostoy-microservice:latest <-
    bc/ostoy-microservice source builds https://github.com/<username>/ostoy on openshift/nodejs:10 
    deployment #1 deployed about a minute ago - 1 pod
``` 

Wait until you see that it was successfully deployed. You can also check this through the web UI.

#### 8. Deploy the frontend UI of the application

The application has been architected to rely on several environment variables to define external settings. We will attach the previously created Secret and ConfigMap afterward, along with creating a PersistentVolume.  Enter the following into the CLI:

```execute
oc new-app https://github.com/${GIT_USER}/ostoy \
  --env=MICROSERVICE_NAME=OSTOY_MICROSERVICE
```

You should see the following:

```shell
Creating resources ...
  imagestream "ostoy" created
  buildconfig "ostoy" created
  deploymentconfig "ostoy" created
  service "ostoy" created
Success
  Build scheduled, use 'oc logs -f bc/ostoy' to track its progress.
  Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
   'oc expose svc/ostoy'
  Run 'oc status' to view your app.
```

Enter the following to monitor the status of the build

```execute
oc logs -f buildconfig/ostoy
```

#### 9. Update the Deployment 

We need to update the deployment to use a "Recreate" deployment strategy (as opposed to the default of `RollingUpdate` for consistent deployments with persistent volumes. Reasoning here is that the PV is backed by EBS and as such only supports the `RWO` method.  If the deployment is updated without all existing pods being killed it may not be able to schedule a new pod and create a PVC for the PV as it's still bound to the existing pod.

```execute
oc patch deploy/ostoy \
  --type=json \
  -p '[{"op":"remove", "path":"/spec/strategy/rollingUpdate"},{"op":"replace", "path":"/spec/strategy/type", "value":"Recreate"}]'
```

```shell
deployment.apps/ostoy patched
```

#### 10. Set a Liveness probe

We need to create a Liveness Probe on the Deployment to ensure the pod is restarted if something isn't healthy within the application.  Enter the following into the CLI:

```execute
oc set probe deploy/ostoy --liveness --get-url=http://:8080/health
```

```shell
deployment.apps/ostoy probes updated
```

#### 11. Attach Secret, ConfigMap, and PersistentVolume to Deployment

We are using the default paths defined in the application, but these paths can be overridden in the application via environment variables

- Attach Secret

```execute
oc set volume deploy/ostoy --add \
  --secret-name=ostoy-secret \
  --mount-path=/var/secret
```

```shell
info: Generated volume name: volume-6fqmv
deployment.apps/ostoy volume updated
```

- Attach ConfigMap (using shorthand commands)

```execute
oc set volume deploy/ostoy \
  --add \
  --configmap-name=ostoy-config \
  -m /var/config
```

```shell
info: Generated volume name: volume-2ct8f
deployment.apps/ostoy volume updated
```

- Create and attach PersistentVolume

```execute
oc set volume deploy/ostoy \
  --add \
  --type=pvc \
  --claim-size=1G \
  -m /var/demo_files
```

```shell
info: Generated volume name: volume-rlbvv
deployment.apps/ostoy volume updated
```

#### 12. Expose the UI application as an OpenShift Route
Using OpenShift Dedicated's included TLS wildcard certificates, we can easily deploy this as an HTTPS application

```execute
oc create route edge --service=ostoy --insecure-policy=Redirect
```

```shell
route.route.openshift.io/ostoy created
```

Get the host of the route that was just created:

```execute
oc get route/ostoy
```

#### 13. Browse to your application

Open a browser to the URL specified by the route: <https://ostoy-%username%-ostoy-s2i.%cluster_subdomain%>

<!-- Place this tag in your head or just before your close body tag. -->
<script async defer src="https://buttons.github.io/buttons.js"></script>