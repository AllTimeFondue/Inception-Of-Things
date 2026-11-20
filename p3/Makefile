SCRIPTS_DIR = scripts
INSTALL     = $(SCRIPTS_DIR)/install.sh
SETUP       = $(SCRIPTS_DIR)/setup.sh
TEST		= $(SCRIPTS_DIR)/test_install.sh
CLEAN		= $(SCRIPTS_DIR)/clean.sh

all: setup

install:
	bash $(INSTALL)

setup:
	bash $(SETUP)

test:
	bash $(TEST)

password:
	@kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
	@echo

ui:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

terminal:
	kubectl get pods -n dev -w

status:
	kubectl get applications -n argocd
	kubectl get pods -n dev

clean:
	bash $(CLEAN)

re: clean all

.PHONY: all install setup password ui status clean re