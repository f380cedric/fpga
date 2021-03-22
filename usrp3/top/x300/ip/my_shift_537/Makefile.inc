#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_SHIFT_537_SRCS = $(IP_BUILD_DIR)/my_shift_537/my_shift_537.xci

IP_MY_SHIFT_537_OUTS = $(addprefix $(IP_BUILD_DIR)/my_shift_537/, \
my_shift_537.xci.out \
synth/my_shift_537.v \
)

$(IP_MY_SHIFT_537_SRCS) $(IP_MY_SHIFT_537_OUTS) : $(IP_DIR)/my_shift_537/my_shift_537.xci
	$(call BUILD_VIVADO_IP,my_shift_537,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
