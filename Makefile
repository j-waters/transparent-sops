PREFIX ?= /usr/local
LIB_DIR = $(PREFIX)/lib/transparent-sops
BIN_DIR = $(PREFIX)/bin

.PHONY: install uninstall test

test:
	@echo "Running integration tests..."
	@./test.sh

installcheck:
	@echo "Verifying installation..."
	@TOOL_PATH="$(BIN_DIR)/transparent-sops" ./test.sh

install:
	@echo "Installing transparent-sops to $(LIB_DIR)..."
	@mkdir -p $(LIB_DIR)/filters
	@cp transparent-sops $(LIB_DIR)/
	@cp filters/*.sh $(LIB_DIR)/filters/
	@chmod +x $(LIB_DIR)/transparent-sops
	@chmod +x $(LIB_DIR)/filters/*.sh
	@echo "Creating symlink in $(BIN_DIR)..."
	@mkdir -p $(BIN_DIR)
	@ln -sf $(LIB_DIR)/transparent-sops $(BIN_DIR)/transparent-sops
	@echo "Installation complete. You can now use 'transparent-sops'."

uninstall:
	@echo "Uninstalling transparent-sops..."
	@rm -f $(BIN_DIR)/transparent-sops
	@rm -rf $(LIB_DIR)
	@echo "Uninstallation complete."
