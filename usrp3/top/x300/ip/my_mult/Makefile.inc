#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_MULT_SRCS = $(IP_BUILD_DIR)/my_mult/my_mult.xci

IP_MY_MULT_OUTS = $(addprefix $(IP_BUILD_DIR)/my_mult/, \
my_mult.xci.out \
synth/my_mult.v \
)

$(IP_MY_MULT_SRCS) $(IP_MY_MULT_OUTS) : $(IP_DIR)/my_mult/my_mult.xci
	$(call BUILD_VIVADO_IP,my_mult,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
