IMAGE="ghcr.io/kwkoo/workshop-dashboard:4.7"

BASE:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: deploy clean image homeroom gau

deploy:
	@$(BASE)/scripts/create-user-projects
	@$(BASE)/scripts/deploy-homeroom
	@$(BASE)/scripts/deploy-get-a-username
	@echo "Done"

clean:
	-@$(BASE)/scripts/clean-user-projects
	-@$(BASE)/scripts/clean-get-a-username
	-@$(BASE)/scripts/clean-homeroom

# downloads version 4.7 of the oc cli
image:
	docker build -t $(IMAGE) $(BASE)/workshop-dashboard
	docker push $(IMAGE)

homeroom:
	@open https://`oc get route/hosted-workshop-spawner -n lab-infra -o jsonpath='{.spec.host}'`

gau:
	@open https://`oc get route/get-a-username -n lab-infra -o jsonpath='{.spec.host}'`
