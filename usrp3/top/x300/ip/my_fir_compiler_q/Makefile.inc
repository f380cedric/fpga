#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_FIR_COMPILER_Q_SRCS = $(IP_BUILD_DIR)/my_fir_compiler_q/my_fir_compiler_q.xci

IP_MY_FIR_COMPILER_Q_OUTS = $(addprefix $(IP_BUILD_DIR)/my_fir_compiler_q/, \
my_fir_compiler_q.xci.out \
synth/my_fir_compiler_q.v \
)

$(IP_MY_FIR_COMPILER_Q_SRCS) $(IP_MY_FIR_COMPILER_Q_OUTS) : $(IP_DIR)/my_fir_compiler_q/my_fir_compiler_q.xci
	$(call BUILD_VIVADO_IP,my_fir_compiler_q,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
