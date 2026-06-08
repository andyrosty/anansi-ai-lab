.PHONY: help ping preflight bootstrap syntax-check dry-run

INVENTORY ?= inventory/hosts.yml
GROUP ?= ai_lab
PLAYBOOK_DIR ?= playbooks

ANSIBLE ?= ansible
ANSIBLE_PLAYBOOK ?= ansible-playbook
ANSIBLE_ARGS ?=
PLAYBOOK_ARGS ?=

help:
	@printf "Available targets:\n"
	@printf "  make ping           # ansible ping to $(GROUP)\n"
	@printf "  make preflight      # run preflight checks\n"
	@printf "  make bootstrap      # bootstrap AI lab hosts\n"
	@printf "  make syntax-check   # validate playbook syntax\n"
	@printf "  make dry-run        # check-mode run for preflight/bootstrap\n"
	@printf "\nOverrides:\n"
	@printf "  INVENTORY=inventory/hosts.yml GROUP=ai_lab\n"
	@printf "  ANSIBLE_ARGS='--limit ai-lab-01'\n"
	@printf "  PLAYBOOK_ARGS='--ask-become-pass --limit ai-lab-01'\n"

ping:
	$(ANSIBLE) -i $(INVENTORY) $(GROUP) -m ping $(ANSIBLE_ARGS)

preflight:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/preflight.yml $(PLAYBOOK_ARGS)

bootstrap:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/bootstrap.yml $(PLAYBOOK_ARGS)

syntax-check:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/preflight.yml --syntax-check
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/bootstrap.yml --syntax-check

dry-run:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/preflight.yml --check --diff $(PLAYBOOK_ARGS)
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/bootstrap.yml --check --diff $(PLAYBOOK_ARGS)
