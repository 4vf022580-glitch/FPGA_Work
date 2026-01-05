# 时钟信号 (100MHz) - 绑定到 W5 引脚
set_property PACKAGE_PIN W5 [get_ports clk]							
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# 复位按钮 - 绑定到中间按钮 U18
set_property PACKAGE_PIN U18 [get_ports rst]						
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# 拨码开关 - 绑定到最右侧 V17
set_property PACKAGE_PIN V17 [get_ports sw_encrypt]					
set_property IOSTANDARD LVCMOS33 [get_ports sw_encrypt]

# USB UART 接口 (串口通信引脚)
set_property PACKAGE_PIN B18 [get_ports rx_line]						
set_property IOSTANDARD LVCMOS33 [get_ports rx_line]
set_property PACKAGE_PIN A18 [get_ports tx_line]						
set_property IOSTANDARD LVCMOS33 [get_ports tx_line]

# 配置约束（消除电压标准报错）
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]