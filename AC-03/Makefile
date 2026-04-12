FLEX ?= flex
CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -std=c11

BUILD_DIR := build
BIN_DIR := bin

EXAMPLE_SRCS := \
	examples/exemplo0.l \
	examples/exemplo1.l \
	examples/exemplo2.l \
	examples/exemplo3.l \
	examples/exemplo4.l

ID_SRCS := ids/c_identifiers.l

EXAMPLE_BINS := \
	$(BIN_DIR)/exemplo0 \
	$(BIN_DIR)/exemplo1 \
	$(BIN_DIR)/exemplo2 \
	$(BIN_DIR)/exemplo3 \
	$(BIN_DIR)/exemplo4

ID_BINS := $(BIN_DIR)/c_identifiers

ALL_BINS := $(EXAMPLE_BINS) $(ID_BINS)

.PHONY: all clean test dirs

all: $(ALL_BINS)

dirs:
	mkdir -p $(BUILD_DIR) $(BIN_DIR)

$(BIN_DIR)/%: examples/%.l | dirs
	$(FLEX) -o $(BUILD_DIR)/$*.c $<
	$(CC) $(CFLAGS) $(BUILD_DIR)/$*.c -o $@

$(BIN_DIR)/%: ids/%.l | dirs
	$(FLEX) -o $(BUILD_DIR)/$*.c $<
	$(CC) $(CFLAGS) $(BUILD_DIR)/$*.c -o $@

test: all
	./tests/run_tests.sh

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
