#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_MULT_II_SRCS = $(IP_BUILD_DIR)/my_mult_ii/my_mult_ii.xci

IP_MY_MULT_II_OUTS = $(addprefix $(IP_BUILD_DIR)/my_mult_ii/, \
my_mult_ii.xci.out \
synth/my_mult_ii.v \
)

$(IP_MY_MULT_II_SRCS) $(IP_MY_MULT_II_OUTS) : $(IP_DIR)/my_mult_ii/my_mult_ii.xci
	$(call BUILD_VIVADO_IP,my_mult_ii,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
