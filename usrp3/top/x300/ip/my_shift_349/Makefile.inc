#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_SHIFT_349_SRCS = $(IP_BUILD_DIR)/my_shift_349/my_shift_349.xci

IP_MY_SHIFT_349_OUTS = $(addprefix $(IP_BUILD_DIR)/my_shift_349/, \
my_shift_349.xci.out \
synth/my_shift_349.v \
)

$(IP_MY_SHIFT_349_SRCS) $(IP_MY_SHIFT_349_OUTS) : $(IP_DIR)/my_shift_349/my_shift_349.xci
	$(call BUILD_VIVADO_IP,my_shift_349,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
