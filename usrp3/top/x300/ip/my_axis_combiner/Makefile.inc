#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_AXIS_COMBINER_SRCS = $(IP_BUILD_DIR)/my_axis_combiner/my_axis_combiner.xci

IP_MY_AXIS_COMBINER_OUTS = $(addprefix $(IP_BUILD_DIR)/my_axis_combiner/, \
my_axis_combiner.xci.out \
synth/my_axis_combiner.v \
)

$(IP_MY_AXIS_COMBINER_SRCS) $(IP_MY_AXIS_COMBINER_OUTS) : $(IP_DIR)/my_axis_combiner/my_axis_combiner.xci
	$(call BUILD_VIVADO_IP,my_axis_combiner,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
