# Copyright 2020 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

############################################################
# Targets
TARGETS += frep_single hello_world ssr_simple ssr_inst_check 
TARGETS += ssr_multi_use ssr_intrinsic sdma_simple frep_inference 

RUNTIME_SRCS    = $(CRT0)

############################################################
# Dirs
BUILD  					= bin
DUMP 						= dump
LOG 						= log

############################################################
# Callables
BANSHEE 			?= banshee
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

OPT 					 ?= 1
FLAGS           = -O$(OPT) -g -Wall -mcpu=snitch -mcmodel=medany -static -std=gnu99 
FLAGS          += -ffast-math -fno-common -fno-builtin-printf
FLAGS          += -mllvm -enable-misched=false 
FLAGS          += -Xclang -disable-O0-optnone

BANSHEE_FLAGS   = --num-cores 1 --no-opt-llvm --no-opt-jit

# Debugging
# FLAGS    += -save-stats
# FLAGS    += -mllvm -debug-only=snitch-freploops
# FLAGS    += -mllvm -print-before=snitch-freploops
# FLAGS    += -mllvm -debug-only=riscv-lower

CFLAGS        += -DBANSHEE

CCFLAGS   = $(FLAGS) $(CFLAGS) $(EXTRAFLAGS) $(INC)
LDFLAGS   = -fuse-ld=lld -static -lm -nostartfiles -T$(LD_SCRIPT)
OBJDUMP_FLAGS = --mcpu=snitch --debug-vars

############################################################
# build
############################################################

all: $(addprefix $(BUILD)/, $(TARGETS))
$(BUILD)/%: src/%.c $(RUNTIME_SRCS)
	mkdir -p $(shell dirname $@) $(DUMP)
	$(CC) $(CCFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJDUMP) $(OBJDUMP_FLAGS) -S $@ > $(DUMP)/$*.list
	$(OBJDUMP) $(OBJDUMP_FLAGS) -D $@ > $(DUMP)/$*.dump
	$(STRIP) $@ -g -S -d --strip-debug

clean:
	rm -rf $(BUILD) $(LOG) $(DUMP)

############################################################
# test
############################################################

test:
	@fails=0; \
	successes=0; \
	for test in $(TARGETS) ; do \
		$(BANSHEE) $(BANSHEE_FLAGS) $(BUILD)/$$test; \
		TMP=$${PIPESTATUS[0]}; \
		if [ $$TMP -eq 0 ]; then \
				echo -e "$$test exit code: $$TMP: \033[0;32mSUCCESS\033[0m" 1>&2; \
				successes=`expr $$successes + 1`; \
		else \
				echo -e "$$test exit code: $$TMP: \033[0;31mFAILED\033[0m" 1>&2; \
				fails=`expr $$fails + 1`; \
		fi; \
	done; \
	echo "Total failed: $$fails/`expr $$fails + $$successes`"; \
	exit $$fails

############################################################
# phony
############################################################
.PHONY: all clean test
