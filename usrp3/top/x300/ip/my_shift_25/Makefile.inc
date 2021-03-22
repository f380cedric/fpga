#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_SHIFT_25_SRCS = $(IP_BUILD_DIR)/my_shift_25/my_shift_25.xci

IP_MY_SHIFT_25_OUTS = $(addprefix $(IP_BUILD_DIR)/my_shift_25/, \
my_shift_25.xci.out \
synth/my_shift_25.v \
)

$(IP_MY_SHIFT_25_SRCS) $(IP_MY_SHIFT_25_OUTS) : $(IP_DIR)/my_shift_25/my_shift_25.xci
	$(call BUILD_VIVADO_IP,my_shift_25,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
