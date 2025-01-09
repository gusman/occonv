SHELL := bash

CP = cp
ECHO = echo -e 
RM = rm
MV = mv
TAR = tar
CURL = curl
MKDIR = mkdir -p
PYTHON3 = python3
TOUCH = touch
SOURCE = source


OC_VERSION = 5.0.0
OC_PKG = v$(OC_VERSION).tar.gz
OC_MODULES_DIR = public-$(OC_VERSION)
YANG_MODULES_DIR = yang_modules

VENV_DIR = ./.venv_tmp

OC_BIND_DIR = ./occonv/oc/bind
OC_YANG_MODULES = \
	"openconfig-platform" \
	"openconfig-interfaces" \
	"openconfig-network-instance" 

.PHONY: all clean new_bind

new_bind: download extract venv ocbind clean

clean:
	@$(ECHO) "\n[Pre clean artefacts...]"
	$(RM) -f $(OC_PKG)
	$(RM) -rf $(VENV_DIR)
	$(RM) -rf $(OC_MODULES_DIR)
	$(RM) -rf $(YANG_MODULES_DIR)

download:
	@$(ECHO) "\n[Download oc yang modules package...]"
	$(RM) -f $(OC_PKG)
	$(CURL) -LO https://github.com/openconfig/public/archive/refs/tags/$(OC_PKG)

extract: download
	@$(ECHO) "\n[Extract oc yang modules package...]"
	$(TAR) zxf $(OC_PKG) 

	$(MKDIR) $(YANG_MODULES_DIR)
	$(CP) $(OC_MODULES_DIR)/release/models/*.yang $(YANG_MODULES_DIR)/.
	$(CP) -R $(OC_MODULES_DIR)/release/models/*/*.yang $(YANG_MODULES_DIR)/.
	$(CP) $(OC_MODULES_DIR)/third_party/ietf/*.yang $(YANG_MODULES_DIR)/.

venv:
	@$(ECHO) "\n[Create .venv virtual environment...]"
	$(RM) -rf $(VENV_DIR)
	$(PYTHON3) -m venv $(VENV_DIR)
	$(SOURCE) $(VENV_DIR)/bin/activate && pip install -r requirements.txt

ocbind: extract venv 
	@$(ECHO) "\n[Construct open config python bind...]"

ifneq (, $(wildcard $(OC_BIND_DIR)/__init__.py))
	$(CP) $(OC_BIND_DIR)/__init__.py ./__init__.py.tmp
	$(RM) -rf $(OC_BIND_DIR)/*
	$(MV) ./__init__.py.tmp $(OC_BIND_DIR)/__init__.py
endif

	$(eval PYBIND_PLUGIN_DIR = \
		$(shell $(SOURCE) $(VENV_DIR)/bin/activate \
			&&  python -c 'import pyangbind; import os; print ("{}/plugin".format(os.path.dirname(pyangbind.__file__)))'))

	for m in $(OC_YANG_MODULES); do \
		bind_name=`echo $$m | sed s/\-/_/g`; \
		$(SOURCE) $(VENV_DIR)/bin/activate  \
			&& pyang --plugindir $(PYBIND_PLUGIN_DIR) \
				-f pybind -o $(OC_BIND_DIR)/$$bind_name.py \
				-p $(YANG_MODULES_DIR) \
				$(YANG_MODULES_DIR)/$$m.yang; \
	done



