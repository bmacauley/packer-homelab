SHELL := $(shell which bash)

.DEFAULT_GOAL := help
.PHONY: help init plan apply destroy output clean

help: ## Show Help
	@grep '^[a-zA-Z]' $(MAKEFILE_LIST) | \
	sort | \
	awk -F ':.*?## ' 'NF==2 {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform working directory
	terraform init

plan: init ## Calculate Terraform plan of changes
	terraform plan -lock=false

apply: init ## Apply Terraform changes
	terraform apply -lock=false

destroy: ## Destroy all Terraform-managed resources
	terraform destroy -lock=false

output: ## Print Terraform outputs as JSON
	terraform output -json

clean: ## Remove Terraform state and cache files
	rm -rf .terraform*
	rm -rf *.tfstate*
