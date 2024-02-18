init:
	terraform init

plan: init
	terraform plan -out terraform.plan

apply:
	terraform apply -auto-approve terraform.plan

destroy: init
	terraform destroy

clean:
	@rm -fR .terraform/terraform.tfstate
	@rm -fR .terraform/modules
	@rm -fR terraform.plan
	@rm -fR build