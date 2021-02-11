#
# Copyright 2015 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_ADDER_SRCS = $(IP_BUILD_DIR)/my_adder/my_adder.xci

IP_MY_ADDER_OUTS = $(addprefix $(IP_BUILD_DIR)/my_adder/, \
my_adder.xci.out \
synth/my_adder.v \
)

$(IP_MY_ADDER_SRCS) $(IP_MY_ADDER_OUTS) : $(IP_DIR)/my_adder/my_adder.xci
	$(call BUILD_VIVADO_IP,my_adder,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
