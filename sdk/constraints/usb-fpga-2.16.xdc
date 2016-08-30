# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLKOUT/FXCLK 
create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]
set_property PACKAGE_PIN Y18 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

# IFCLK 
create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]
set_property PACKAGE_PIN J19 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]


set_property PACKAGE_PIN P20 [get_ports {PB[0]}]  		;# PB0/FD0
set_property IOSTANDARD LVCMOS33 [get_ports {PB[0]}]

set_property PACKAGE_PIN N17 [get_ports {PB[1]}]  		;# PB1/FD1
set_property IOSTANDARD LVCMOS33 [get_ports {PB[1]}]

set_property PACKAGE_PIN P21 [get_ports {PB[2]}]  		;# PB2/FD2
set_property IOSTANDARD LVCMOS33 [get_ports {PB[2]}]

set_property PACKAGE_PIN R21 [get_ports {PB[3]}]  		;# PB3/FD3
set_property IOSTANDARD LVCMOS33 [get_ports {PB[3]}]

set_property PACKAGE_PIN T21 [get_ports {PB[4]}]  		;# PB4/FD4
set_property IOSTANDARD LVCMOS33 [get_ports {PB[4]}]

set_property PACKAGE_PIN U21 [get_ports {PB[5]}]  		;# PB5/FD5
set_property IOSTANDARD LVCMOS33 [get_ports {PB[5]}]

set_property PACKAGE_PIN P19 [get_ports {PB[6]}]  		;# PB6/FD6
set_property IOSTANDARD LVCMOS33 [get_ports {PB[6]}]

set_property PACKAGE_PIN R19 [get_ports {PB[7]}]  		;# PB7/FD7
set_property IOSTANDARD LVCMOS33 [get_ports {PB[7]}]


set_property PACKAGE_PIN T20 [get_ports {PD[0]}]  		;# PD0/FD8
set_property IOSTANDARD LVCMOS33 [get_ports {PD[0]}]

set_property PACKAGE_PIN U20 [get_ports {PD[1]}]  		;# PD1/FD9
set_property IOSTANDARD LVCMOS33 [get_ports {PD[1]}]

set_property PACKAGE_PIN U18 [get_ports {PD[2]}]  		;# PD2/FD10
set_property IOSTANDARD LVCMOS33 [get_ports {PD[2]}]

set_property PACKAGE_PIN U17 [get_ports {PD[3]}]  		;# PD3/FD11
set_property IOSTANDARD LVCMOS33 [get_ports {PD[3]}]

set_property PACKAGE_PIN W19 [get_ports {PD[4]}]  		;# PD4/FD12
set_property IOSTANDARD LVCMOS33 [get_ports {PD[4]}]

set_property PACKAGE_PIN W20 [get_ports {PD[5]}]  		;# PD5/FD13
set_property IOSTANDARD LVCMOS33 [get_ports {PD[5]}]

set_property PACKAGE_PIN W21 [get_ports {PD[6]}]  		;# PD6/FD14
set_property IOSTANDARD LVCMOS33 [get_ports {PD[6]}]

set_property PACKAGE_PIN W22 [get_ports {PD[7]}]  		;# PD7/FD15
set_property IOSTANDARD LVCMOS33 [get_ports {PD[7]}]


set_property PACKAGE_PIN M22 [get_ports {PA[0]}]  		;# PA0/INT0#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[0]}]

set_property PACKAGE_PIN M21 [get_ports {PA[1]}]  		;# PA1/INT1#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[1]}]

set_property PACKAGE_PIN M20 [get_ports {PA[2]}]  		;# PA2/SLOE
set_property IOSTANDARD LVCMOS33 [get_ports {PA[2]}]

set_property PACKAGE_PIN M18 [get_ports {PA[3]}]  		;# PA3/WU2
set_property IOSTANDARD LVCMOS33 [get_ports {PA[3]}]

set_property PACKAGE_PIN N19 [get_ports {PA[4]}]  		;# PA4/FIFOADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PA[4]}]

set_property PACKAGE_PIN N18 [get_ports {PA[5]}]  		;# PA5/FIFOADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PA[5]}]

set_property PACKAGE_PIN P17 [get_ports {PA[6]}]  		;# PA6/PKTEND
set_property IOSTANDARD LVCMOS33 [get_ports {PA[6]}]

set_property PACKAGE_PIN R18 [get_ports {PA[7]}]  		;# PA7/FLAGD/SLCS#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[7]}]


set_property PACKAGE_PIN L20 [get_ports {PC[0]}]  		;# PC0/GPIFADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PC[0]}]

set_property PACKAGE_PIN L19 [get_ports {PC[1]}]  		;# PC1/GPIFADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PC[1]}]

set_property PACKAGE_PIN L18 [get_ports {PC[2]}]  		;# PC2/GPIFADR2
set_property IOSTANDARD LVCMOS33 [get_ports {PC[2]}]

set_property PACKAGE_PIN L16 [get_ports {PC[3]}]  		;# PC3/GPIFADR3
set_property IOSTANDARD LVCMOS33 [get_ports {PC[3]}]

set_property PACKAGE_PIN R22 [get_ports {FLASH_DO}]  		;# PC4/GPIFADR4
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_DO}]

set_property PACKAGE_PIN T19 [get_ports {FLASH_CS}]  		;# PC5/GPIFADR5
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_CS}]

set_property PACKAGE_PIN L12 [get_ports {FLASH_CLK}]  		;# PC6/GPIFADR6
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_CLK}]

set_property PACKAGE_PIN P22 [get_ports {FLASH_DI}]  		;# PC7/GPIFADR7
set_property IOSTANDARD LVCMOS33 [get_ports {FLASH_DI}]


set_property PACKAGE_PIN G11 [get_ports {PE[0]}]  		;# PE0/T0OUT
set_property IOSTANDARD LVCMOS33 [get_ports {PE[0]}]

set_property PACKAGE_PIN U12 [get_ports {PE[1]}]  		;# PE1/T1OUT
set_property IOSTANDARD LVCMOS33 [get_ports {PE[1]}]

set_property PACKAGE_PIN V17 [get_ports {PE[2]}]  		;# PE2/T2OUT
set_property IOSTANDARD LVCMOS33 [get_ports {PE[2]}]

set_property PACKAGE_PIN AA19 [get_ports {PE[5]}]  		;# PE5/INT6
set_property IOSTANDARD LVCMOS33 [get_ports {PE[5]}]

set_property PACKAGE_PIN AB20 [get_ports {PE[6]}]  		;# PE6/T2EX
set_property IOSTANDARD LVCMOS33 [get_ports {PE[6]}]


set_property PACKAGE_PIN AB22 [get_ports {SLRD}]  		;# RDY0/SLRD
set_property IOSTANDARD LVCMOS33 [get_ports {SLRD}]

set_property PACKAGE_PIN AB21 [get_ports {SLWR}]  		;# RDY1/SLWR
set_property IOSTANDARD LVCMOS33 [get_ports {SLWR}]

set_property PACKAGE_PIN AB18 [get_ports {RDY2}]  		;# RDY2
set_property IOSTANDARD LVCMOS33 [get_ports {RDY2}]

set_property PACKAGE_PIN AA21 [get_ports {RDY3}]  		;# RDY3
set_property IOSTANDARD LVCMOS33 [get_ports {RDY3}]

set_property PACKAGE_PIN AA20 [get_ports {RDY4}]  		;# RDY4
set_property IOSTANDARD LVCMOS33 [get_ports {RDY4}]

set_property PACKAGE_PIN AA18 [get_ports {RDY5}]  		;# RDY5
set_property IOSTANDARD LVCMOS33 [get_ports {RDY5}]


set_property PACKAGE_PIN K19 [get_ports {FLAGA}]  		;# CTL0/FLAGA
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGA}]

set_property PACKAGE_PIN K18 [get_ports {FLAGB}]  		;# CTL1/FLAGB
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGB}]

set_property PACKAGE_PIN L21 [get_ports {FLAGC}]  		;# CTL2/FLAGC
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGC}]

set_property PACKAGE_PIN K22 [get_ports {CTL3}]  		;# CTL3
set_property IOSTANDARD LVCMOS33 [get_ports {CTL3}]

set_property PACKAGE_PIN K21 [get_ports {CTL4}]  		;# CTL4
set_property IOSTANDARD LVCMOS33 [get_ports {CTL4}]


set_property PACKAGE_PIN G13 [get_ports {INT4}]  		;# INT4
set_property IOSTANDARD LVCMOS33 [get_ports {INT4}]

set_property PACKAGE_PIN V18 [get_ports {INT5_N}]  		;# INT5#
set_property IOSTANDARD LVCMOS33 [get_ports {INT5_N}]

set_property PACKAGE_PIN H22 [get_ports {T0}]  		;# T0
set_property IOSTANDARD LVCMOS33 [get_ports {T0}]


set_property PACKAGE_PIN H19 [get_ports {SCL}]  		;# SCL
set_property IOSTANDARD LVCMOS33 [get_ports {SCL}]

set_property PACKAGE_PIN H20 [get_ports {SDA}]  		;# SDA
set_property IOSTANDARD LVCMOS33 [get_ports {SDA}]


set_property PACKAGE_PIN J16 [get_ports {RxD0}]  		;# RxD0
set_property IOSTANDARD LVCMOS33 [get_ports {RxD0}]

set_property PACKAGE_PIN H15 [get_ports {TxD0}]  		;# TxD0
set_property IOSTANDARD LVCMOS33 [get_ports {TxD0}]


set_property PACKAGE_PIN R17 [get_ports {MM_A[0]}]  		;# A0
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[0]}]

set_property PACKAGE_PIN P16 [get_ports {MM_A[1]}]  		;# A1
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[1]}]

set_property PACKAGE_PIN R16 [get_ports {MM_A[2]}]  		;# A2
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[2]}]

set_property PACKAGE_PIN T18 [get_ports {MM_A[3]}]  		;# A3
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[3]}]

set_property PACKAGE_PIN V19 [get_ports {MM_A[4]}]  		;# A4
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[4]}]

set_property PACKAGE_PIN V20 [get_ports {MM_A[5]}]  		;# A5
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[5]}]

set_property PACKAGE_PIN V22 [get_ports {MM_A[6]}]  		;# A6
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[6]}]

set_property PACKAGE_PIN W17 [get_ports {MM_A[7]}]  		;# A7
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[7]}]

set_property PACKAGE_PIN Y19 [get_ports {MM_A[8]}]  		;# A8
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[8]}]

set_property PACKAGE_PIN Y21 [get_ports {MM_A[9]}]  		;# A9
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[9]}]

set_property PACKAGE_PIN Y22 [get_ports {MM_A[10]}]  		;# A10
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[10]}]

set_property PACKAGE_PIN G20 [get_ports {MM_A[11]}]  		;# A11
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[11]}]

set_property PACKAGE_PIN G18 [get_ports {MM_A[12]}]  		;# A12
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[12]}]

set_property PACKAGE_PIN G17 [get_ports {MM_A[13]}]  		;# A13
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[13]}]

set_property PACKAGE_PIN G16 [get_ports {MM_A[14]}]  		;# A14
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[14]}]

set_property PACKAGE_PIN G15 [get_ports {MM_A[15]}]  		;# A15
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[15]}]


set_property PACKAGE_PIN J22 [get_ports {MM_D[0]}]  		;# D0
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[0]}]

set_property PACKAGE_PIN J21 [get_ports {MM_D[1]}]  		;# D1
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[1]}]

set_property PACKAGE_PIN J20 [get_ports {MM_D[2]}]  		;# D2
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[2]}]

set_property PACKAGE_PIN K17 [get_ports {MM_D[3]}]  		;# D3
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[3]}]

set_property PACKAGE_PIN J17 [get_ports {MM_D[4]}]  		;# D4
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[4]}]

set_property PACKAGE_PIN M17 [get_ports {MM_D[5]}]  		;# D5
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[5]}]

set_property PACKAGE_PIN N22 [get_ports {MM_D[6]}]  		;# D6
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[6]}]

set_property PACKAGE_PIN N20 [get_ports {MM_D[7]}]  		;# D7
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[7]}]


set_property PACKAGE_PIN H14 [get_ports {MM_WR_N}]  		;# WR_N
set_property IOSTANDARD LVCMOS33 [get_ports {MM_WR_N}]

set_property PACKAGE_PIN H17 [get_ports {MM_RD_N}]  		;# RD_N
set_property IOSTANDARD LVCMOS33 [get_ports {MM_RD_N}]

set_property PACKAGE_PIN H18 [get_ports {MM_PSEN_N}]  		;# PSEN_N
set_property IOSTANDARD LVCMOS33 [get_ports {MM_PSEN_N}]


# external I/O

set_property PACKAGE_PIN E22 [get_ports {IO_A[0]}]		;# A3 / E22~IO_L22P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[0]}]

set_property PACKAGE_PIN C22 [get_ports {IO_A[1]}]		;# A4 / C22~IO_L20P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[1]}]

set_property PACKAGE_PIN E21 [get_ports {IO_A[2]}]		;# A5 / E21~IO_L23P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[2]}]

set_property PACKAGE_PIN B21 [get_ports {IO_A[3]}]		;# A6 / B21~IO_L21P_T3_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[3]}]

set_property PACKAGE_PIN D20 [get_ports {IO_A[4]}]		;# A7 / D20~IO_L19P_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[4]}]

set_property PACKAGE_PIN B20 [get_ports {IO_A[5]}]		;# A8 / B20~IO_L16P_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[5]}]

set_property PACKAGE_PIN C19 [get_ports {IO_A[6]}]		;# A9 / C19~IO_L13N_T2_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[6]}]

set_property PACKAGE_PIN C18 [get_ports {IO_A[7]}]		;# A10 / C18~IO_L13P_T2_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[7]}]

set_property PACKAGE_PIN B18 [get_ports {IO_A[8]}]		;# A11 / B18~IO_L11N_T1_SRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[8]}]

set_property PACKAGE_PIN B17 [get_ports {IO_A[9]}]		;# A12 / B17~IO_L11P_T1_SRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[9]}]

set_property PACKAGE_PIN B16 [get_ports {IO_A[10]}]		;# A13 / B16~IO_L7N_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[10]}]

set_property PACKAGE_PIN A16 [get_ports {IO_A[11]}]		;# A14 / A16~IO_L9N_T1_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[11]}]

set_property PACKAGE_PIN A14 [get_ports {IO_A[12]}]		;# A18 / A14~IO_L10N_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[12]}]

set_property PACKAGE_PIN D15 [get_ports {IO_A[13]}]		;# A19 / D15~IO_L6N_T0_VREF_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[13]}]

set_property PACKAGE_PIN B13 [get_ports {IO_A[14]}]		;# A20 / B13~IO_L8N_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[14]}]

set_property PACKAGE_PIN N3 [get_ports {IO_A[15]}]		;# A21 / N3~IO_L19N_T3_VREF_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[15]}]

set_property PACKAGE_PIN H4 [get_ports {IO_A[16]}]		;# A22 / H4~IO_L12P_T1_MRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[16]}]

set_property PACKAGE_PIN G4 [get_ports {IO_A[17]}]		;# A23 / G4~IO_L12N_T1_MRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[17]}]

set_property PACKAGE_PIN E3 [get_ports {IO_A[18]}]		;# A24 / E3~IO_L6N_T0_VREF_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[18]}]

set_property PACKAGE_PIN B2 [get_ports {IO_A[19]}]		;# A25 / B2~IO_L2N_T0_AD12N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[19]}]

set_property PACKAGE_PIN D2 [get_ports {IO_A[20]}]		;# A26 / D2~IO_L4N_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[20]}]

set_property PACKAGE_PIN G2 [get_ports {IO_A[21]}]		;# A27 / G2~IO_L8N_T1_AD14N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[21]}]

set_property PACKAGE_PIN A1 [get_ports {IO_A[22]}]		;# A28 / A1~IO_L1N_T0_AD4N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[22]}]

set_property PACKAGE_PIN D1 [get_ports {IO_A[23]}]		;# A29 / D1~IO_L3N_T0_DQS_AD5N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[23]}]

set_property PACKAGE_PIN G1 [get_ports {IO_A[24]}]		;# A30 / G1~IO_L5P_T0_AD13P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[24]}]


set_property PACKAGE_PIN D22 [get_ports {IO_B[0]}]		;# B3 / D22~IO_L22N_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[0]}]

set_property PACKAGE_PIN B22 [get_ports {IO_B[1]}]		;# B4 / B22~IO_L20N_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[1]}]

set_property PACKAGE_PIN D21 [get_ports {IO_B[2]}]		;# B5 / D21~IO_L23N_T3_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[2]}]

set_property PACKAGE_PIN A21 [get_ports {IO_B[3]}]		;# B6 / A21~IO_L21N_T3_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[3]}]

set_property PACKAGE_PIN C20 [get_ports {IO_B[4]}]		;# B7 / C20~IO_L19N_T3_VREF_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[4]}]

set_property PACKAGE_PIN A20 [get_ports {IO_B[5]}]		;# B8 / A20~IO_L16N_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[5]}]

set_property PACKAGE_PIN A19 [get_ports {IO_B[6]}]		;# B9 / A19~IO_L17N_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[6]}]

set_property PACKAGE_PIN A18 [get_ports {IO_B[7]}]		;# B10 / A18~IO_L17P_T2_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[7]}]

set_property PACKAGE_PIN D17 [get_ports {IO_B[8]}]		;# B11 / D17~IO_L12P_T1_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[8]}]

set_property PACKAGE_PIN C17 [get_ports {IO_B[9]}]		;# B12 / C17~IO_L12N_T1_MRCC_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[9]}]

set_property PACKAGE_PIN B15 [get_ports {IO_B[10]}]		;# B13 / B15~IO_L7P_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[10]}]

set_property PACKAGE_PIN A15 [get_ports {IO_B[11]}]		;# B14 / A15~IO_L9P_T1_DQS_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[11]}]

set_property PACKAGE_PIN A13 [get_ports {IO_B[12]}]		;# B18 / A13~IO_L10P_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[12]}]

set_property PACKAGE_PIN D14 [get_ports {IO_B[13]}]		;# B19 / D14~IO_L6P_T0_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[13]}]

set_property PACKAGE_PIN C13 [get_ports {IO_B[14]}]		;# B20 / C13~IO_L8P_T1_16
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[14]}]

set_property PACKAGE_PIN H3 [get_ports {IO_B[15]}]		;# B21 / H3~IO_L11P_T1_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[15]}]

set_property PACKAGE_PIN G3 [get_ports {IO_B[16]}]		;# B22 / G3~IO_L11N_T1_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[16]}]

set_property PACKAGE_PIN F4 [get_ports {IO_B[17]}]		;# B23 / F4~IO_0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[17]}]

set_property PACKAGE_PIN F3 [get_ports {IO_B[18]}]		;# B24 / F3~IO_L6P_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[18]}]

set_property PACKAGE_PIN C2 [get_ports {IO_B[19]}]		;# B25 / C2~IO_L2P_T0_AD12P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[19]}]

set_property PACKAGE_PIN E2 [get_ports {IO_B[20]}]		;# B26 / E2~IO_L4P_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[20]}]

set_property PACKAGE_PIN H2 [get_ports {IO_B[21]}]		;# B27 / H2~IO_L8P_T1_AD14P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[21]}]

set_property PACKAGE_PIN B1 [get_ports {IO_B[22]}]		;# B28 / B1~IO_L1P_T0_AD4P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[22]}]

set_property PACKAGE_PIN E1 [get_ports {IO_B[23]}]		;# B29 / E1~IO_L3P_T0_DQS_AD5P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[23]}]

set_property PACKAGE_PIN F1 [get_ports {IO_B[24]}]		;# B30 / F1~IO_L5N_T0_AD13N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[24]}]


set_property PACKAGE_PIN AB17 [get_ports {IO_C[0]}]		;# C3 / AB17~IO_L2N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[0]}]

set_property PACKAGE_PIN Y16 [get_ports {IO_C[1]}]		;# C4 / Y16~IO_L1P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[1]}]

set_property PACKAGE_PIN AA15 [get_ports {IO_C[2]}]		;# C5 / AA15~IO_L4P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[2]}]

set_property PACKAGE_PIN Y13 [get_ports {IO_C[3]}]		;# C6 / Y13~IO_L5P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[3]}]

set_property PACKAGE_PIN W14 [get_ports {IO_C[4]}]		;# C7 / W14~IO_L6P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[4]}]

set_property PACKAGE_PIN AA13 [get_ports {IO_C[5]}]		;# C8 / AA13~IO_L3P_T0_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[5]}]

set_property PACKAGE_PIN AB12 [get_ports {IO_C[6]}]		;# C9 / AB12~IO_L7N_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[6]}]

set_property PACKAGE_PIN W12 [get_ports {IO_C[7]}]		;# C10 / W12~IO_L12N_T1_MRCC_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[7]}]

set_property PACKAGE_PIN AA11 [get_ports {IO_C[8]}]		;# C11 / AA11~IO_L9N_T1_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[8]}]

set_property PACKAGE_PIN AA9 [get_ports {IO_C[9]}]		;# C12 / AA9~IO_L8P_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[9]}]

set_property PACKAGE_PIN W9 [get_ports {IO_C[10]}]		;# C13 / W9~IO_L24P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[10]}]

set_property PACKAGE_PIN AA8 [get_ports {IO_C[11]}]		;# C14 / AA8~IO_L22P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[11]}]

set_property PACKAGE_PIN V7 [get_ports {IO_C[12]}]		;# C15 / V7~IO_L19P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[12]}]

set_property PACKAGE_PIN AB6 [get_ports {IO_C[13]}]		;# C19 / AB6~IO_L20N_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[13]}]

set_property PACKAGE_PIN AA5 [get_ports {IO_C[14]}]		;# C20 / AA5~IO_L10P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[14]}]

set_property PACKAGE_PIN Y4 [get_ports {IO_C[15]}]		;# C21 / Y4~IO_L11P_T1_SRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[15]}]

set_property PACKAGE_PIN V4 [get_ports {IO_C[16]}]		;# C22 / V4~IO_L12P_T1_MRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[16]}]

set_property PACKAGE_PIN Y3 [get_ports {IO_C[17]}]		;# C23 / Y3~IO_L9P_T1_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[17]}]

set_property PACKAGE_PIN U3 [get_ports {IO_C[18]}]		;# C24 / U3~IO_L6P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[18]}]

set_property PACKAGE_PIN AB3 [get_ports {IO_C[19]}]		;# C25 / AB3~IO_L8P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[19]}]

set_property PACKAGE_PIN W2 [get_ports {IO_C[20]}]		;# C26 / W2~IO_L4P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[20]}]

set_property PACKAGE_PIN U2 [get_ports {IO_C[21]}]		;# C27 / U2~IO_L2P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[21]}]

set_property PACKAGE_PIN AA1 [get_ports {IO_C[22]}]		;# C28 / AA1~IO_L7P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[22]}]

set_property PACKAGE_PIN W1 [get_ports {IO_C[23]}]		;# C29 / W1~IO_L5P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[23]}]

set_property PACKAGE_PIN T1 [get_ports {IO_C[24]}]		;# C30 / T1~IO_L1P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[24]}]


set_property PACKAGE_PIN AB16 [get_ports {IO_D[0]}]		;# D3 / AB16~IO_L2P_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[0]}]

set_property PACKAGE_PIN AA16 [get_ports {IO_D[1]}]		;# D4 / AA16~IO_L1N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[1]}]

set_property PACKAGE_PIN AB15 [get_ports {IO_D[2]}]		;# D5 / AB15~IO_L4N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[2]}]

set_property PACKAGE_PIN AA14 [get_ports {IO_D[3]}]		;# D6 / AA14~IO_L5N_T0_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[3]}]

set_property PACKAGE_PIN Y14 [get_ports {IO_D[4]}]		;# D7 / Y14~IO_L6N_T0_VREF_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[4]}]

set_property PACKAGE_PIN AB13 [get_ports {IO_D[5]}]		;# D8 / AB13~IO_L3N_T0_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[5]}]

set_property PACKAGE_PIN AB11 [get_ports {IO_D[6]}]		;# D9 / AB11~IO_L7P_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[6]}]

set_property PACKAGE_PIN W11 [get_ports {IO_D[7]}]		;# D10 / W11~IO_L12P_T1_MRCC_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[7]}]

set_property PACKAGE_PIN AA10 [get_ports {IO_D[8]}]		;# D11 / AA10~IO_L9P_T1_DQS_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[8]}]

set_property PACKAGE_PIN AB10 [get_ports {IO_D[9]}]		;# D12 / AB10~IO_L8N_T1_13
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[9]}]

set_property PACKAGE_PIN Y9 [get_ports {IO_D[10]}]		;# D13 / Y9~IO_L24N_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[10]}]

set_property PACKAGE_PIN AB8 [get_ports {IO_D[11]}]		;# D14 / AB8~IO_L22N_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[11]}]

set_property PACKAGE_PIN W7 [get_ports {IO_D[12]}]		;# D15 / W7~IO_L19N_T3_VREF_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[12]}]

set_property PACKAGE_PIN AB7 [get_ports {IO_D[13]}]		;# D19 / AB7~IO_L20P_T3_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[13]}]

set_property PACKAGE_PIN AB5 [get_ports {IO_D[14]}]		;# D20 / AB5~IO_L10N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[14]}]

set_property PACKAGE_PIN AA4 [get_ports {IO_D[15]}]		;# D21 / AA4~IO_L11N_T1_SRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[15]}]

set_property PACKAGE_PIN W4 [get_ports {IO_D[16]}]		;# D22 / W4~IO_L12N_T1_MRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[16]}]

set_property PACKAGE_PIN AA3 [get_ports {IO_D[17]}]		;# D23 / AA3~IO_L9N_T1_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[17]}]

set_property PACKAGE_PIN V3 [get_ports {IO_D[18]}]		;# D24 / V3~IO_L6N_T0_VREF_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[18]}]

set_property PACKAGE_PIN AB2 [get_ports {IO_D[19]}]		;# D25 / AB2~IO_L8N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[19]}]

set_property PACKAGE_PIN Y2 [get_ports {IO_D[20]}]		;# D26 / Y2~IO_L4N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[20]}]

set_property PACKAGE_PIN V2 [get_ports {IO_D[21]}]		;# D27 / V2~IO_L2N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[21]}]

set_property PACKAGE_PIN AB1 [get_ports {IO_D[22]}]		;# D28 / AB1~IO_L7N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[22]}]

set_property PACKAGE_PIN Y1 [get_ports {IO_D[23]}]		;# D29 / Y1~IO_L5N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[23]}]

set_property PACKAGE_PIN U1 [get_ports {IO_D[24]}]		;# D30 / U1~IO_L1N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[24]}]
