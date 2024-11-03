###############################################################################################
## main.xdc for Arty A7-35T    ArchLab, Institute of Science Tokyo / Tokyo Tech
## FPGA: xc7a35ticsg324-1L
###############################################################################################

## 100MHz system clock
###############################################################################################
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports { w_clk }];
create_clock -add -name sys_clk -period 10.00 [get_ports { w_clk }]

###############################################################################################
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [get_ports { w_led[0] }];
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports { w_led[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports { w_led[2] }];
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports { w_led[3] }];

##### 240x240 ST7789 mini display #####
###############################################################################################
###### Pmod Header JC
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports { st7789_DC  }]; # Pin 1
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { st7789_RES }]; # Pin 2
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports { st7789_SDA }]; # Pin 3
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { st7789_SCL }]; # Pin 4

###############################################################################################
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { w_button[0] }];
set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { w_button[1] }];
set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports { w_button[2] }];
set_property -dict { PACKAGE_PIN B8  IOSTANDARD LVCMOS33 } [get_ports { w_button[3] }];

###############################################################################################
