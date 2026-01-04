#-----------------------------
# Makefile for packer-homelab
#-----------------------------

#-----------------------------
# Variables
#-----------------------------
PACKER_DIR ?= .
TERRAFORM_DIR ?= terraform

#-----------------------------
# Targets
#-----------------------------

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#--------------------------------------------
# install mise tools
#--------------------------------------------

.PHONY: install-mise-tools
install-mise-tools: ## Install mise tools
	mise install

#--------------------------------------------
# packer layers
#--------------------------------------------

.PHONY: ubuntu-2404-base
ubuntu-2404-base: ## Select ubuntu-2404-base layer
	$(eval LAYER := ubuntu-2404-base)

.PHONY: ubuntu-2404-homelab
ubuntu-2404-homelab: ## Select ubuntu-2404-homelab layer
	$(eval LAYER := ubuntu-2404-homelab)

#--------------------------------------------
# packer commands
#--------------------------------------------

.PHONY: packer-init
packer-init: ## Packer init for selected layer
	cd $(LAYER) && packer init .

.PHONY: packer-validate
packer-validate: ## Packer validate for selected layer
	cd $(LAYER) && packer validate -var-file=variables.pkrvars.hcl .

.PHONY: packer-build
packer-build: ## Packer build for selected layer
	cd $(LAYER) && packer build -var-file=variables.pkrvars.hcl .

.PHONY: packer-build-force
packer-build-force: ## Packer build with force for selected layer
	cd $(LAYER) && packer build -force -var-file=variables.pkrvars.hcl .

#--------------------------------------------
# terraform layers (for testing)
#--------------------------------------------

.PHONY: tf-ubuntu-2404-base
tf-ubuntu-2404-base: ## Select terraform ubuntu-2404-base layer
	$(eval TF_LAYER := ubuntu-2404-base)

#--------------------------------------------
# terraform commands
#--------------------------------------------

.PHONY: tf-init
tf-init: ## Terraform init for selected layer
	cd $(TERRAFORM_DIR)/$(TF_LAYER) && terraform init

.PHONY: tf-plan
tf-plan: ## Terraform plan for selected layer
	cd $(TERRAFORM_DIR)/$(TF_LAYER) && terraform plan

.PHONY: tf-apply
tf-apply: ## Terraform apply for selected layer
	cd $(TERRAFORM_DIR)/$(TF_LAYER) && terraform apply

.PHONY: tf-destroy
tf-destroy: ## Terraform destroy for selected layer
	cd $(TERRAFORM_DIR)/$(TF_LAYER) && terraform destroy

.PHONY: tf-output
tf-output: ## Terraform output for selected layer
	cd $(TERRAFORM_DIR)/$(TF_LAYER) && terraform output

#--------------------------------------------
# vault - set terraform credentials
#--------------------------------------------

.PHONY: vault-tf-creds
vault-tf-creds: ## Export Vault credentials for Terraform (run with: eval $$(make vault-tf-creds))
	@echo "export TF_VAR_proxmox_api_url=\$$(vault kv get -field=api-url kv/proxmox)"
	@echo "export TF_VAR_proxmox_api_token_id=\$$(vault kv get -field=api-token-id kv/proxmox)"
	@echo "export TF_VAR_proxmox_api_token_secret=\$$(vault kv get -field=api-token-secret kv/proxmox)"

#--------------------------------------------
# helpers
#--------------------------------------------

.PHONY: clean
clean: ## Clean up cache directories
	@find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	@find . -type d -name "packer_cache" -prune -exec rm -rf {} \;

.PHONY: clean-locks
clean-locks: ## Clean up terraform lock files
	@find . -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;

.PHONY: clean-all
clean-all: clean clean-locks ## Clean all caches and locks
