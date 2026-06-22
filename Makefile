.PHONY: help ping preflight bootstrap swap ollama status syntax-check lint dry-run

.DEFAULT_GOAL := help

INVENTORY ?= inventory/hosts.yml
GROUP ?= ai_lab
PLAYBOOK_DIR ?= playbooks
PLAYBOOKS ?= preflight bootstrap swap ollama status

ANSIBLE ?= ansible
ANSIBLE_PLAYBOOK ?= ansible-playbook
ANSIBLE_ARGS ?=
PLAYBOOK_ARGS ?=

help:
	@printf "Available targets:\n"
	@printf "  make ping           # ansible ping to $(GROUP)\n"
	@printf "  make preflight      # run preflight checks\n"
	@printf "  make bootstrap      # bootstrap AI lab hosts\n"
	@printf "  make swap           # create and enable swap\n"
	@printf "  make ollama         # install and test Ollama\n"
	@printf "  make status         # check runtime AI lab status\n"
	@printf "  make syntax-check   # validate playbook syntax\n"
	@printf "  make lint           # run ansible-lint checks\n"
	@printf "  make dry-run        # check-mode run for all playbooks\n"
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

swap:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/swap.yml $(PLAYBOOK_ARGS)

ollama:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/ollama.yml $(PLAYBOOK_ARGS)

status:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/status.yml $(PLAYBOOK_ARGS)

syntax-check:
	@for pb in $(PLAYBOOKS); do \
		$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/$$pb.yml --syntax-check || exit $$?; \
	done

lint:
	ansible-lint

dry-run:
	@for pb in $(PLAYBOOKS); do \
		$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK_DIR)/$$pb.yml --check --diff $(PLAYBOOK_ARGS) || exit $$?; \
	done
