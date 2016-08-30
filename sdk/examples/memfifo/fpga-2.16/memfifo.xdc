# IFCLK 
create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]
set_property PACKAGE_PIN J19 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]

# GPIO
set_property PACKAGE_PIN M22 [get_ports {gpio_clk}]  		;# PA0/INT0#
set_property PACKAGE_PIN M21 [get_ports {gpio_dir}]  		;# PA1/INT1#
set_property PACKAGE_PIN M18 [get_ports {gpio_dat}]  		;# PA3/WU2
set_property PULLUP true [get_ports {gpio_dat}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_*}]

# reset
set_property PACKAGE_PIN R18 [get_ports {reset}]  		;# PA7/FLAGD/SLCS#
set_property IOSTANDARD LVCMOS33 [get_ports {reset}]

# SW8
set_property PACKAGE_PIN D17 [get_ports {SW8}]			;# B11 / D17~IO_L12P_T1_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {SW8}]
set_property PULLUP true [get_ports {SW8}]

# led1
set_property PACKAGE_PIN B21 [get_ports {led1[0]}]		;# A6 / B21~IO_L21P_T3_DQS_16
set_property PACKAGE_PIN A21 [get_ports {led1[1]}]		;# B6 / A21~IO_L21N_T3_DQS_16
set_property PACKAGE_PIN D20 [get_ports {led1[2]}]		;# A7 / D20~IO_L19P_T3_16
set_property PACKAGE_PIN C20 [get_ports {led1[3]}]		;# B7 / C20~IO_L19N_T3_VREF_16
set_property PACKAGE_PIN B20 [get_ports {led1[4]}]		;# A8 / B20~IO_L16P_T2_16
set_property PACKAGE_PIN A20 [get_ports {led1[5]}]		;# B8 / A20~IO_L16N_T2_16
set_property PACKAGE_PIN C19 [get_ports {led1[6]}]		;# A9 / C19~IO_L13N_T2_MRCC_16
set_property PACKAGE_PIN A19 [get_ports {led1[7]}]		;# B9 / A19~IO_L17N_T2_16
set_property PACKAGE_PIN C18 [get_ports {led1[8]}]		;# A10 / C18~IO_L13P_T2_MRCC_16
set_property PACKAGE_PIN A18 [get_ports {led1[9]}]		;# B10 / A18~IO_L17P_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {led1[*]}]
set_property DRIVE 12 [get_ports {led1[*]}]

# FD
set_property PACKAGE_PIN P20 [get_ports {fd[0]}]  		;# PB0/FD0
set_property PACKAGE_PIN N17 [get_ports {fd[1]}]  		;# PB1/FD1
set_property PACKAGE_PIN P21 [get_ports {fd[2]}]  		;# PB2/FD2
set_property PACKAGE_PIN R21 [get_ports {fd[3]}]  		;# PB3/FD3
set_property PACKAGE_PIN T21 [get_ports {fd[4]}]  		;# PB4/FD4
set_property PACKAGE_PIN U21 [get_ports {fd[5]}]  		;# PB5/FD5
set_property PACKAGE_PIN P19 [get_ports {fd[6]}]  		;# PB6/FD6
set_property PACKAGE_PIN R19 [get_ports {fd[7]}]  		;# PB7/FD7
set_property PACKAGE_PIN T20 [get_ports {fd[8]}]  		;# PD0/FD8
set_property PACKAGE_PIN U20 [get_ports {fd[9]}]  		;# PD1/FD9
set_property PACKAGE_PIN U18 [get_ports {fd[10]}]  		;# PD2/FD10
set_property PACKAGE_PIN U17 [get_ports {fd[11]}]  		;# PD3/FD11
set_property PACKAGE_PIN W19 [get_ports {fd[12]}]  		;# PD4/FD12
set_property PACKAGE_PIN W20 [get_ports {fd[13]}]  		;# PD5/FD13
set_property PACKAGE_PIN W21 [get_ports {fd[14]}]  		;# PD6/FD14
set_property PACKAGE_PIN W22 [get_ports {fd[15]}]  		;# PD7/FD15
set_property IOSTANDARD LVCMOS33 [get_ports {fd[*]}]

# SLRD
set_property PACKAGE_PIN AB22 [get_ports {SLRD}]  		;# RDY0/SLRD
set_property IOSTANDARD LVCMOS33 [get_ports {SLRD}]
# SLWR
set_property PACKAGE_PIN AB21 [get_ports {SLWR}]  		;# RDY1/SLWR
set_property IOSTANDARD LVCMOS33 [get_ports {SLWR}]

# FLAGA
set_property PACKAGE_PIN K19 [get_ports {FLAGA}]  		;# CTL0/FLAGA
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGA}]
# FLAGB
set_property PACKAGE_PIN K18 [get_ports {FLAGB}]  		;# CTL1/FLAGB
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGB}]

# SLOE
set_property PACKAGE_PIN M20 [get_ports {SLOE}]  		;# PA2/SLOE
set_property IOSTANDARD LVCMOS33 [get_ports {SLOE}]
# FIFOADDR0
set_property PACKAGE_PIN N19 [get_ports {FIFOADDR0} ]  		;# PA4/FIFOADR0
set_property IOSTANDARD LVCMOS33 [get_ports {FIFOADDR0} ]
# FIFOADDR1
set_property PACKAGE_PIN N18 [get_ports {FIFOADDR1}]  		;# PA5/FIFOADR1
set_property IOSTANDARD LVCMOS33 [get_ports {FIFOADDR1}]
# PKTEND
set_property PACKAGE_PIN P17 [get_ports {PKTEND}]  		;# PA6/PKTEND
set_property IOSTANDARD LVCMOS33 [get_ports {PKTEND}]


# bitstream settings for all ZTEX Series 2 FPGA Boards
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]  
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design] 

