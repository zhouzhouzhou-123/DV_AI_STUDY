
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

TC      ?= hello_world
BOOT    ?= APROM
DEFINE  ?=  #RUN_CPU0+TEST

################################################################################
# Target CPU option
#  - CPU option is always kite
CPU     = cortex-m3
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
# sv define : define from sv(m script)
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
STARTUP_FILE	:= ./system/startup.s
################################################################################

################################################################################
# include files(.h)
INCLUDE_FILE	:= ./common/pcommon.h

# include directory
INCLUDE_DIR := -I ./driver/ -I ./register/ -I ./common/ -I ./core/

INCLUDE_FILE_LIST := $(foreach item, $(INCLUDE_FILE),-include $(item))
################################################################################

################################################################################
# link file
ifeq ($(BOOT), )
    LINKER_FILE     := ./link/link.ld
else
    LINKER_FILE     := ./link/link_$(BOOT).ld
endif
################################################################################

################################################################################
# main.c
ifeq ($(findstring "/", $(TC)), )
    TC_FILE_PATH = ../testcases/$(TC)
else
    TC_FILE_PATH = $(TC)
endif
TC_SOURCE_FILE  := $(TC_FILE_PATH)/main.c
################################################################################

################################################################################
# GGC toolchain executables
GCC_TOOL_PATH   := /eda/tools/gcc/arm/2021.10/bin
GCC_TOOLCHAIN   := arm-none-eabi

ASM             := $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-as
GCC             := $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-gcc
LD              := $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-ld
ELF2HEX         := $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-objcopy
DIS             := $(GCC_TOOL_PATH)/$(GCC_TOOLCHAIN)-objdump
################################################################################

################################################################################
# GGC options
GCC_TARGET  := -DGCC
GCC_OPTS    := $(GCC_TARGET) -mtune=$(CPU) -Wall -MMD -g -Os -Wall  -DITERATIONS=20 $(INCLUDE_DIR)

GCC_OPTS += $(GCC_DEFINE)
################################################################################

################################################################################
# LD options
LD_OPTS     := -T $(LINKER_FILE)
# LD_OPTS     += -Wl,-Map=map.rpt,-lgcc,-lc,-lnosys -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs
################################################################################

################################################################################
# DIS options
DISSAMBLER_OPTS := --disassemble-all --disassemble-zeroes
################################################################################

################################################################################
# ELF2HEX options
ELF2HEX_OPTS    := -O ihex
################################################################################

################################################################################
DIS_DIR = dis
ELF_DIR = elf
HEX_DIR = hex

MKDIR_DIS = $(shell if [ -d $(DIS_DIR) ];   then echo "dis directory exist,no need mkdir";  else mkdir $(DIS_DIR);fi;)
MKDIR_ELF = $(shell if [ -d $(ELF_DIR) ];   then echo "elf directory exist,no need mkdir";  else mkdir $(ELF_DIR);fi;)
MKDIR_HEX = $(shell if [ -d $(HEX_DIR) ];   then echo "hex directory exist,no need mkdir";  else mkdir $(HEX_DIR);fi;)

TC_HEX_FILE	= $(HEX_DIR)/$(TC).hex
TC_ELF_FILE	= $(ELF_DIR)/$(TC).elf
TC_DIS_FILE	= $(DIS_DIR)/$(TC).dis
################################################################################

################################################################################
# get all *.c in current & sub path
ALL_C_FILES = $(shell find ./common -name "*.c")
ALL_C_FILES += $(shell find ./core -name "*.c")
ALL_C_FILES += $(shell find ./driver -name "*.c")
ALL_C_FILES += $(shell find ./register -name "*.c")
ALL_C_FILES += $(shell find ./system -name "*.c")
ALL_C_FILES += $(TC_SOURCE_FILE)
################################################################################

all:    getdir  $(TC_HEX_FILE)

getdir:
	@echo $(MKDIR_DIS)
	@echo $(MKDIR_ELF)
	@echo $(MKDIR_HEX)

$(TC_HEX_FILE) : $(TC_ELF_FILE)
	@echo " [.elf to .hex ] $@ <----($^)"
	$(ELF2HEX) $(ELF2HEX_OPTS) $< $@

$(TC_ELF_FILE) : $(STARTUP_FILE) $(INCLUDE_FILE) $(ALL_C_FILES)
	@echo " [ELF             ] $@ <----($^)"
	$(GCC) $(GCC_OPTS) $(INCLUDE_FILE_LIST) $^ $(LD_OPTS) -o $@
	@echo " [DIS             ] $(TC_DIS_FILE) <----($@)"
	$(DIS) $(DISSAMBLER_OPTS) $@ > $(TC_DIS_FILE)

clean:
	rm -f $(DIS_DIR)/* $(HEX_DIR)/* $(ELF_DIR)/*

-include $(TC_ELF_FILE:.elf=.d)
