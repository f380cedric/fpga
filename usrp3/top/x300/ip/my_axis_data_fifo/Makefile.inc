#
# Copyright 2014 Ettus Research
#

include $(TOOLS_DIR)/make/viv_ip_builder.mak

IP_MY_AXIS_DATA_FIFO_SRCS = $(IP_BUILD_DIR)/my_axis_data_fifo/my_axis_data_fifo.xci

IP_MY_AXIS_DATA_FIFO_OUTS = $(addprefix $(IP_BUILD_DIR)/my_axis_data_fifo/, \
my_axis_data_fifo.xci.out \
synth/my_axis_data_fifo.v \
)

$(IP_MY_AXIS_DATA_FIFO_SRCS) $(IP_MY_AXIS_DATA_FIFO_OUTS) : $(IP_DIR)/my_axis_data_fifo/my_axis_data_fifo.xci
	$(call BUILD_VIVADO_IP,my_axis_data_fifo,$(ARCH),$(PART_ID),$(IP_DIR),$(IP_BUILD_DIR),0)
