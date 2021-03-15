#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_AXIS_BROADCASTER_SRCS = $(IP_BUILD_DIR)/my_axis_broadcaster/my_axis_broadcaster.xci

IP_MY_AXIS_BROADCASTER_OUTS = $(addprefix $(IP_BUILD_DIR)/my_axis_broadcaster/, \
my_axis_broadcaster.xci.out \
synth/my_axis_broadcaster.v \
)

$(IP_MY_AXIS_BROADCASTER_SRCS) $(IP_MY_AXIS_BROADCASTER_OUTS) : $(IP_DIR)/my_axis_broadcaster/my_axis_broadcaster.xci
	$(call BUILD_VIVADO_IP,my_axis_broadcaster,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
