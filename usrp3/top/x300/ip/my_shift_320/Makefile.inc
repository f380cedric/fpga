#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_SHIFT_320_SRCS = $(IP_BUILD_DIR)/my_shift_320/my_shift_320.xci

IP_MY_SHIFT_320_OUTS = $(addprefix $(IP_BUILD_DIR)/my_shift_320/, \
my_shift_320.xci.out \
synth/my_shift_320.v \
)

$(IP_MY_SHIFT_320_SRCS) $(IP_MY_SHIFT_320_OUTS) : $(IP_DIR)/my_shift_320/my_shift_320.xci
	$(call BUILD_VIVADO_IP,my_shift_320,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
