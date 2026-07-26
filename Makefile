.PHONY: help test docs \
        run-personal run-business run-combined \
        build-personal build-business build-combined build-all \
        build-personal-apk build-business-apk build-combined-apk \
        clean

.DEFAULT_GOAL := help

help:
	@$(MAKE) -C budget_app help

run-personal:
	@$(MAKE) -C budget_app run-personal

run-business:
	@$(MAKE) -C budget_app run-business

run-combined:
	@$(MAKE) -C budget_app run-combined

build-personal:
	@$(MAKE) -C budget_app build-personal

build-business:
	@$(MAKE) -C budget_app build-business

build-combined:
	@$(MAKE) -C budget_app build-combined

build-all:
	@$(MAKE) -C budget_app build-all

build-personal-apk:
	@$(MAKE) -C budget_app build-personal-apk

build-business-apk:
	@$(MAKE) -C budget_app build-business-apk

build-combined-apk:
	@$(MAKE) -C budget_app build-combined-apk

test:
	@$(MAKE) -C budget_app test

docs:
	@$(MAKE) -C budget_app docs

clean:
	@$(MAKE) -C budget_app clean
