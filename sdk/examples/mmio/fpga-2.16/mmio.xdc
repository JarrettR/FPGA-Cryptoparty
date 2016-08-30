# CLKOUT/FXCLK 
create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]
set_property PACKAGE_PIN Y18 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

set_property PACKAGE_PIN R17 [get_ports {MM_A[0]}]  		;# A0
set_property PACKAGE_PIN P16 [get_ports {MM_A[1]}]  		;# A1
set_property PACKAGE_PIN R16 [get_ports {MM_A[2]}]  		;# A2
set_property PACKAGE_PIN T18 [get_ports {MM_A[3]}]  		;# A3
set_property PACKAGE_PIN V19 [get_ports {MM_A[4]}]  		;# A4
set_property PACKAGE_PIN V20 [get_ports {MM_A[5]}]  		;# A5
set_property PACKAGE_PIN V22 [get_ports {MM_A[6]}]  		;# A6
set_property PACKAGE_PIN W17 [get_ports {MM_A[7]}]  		;# A7
set_property PACKAGE_PIN Y19 [get_ports {MM_A[8]}]  		;# A8
set_property PACKAGE_PIN Y21 [get_ports {MM_A[9]}]  		;# A9
set_property PACKAGE_PIN Y22 [get_ports {MM_A[10]}]  		;# A10
set_property PACKAGE_PIN G20 [get_ports {MM_A[11]}]  		;# A11
set_property PACKAGE_PIN G18 [get_ports {MM_A[12]}]  		;# A12
set_property PACKAGE_PIN G17 [get_ports {MM_A[13]}]  		;# A13
set_property PACKAGE_PIN G16 [get_ports {MM_A[14]}]  		;# A14
set_property PACKAGE_PIN G15 [get_ports {MM_A[15]}]  		;# A15

set_property PACKAGE_PIN J22 [get_ports {MM_D[0]}]  		;# D0
set_property PACKAGE_PIN J21 [get_ports {MM_D[1]}]  		;# D1
set_property PACKAGE_PIN J20 [get_ports {MM_D[2]}]  		;# D2
set_property PACKAGE_PIN K17 [get_ports {MM_D[3]}]  		;# D3
set_property PACKAGE_PIN J17 [get_ports {MM_D[4]}]  		;# D4
set_property PACKAGE_PIN M17 [get_ports {MM_D[5]}]  		;# D5
set_property PACKAGE_PIN N22 [get_ports {MM_D[6]}]  		;# D6
set_property PACKAGE_PIN N20 [get_ports {MM_D[7]}]  		;# D7
set_property DRIVE 4 [get_ports {MM_D[*]}]

set_property PACKAGE_PIN H14 [get_ports {MM_WRN}]  		;# WR_N
set_property PACKAGE_PIN H17 [get_ports {MM_RDN}]  		;# RD_N
set_property PACKAGE_PIN H18 [get_ports {MM_PSENN}]  		;# PSEN_N

set_property IOSTANDARD LVCMOS33 [get_ports {MM_*}]

# bitstream settings
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]  
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design] 
