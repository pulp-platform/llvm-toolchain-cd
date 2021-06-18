# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

############################################################
# Targets
TARGETS += frep_single hello_world ssr_simple ssr_inst_check 
TARGETS += ssr_multi_use ssr_intrinsic sdma_simple frep_inference 

# Tests that are ignored from exit code check
IGNORE_TESTS += frep_inference

RUNTIME_SRCS    = $(CRT0)

############################################################
# Dirs
BUILD  					= bin
DUMP 						= dump
LOG 						= log

############################################################
# Callables
BANSHEE 			?= banshee
SPIKE         ?= spike-dasm
PREFIX        ?= 

############################################################
# Toolchain

LD_SCRIPT       = link.ld
CRT0 					  = runtime/crt0.S
INC             = -Iruntime

CC 				= $(PREFIX)clang
ASM 			= $(PREFIX)clang
LD 				= $(PREFIX)clang
OBJDUMP   = $(PREFIX)llvm-objdump
STRIP     = $(PREFIX)llvm-strip
SIZE     	= $(PREFIX)llvm-size --radix=16 
LLVM_CONFIG = $(PREFIX)llvm-config

OPT 					 ?= 0
FLAGS           = -O$(OPT) -g -Wall -mcpu=snitch -mcmodel=medany -static -std=gnu99 
FLAGS          += -ffast-math -fno-common -fno-builtin-printf
FLAGS          += -mllvm -enable-misched=false 
FLAGS          += -Xclang -disable-O0-optnone

BANSHEE_FLAGS   = --num-cores 1 --no-opt-llvm --no-opt-jit
SNITCH_LOG     ?= info

# Debugging
# FLAGS    += -save-stats
# FLAGS    += -mllvm -debug-only=snitch-freploops
# FLAGS    += -mllvm -print-before=snitch-freploops
# FLAGS    += -mllvm -debug-only=riscv-lower
# FLAGS    += -mllvm -print-after-all
# FLAGS    += -mllvm -debug-only=riscv-ssr -mllvm -print-before=riscv-ssr
# FLAGS    += -mllvm -ssr-noregmerge

CFLAGS        += -DBANSHEE

CCFLAGS   = $(FLAGS) $(CFLAGS) $(EXTRAFLAGS) $(INC)
LDFLAGS   = -fuse-ld=lld -static -lm -nostartfiles -T$(LD_SCRIPT)
OBJDUMP_FLAGS = --mcpu=snitch --debug-vars

############################################################
# build
############################################################

version:
	@echo "== Version ========================"
	@$(CC) --version
	@$(LLVM_CONFIG) --version
	@echo "==================================="

all: $(addprefix $(BUILD)/, $(TARGETS))
$(BUILD)/%: src/%.c $(RUNTIME_SRCS)
	mkdir -p $(shell dirname $@) $(DUMP)
	$(CC) $(CCFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJDUMP) $(OBJDUMP_FLAGS) -S $@ > $(DUMP)/$*.list
	$(OBJDUMP) $(OBJDUMP_FLAGS) -D $@ > $(DUMP)/$*.dump
	$(STRIP) $@ -g -S -d --strip-debug

clean:
	rm -rf $(BUILD) $(LOG) $(DUMP)
format:
	clang-format -i --verbose --style=file src/*
############################################################
# test
############################################################

test: $(addprefix $(BUILD)/, $(TARGETS))
	@mkdir -p $(LOG); fails=0; successes=0; \
	for test in $(TARGETS) ; do \
		SNITCH_LOG=$(SNITCH_LOG) $(BANSHEE) $(BANSHEE_FLAGS) $(BUILD)/$$test --trace 2>$(LOG)/$$test 1>$(LOG)/$$test.trace; \
		TMP=$${PIPESTATUS[0]}; \
		$(SPIKE) < $(LOG)/$$test.trace > $(LOG)/$$test.txt ||:; \
		if [[ "$(IGNORE_TESTS)" == *$$test* ]]; then \
			echo -e "$$test exit code: $$TMP: \033[0;33mignored\033[0m" 1>&2; \
		elif [ $$TMP -eq 0 ]; then \
				echo -e "$$test exit code: $$TMP: \033[0;32mSUCCESS\033[0m" 1>&2; \
				successes=`expr $$successes + 1`; \
		else \
				echo -e "$$test exit code: $$TMP: \033[0;31mFAILED\033[0m" 1>&2; \
				fails=`expr $$fails + 1`; \
		fi; \
	done; \
	echo "Total failed: $$fails/`expr $$fails + $$successes`"; \
	exit $$fails

test-%: $(BUILD)/%
	mkdir -p $(LOG); test=$*; \
	SNITCH_LOG=$(SNITCH_LOG) $(BANSHEE) $(BANSHEE_FLAGS) $(BUILD)/$$test --trace 2>$(LOG)/$$test 1>$(LOG)/$$test.trace; \
	TMP=$${PIPESTATUS[0]}; \
	$(SPIKE) < $(LOG)/$$test.trace > $(LOG)/$$test.txt ||:; \
	if [ $$TMP -eq 0 ]; then \
			echo -e "$$test exit code: $$TMP: \033[0;32mSUCCESS\033[0m" 1>&2; \
	else \
			echo -e "$$test exit code: $$TMP: \033[0;31mFAILED\033[0m" 1>&2; \
			fails=`expr $$fails + 1`; \
	fi;


############################################################
# phony
############################################################
.PHONY: all clean test version format
