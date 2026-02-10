.PHONY: help desktop server home-desktop home-server update check clean

help: ## Show this help message
	@echo "Modular NixOS Configuration"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

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
