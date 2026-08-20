.PHONY: help test docs docs-html \
        run-personal run-business run-combined \
        build-personal build-business build-combined build-all \
        build-personal-apk build-business-apk build-combined-apk \
        clean

# Default target
.DEFAULT_GOAL := help

help: ## Display available commands
	@echo "Budget App - Build & Run Commands by Edition"
	@echo "============================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

## --- Run Local Dev Server / Desktop App ---

run-personal: ## Run Personal Edition locally
	flutter run -d linux --dart-define=RELEASE_EDITION=personal

run-business: ## Run Business Edition locally
	flutter run -d linux --dart-define=RELEASE_EDITION=business

run-combined: ## Run Combined Edition locally (Default)
	flutter run -d linux --dart-define=RELEASE_EDITION=combined

## --- Desktop Builds (Linux) ---

build-personal: ## Build Linux release executable for Personal Edition
	flutter build linux --release --dart-define=RELEASE_EDITION=personal

build-business: ## Build Linux release executable for Business Edition
	flutter build linux --release --dart-define=RELEASE_EDITION=business

build-combined: ## Build Linux release executable for Combined Edition
	flutter build linux --release --dart-define=RELEASE_EDITION=combined

build-all: build-personal build-business build-combined ## Build Linux release executables for all 3 editions

## --- Mobile Builds (Android APK) ---

build-personal-apk: ## Build Android APK for Personal Edition
	flutter build apk --release --dart-define=RELEASE_EDITION=personal

build-business-apk: ## Build Android APK for Business Edition
	flutter build apk --release --dart-define=RELEASE_EDITION=business

build-combined-apk: ## Build Android APK for Combined Edition
	flutter build apk --release --dart-define=RELEASE_EDITION=combined

## --- Testing & Quality Assurance ---

test: ## Run unit, widget, and integration tests
	flutter test

## --- Documentation & Diagrams ---

generate-diagrams: ## Generate Mermaid architecture diagrams via Python script
	python3 docs/generate_diagrams.py

docs-html: generate-diagrams ## Build Sphinx HTML documentation using uv
	uv run --with sphinx --with myst-parser --with sphinxcontrib-mermaid sphinx-build -b html docs docs/_build/html

docs: docs-html ## Alias for building HTML documentation

clean: ## Clean Flutter build cache and Sphinx output
	flutter clean
	rm -rf docs/_build
