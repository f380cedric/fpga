#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_SHIFT_1088_SRCS = $(IP_BUILD_DIR)/my_shift_1088/my_shift_1088.xci

IP_MY_SHIFT_1088_OUTS = $(addprefix $(IP_BUILD_DIR)/my_shift_1088/, \
my_shift_1088.xci.out \
synth/my_shift_1088.v \
)

$(IP_MY_SHIFT_1088_SRCS) $(IP_MY_SHIFT_1088_OUTS) : $(IP_DIR)/my_shift_1088/my_shift_1088.xci
	$(call BUILD_VIVADO_IP,my_shift_1088,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
