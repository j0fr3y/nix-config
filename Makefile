.PHONY: help desktop server home-desktop home-server update check clean bootstrap

HOSTNAME ?= $(shell hostname)
TYPE ?= desktop

help: ## Show this help message
	@echo "Modular NixOS Configuration"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [HOSTNAME=name]"
	@echo ""
	@echo "Current hostname: $(HOSTNAME)"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

desktop: ## Build and switch to desktop NixOS configuration
	sudo nixos-rebuild switch --flake .#desktop

server: ## Build and switch to server NixOS configuration
	sudo nixos-rebuild switch --flake .#server

home-desktop: ## Build and switch to desktop home-manager configuration
	home-manager switch --flake .#user@desktop

home-server: ## Build and switch to server home-manager configuration
	home-manager switch --flake .#user@server

update: ## Update flake inputs
	nix flake update

check: ## Check flake configuration
	nix flake check

clean: ## Clean old generations and garbage collect
	sudo nix-collect-garbage -d
	home-manager expire-generations "-7 days"

test-desktop: ## Test desktop configuration without switching
	sudo nixos-rebuild test --flake .#desktop

test-server: ## Test server configuration without switching
	sudo nixos-rebuild test --flake .#server

build-desktop: ## Build desktop configuration without activating
	sudo nixos-rebuild build --flake .#desktop

build-server: ## Build server configuration without activating
	sudo nixos-rebuild build --flake .#server

switch: ## Switch to configuration for current hostname
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

bootstrap: ## Bootstrap a new host (interactive)
	@bash scripts/bootstrap.sh

list-hosts: ## List all configured hosts
	@echo "Configured hosts:"
	@ls -1 hosts/ | grep -v common | grep -v hardware-configuration.nix.example

add-host: ## Add a new host to the configuration (HOSTNAME=name TYPE=desktop|server)
	@echo "Creating host: $(HOSTNAME) (type: $(TYPE))"
	@mkdir -p hosts/$(HOSTNAME)
	@echo "Run 'make bootstrap' for interactive setup or manually create configuration"
