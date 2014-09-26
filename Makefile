#!/usr/bin/make -f
# -------------------------------------------------------------------------
# This Makefile is destined to ease the work with the infrastructure repo,
# especially when working with Vagrant: It contains wildcard targets for the
# most common Vagrant commands ($box.$operation) that ensure each operation
# is logged properly. This eases reporting, reproducing and debugging any
# issues that may arise.
# In addition, there are a set of additional targets that perform actions
# specific to the repo, such as invocation of the ensure_dependencies.py 
# script and the creation of the modules/private resource when necessary.
# -------------------------------------------------------------------------

# Phony targets are always considered out-of-date.
.PHONY: ensure_dependencies.py prepare clean distclean

# The first target is also the default one.
.DEFAULT_GOAL = prepare

# -------------------------------------------------------------------------
# Recognized environment variables and their defaults
# -------------------------------------------------------------------------

# The python(1) executable to use. Note that it must be Python version 2!
PYTHON ?= python

# The Vagrant executable to use.
VAGRANT ?= vagrant

# -------------------------------------------------------------------------
# Common targets or "commands"
# -------------------------------------------------------------------------

# The prepare target is also the default goal. It ensures all prerequisites
# for development and testing are fulfilled.
prepare: \
	ensure_dependencies.py \
	modules/private

##
# The clean target removes any logs written so far.
clean:
	rm -rf "$(VAGRANT_LOG_PATH)"

##
# The obligatoric distclean target implies clean and, in addition, removes
# all submodules as well as the modules/private stub, if any.
distclean: clean
	$(MAKE) list-dependencies | while read module; do rm -rf "$$module"; done
	if [ -L "modules/private" ]; then rm "modules/private"; fi

# -------------------------------------------------------------------------
# Vagrant-specific utilities
# -------------------------------------------------------------------------

# The following variables are local to the Makefile and meant to decrease
# the amount of code being repeated in the %.command targets.
VAGRANT_LOG_PATH = .vagrant/logs
VAGRANT_LOG_APPEND = tee -a "$(VAGRANT_LOG_PATH)/$*.log"
VAGRANT_LOG_STANZA = echo "[`date` $@]" | $(VAGRANT_LOG_APPEND)

%.back: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) snapshot back "$*" 2>&1 | $(VAGRANT_LOG_APPEND)

%.destroy: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) destroy -f "$*" 2>&1 | $(VAGRANT_LOG_APPEND)

%.halt: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) halt "$*" 2>&1 | $(VAGRANT_LOG_APPEND)

%.provision: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) provision "$*" 2>&1 | $(VAGRANT_LOG_APPEND)

%.snapshot: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) snapshot take "$*" 2>&1 | $(VAGRANT_LOG_APPEND)

%.ssh: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) ssh "$*"

%.up: $(VAGRANT_LOG_PATH)
	@$(VAGRANT_LOG_STANZA)
	@$(VAGRANT) up "$*" 2>&1 | $(VAGRANT_LOG_APPEND)

# -------------------------------------------------------------------------
# Fragmental dependencies of other targets
# -------------------------------------------------------------------------

##
# The list-dependencies target is used internally to accumulate a newline-
# separated list of all external modules referenced in the dependencies file.
list-dependencies:
	@sed -n 's/^\s*\([a-z0-9][^    ]\+\)\s*=.*/\1/p' dependencies

# The ensure_dependencies.py target invokes the accompanying $(PYTHON)
# script of the same name for each dependency module not found in the local
# repository clone.
ensure_dependencies.py:
	$(MAKE) list-dependencies \
	| while read line; do \
	    if [ ! -e "$$line" ]; then \
	        $(PYTHON) "$@"; \
	        break; \
	    fi; \
	done

# The modules/private target ensures the private setup module being present.
# By default, it's using the development stub that ships with the repository.
# Please refer to the accompanying README.md file for more information.
modules/private:
	if [ ! -e "$@" ]; then ln -s private-stub "$@"; fi

# The $(VAGRANT_LOG_PATH) target ensures the destination for log files
# being present.
$(VAGRANT_LOG_PATH):
	mkdir -p "$@"

# -------------------------------------------------------------------------
# Miscellaneous targets
# -------------------------------------------------------------------------

# The Makefile target is an empty stub required when the Makefile is invoked
# as an executable script in another directory (see also the #!shebang line
# at the top).
Makefile:

