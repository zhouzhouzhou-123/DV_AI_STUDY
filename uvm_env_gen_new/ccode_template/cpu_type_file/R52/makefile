#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#            (C) COPYRIGHT 2014-2021 ARM Limited or its affiliates.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited or its affiliates.
#
#      SVN Information
#
#      Checked In          : $Date: 2017-03-27 17:56:55 +0100 (Mon, 27 Mar 2017) $
#
#      Revision            : $Revision: 363528 $
#
#      Release Information : Cortex-R52 Processor MP040-r1p4-00rel0
#
#-----------------------------------------------------------------------------

TC		?= hello_world
BOOT	?= BOOTROM

DEFINE	?= RUN_CPU0

################################################################################
# Target CPU and FPU option
#  - CPU option is always kite
#  - When processor does not support NEON SIMD operations, tests should be built using FPU = fp-armv8
#  - When processor supports NEON SIMD operations, tests should be built using FPU = neon-fp-armv8
#  - Default is FPU = neon-fp-armv8
FPU  	= neon-fp-armv8
CPU  	= cortex-r52
MARCH	= armv8-a
################################################################################

################################################################################
# ccode define
GCC_DEFINE ?=
ifneq ($(DEFINE), )
ifneq ($(findstring +, $(DEFINE)), )
	SUB_DEFINE = $(subst +, -D,$(DEFINE))
	GCC_DEFINE += -D$(SUB_DEFINE)
else
	GCC_DEFINE += -D$(DEFINE)
endif
endif
################################################################################

################################################################################
# sv define
SV_DEFINE ?=
ifneq ($(SV_DEFINE), )
ifneq ($(findstring +, $(SV_DEFINE)), )
	SUB_DEFINE = $(subst +, -D,$(SV_DEFINE))
	GCC_DEFINE += -D$(SUB_DEFINE)
else
	GCC_DEFINE += -D$(SV_DEFINE)
endif
endif

################################################################################

################################################################################
# startup.s
STARTUP_FILE	:= ./system/bootcode.s ./system/stackheap.s ./system/vectors.s
################################################################################

################################################################################
# include files
C_FILES			:= $(shell find ./ -type f -name "*.c")
################################################################################

################################################################################
# link file
ifeq ($(BOOT), )
	LINKER_FILE		:= ./link/link.ld
else
	LINKER_FILE		:= ./link/link_$(BOOT).ld
endif
################################################################################

################################################################################
# main.c
ifeq ($(findstring "/", $(TC)), )
	TC_FILE_PATH = ../testcases/$(TC)
else
	TC_FILE_PATH = $(TC)
endif
TC_SOURCE_FILE	:= $(TC_FILE_PATH)/main.c
################################################################################

################################################################################
# include directory
INCLUDE_DIR		:= -I ./driver/ -I ./register/ -I ./common/ -I ./core/
################################################################################

################################################################################
# GGC toolchain executables
GCC_TOOL_PATH   := /eda/tools/gcc/arm/2021.10/bin
GCC_TOOLCHAIN   := arm-none-eabi

ASM         	:= $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-as
GCC            	:= $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-gcc
LD				:= $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-ld
ELF2HEX			:= $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-objcopy
DIS				:= $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-objdump
################################################################################

################################################################################
# GGC options
GCC_TARGET	:= -march=$(MARCH) -mfpu=$(FPU)  -DGCC
GCC_OPTS    := $(GCC_TARGET) -mtune=$(CPU) -Wall -g -O0 -Wall  -DITERATIONS=20 $(INCLUDE_DIR)
################################################################################

################################################################################
# LD options
LD_OPTS	:= -T $(LINKER_FILE)
#LD_OPTS	+= -Wl,-Map=map.rpt,-lgcc,-lc,-lnosys -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs
################################################################################

################################################################################
# DIS options
DISSAMBLER_OPTS			:= --disassemble-all --disassemble-zeroes
################################################################################

################################################################################
# ELF2HEX options
ELF2HEX_OPTS      	:= -O ihex
################################################################################

# Other options
# Add PMUs counter to the ELF files if ACTIVATE_PMU is defined (only tests controlled by benchmark.h Dhrystone and Coremark)
ifdef ACTIVATE_PMU
	GCC_OPTS	+= -DACTIVATE_PMU
endif

# Run tests for all CPUs.
# Default is that only CPU0 runs the test, the other ones go to WFI (with exception of Hello World, that runs from all CPUs)
ifdef RUN_ALL_CPUS
	GCC_OPTS	+= -DRUN_ALL_CPUS
endif

################################################################################
DIS_DIR = dis
ELF_DIR = elf
HEX_DIR = hex

MKDIR_DIS = $(shell if [ -d $(DIS_DIR) ]; 	then echo "dis directory exist,no need mkdir";	else mkdir $(DIS_DIR);fi;)
MKDIR_ELF = $(shell if [ -d $(ELF_DIR) ]; 	then echo "elf directory exist,no need mkdir";	else mkdir $(ELF_DIR);fi;)
MKDIR_HEX = $(shell if [ -d $(HEX_DIR) ]; 	then echo "hex directory exist,no need mkdir";	else mkdir $(HEX_DIR);fi;)
################################################################################

all:	getdir	$(TC).hex	postp	clean

getdir:
	@echo $(MKDIR_DIS)
	@echo $(MKDIR_ELF)
	@echo $(MKDIR_HEX)

$(TC).hex : $(TC).elf
	@echo " [.elf to .hex ] $@ <----($^)"
	$(ELF2HEX) $(ELF2HEX_OPTS) $< $@

$(TC).elf : $(STARTUP_FILE) $(C_FILES) $(TC_SOURCE_FILE)
	@echo " [ELF             ] $@ <----($^)"
	$(GCC) $(GCC_DEFINE) $(GCC_OPTS) $^ $(LD_OPTS) -o $@

	@echo " [DIS             ] $@ <----($^)"
	$(DIS) $(DISSAMBLER_OPTS) $(TC).elf > $(TC).dis

postp:
	mv $(TC).elf  	./elf/
	mv $(TC).dis  	./dis/
	mv $(TC).hex  	./hex/

clean:
	rm -f *.hex *.elf *.dis *.bin *.lst *.o *.rpt
