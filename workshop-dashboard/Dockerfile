FROM quay.io/openshifthomeroom/workshop-dashboard:5.0.0

USER root

RUN \
  curl -o /tmp/oc.tgz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.7/openshift-client-linux.tar.gz \
  && \
  cd /opt/workshop/bin \
  && \
  tar -zxf /tmp/oc.tgz oc \
  && \
  rm -f /tmp/oc.tgz

USER 1001
