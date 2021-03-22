#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_MULT_II_QQ_SRCS = $(IP_BUILD_DIR)/my_mult_ii_qq/my_mult_ii_qq.xci

IP_MY_MULT_II_QQ_OUTS = $(addprefix $(IP_BUILD_DIR)/my_mult_ii_qq/, \
my_mult_ii_qq.xci.out \
synth/my_mult_ii_qq.v \
)

$(IP_MY_MULT_II_QQ_SRCS) $(IP_MY_MULT_II_QQ_OUTS) : $(IP_DIR)/my_mult_ii_qq/my_mult_ii_qq.xci
	$(call BUILD_VIVADO_IP,my_mult_ii_qq,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
