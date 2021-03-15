#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_FIR_COMPILER_I_SRCS = $(IP_BUILD_DIR)/my_fir_compiler_i/my_fir_compiler_i.xci

IP_MY_FIR_COMPILER_I_OUTS = $(addprefix $(IP_BUILD_DIR)/my_fir_compiler_i/, \
my_fir_compiler_i.xci.out \
synth/my_fir_compiler_i.v \
)

$(IP_MY_FIR_COMPILER_I_SRCS) $(IP_MY_FIR_COMPILER_I_OUTS) : $(IP_DIR)/my_fir_compiler_i/my_fir_compiler_i.xci
	$(call BUILD_VIVADO_IP,my_fir_compiler_i,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
