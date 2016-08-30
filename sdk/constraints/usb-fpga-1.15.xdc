# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLKOUT/FXCLK 
create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]
set_property PACKAGE_PIN L22 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

# IFCLK 
create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]
set_property PACKAGE_PIN K20 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]


set_property PACKAGE_PIN U15 [get_ports {PA[2]}]  		;# PA2/SLOE
set_property IOSTANDARD LVCMOS33 [get_ports {PA[2]}]

set_property PACKAGE_PIN W17 [get_ports {PA[4]}]  		;# PA4/FIFOADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PA[4]}]

set_property PACKAGE_PIN Y18 [get_ports {PA[5]}]  		;# PA5/FIFOADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PA[5]}]

set_property PACKAGE_PIN AB5 [get_ports {PA[6]}]  		;# PA6/PKTEND
set_property IOSTANDARD LVCMOS33 [get_ports {PA[6]}]

set_property PACKAGE_PIN AB17 [get_ports {PA[7]}]  		;# PA7/FLAGD/SLCS#
set_property IOSTANDARD LVCMOS33 [get_ports {PA[7]}]


set_property PACKAGE_PIN Y17 [get_ports {PB[0]}]  		;# PB0/FD0
set_property IOSTANDARD LVCMOS33 [get_ports {PB[0]}]

set_property PACKAGE_PIN V13 [get_ports {PB[1]}]  		;# PB1/FD1
set_property IOSTANDARD LVCMOS33 [get_ports {PB[1]}]

set_property PACKAGE_PIN W13 [get_ports {PB[2]}]  		;# PB2/FD2
set_property IOSTANDARD LVCMOS33 [get_ports {PB[2]}]

set_property PACKAGE_PIN AA8 [get_ports {PB[3]}]  		;# PB3/FD3
set_property IOSTANDARD LVCMOS33 [get_ports {PB[3]}]

set_property PACKAGE_PIN AB8 [get_ports {PB[4]}]  		;# PB4/FD4
set_property IOSTANDARD LVCMOS33 [get_ports {PB[4]}]

set_property PACKAGE_PIN W6 [get_ports {PB[5]}]  		;# PB5/FD5
set_property IOSTANDARD LVCMOS33 [get_ports {PB[5]}]

set_property PACKAGE_PIN Y6 [get_ports {PB[6]}]  		;# PB6/FD6
set_property IOSTANDARD LVCMOS33 [get_ports {PB[6]}]

set_property PACKAGE_PIN Y9 [get_ports {PB[7]}]  		;# PB7/FD7
set_property IOSTANDARD LVCMOS33 [get_ports {PB[7]}]


set_property PACKAGE_PIN G20 [get_ports {PC[0]}]  		;# PC0/GPIFADR0
set_property IOSTANDARD LVCMOS33 [get_ports {PC[0]}]

set_property PACKAGE_PIN T20 [get_ports {PC[1]}]  		;# PC1/GPIFADR1
set_property IOSTANDARD LVCMOS33 [get_ports {PC[1]}]

set_property PACKAGE_PIN Y5 [get_ports {PC[2]}]  		;# PC2/GPIFADR2
set_property IOSTANDARD LVCMOS33 [get_ports {PC[2]}]

set_property PACKAGE_PIN AB9 [get_ports {PC[3]}]  		;# PC3/GPIFADR3
set_property IOSTANDARD LVCMOS33 [get_ports {PC[3]}]

set_property PACKAGE_PIN G19 [get_ports {PC[4]}]  		;# PC4/GPIFADR4
set_property IOSTANDARD LVCMOS33 [get_ports {PC[4]}]

set_property PACKAGE_PIN H20 [get_ports {PC[5]}]  		;# PC5/GPIFADR5
set_property IOSTANDARD LVCMOS33 [get_ports {PC[5]}]

set_property PACKAGE_PIN H19 [get_ports {PC[6]}]  		;# PC6/GPIFADR6
set_property IOSTANDARD LVCMOS33 [get_ports {PC[6]}]

set_property PACKAGE_PIN H18 [get_ports {PC[7]}]  		;# PC7/GPIFADR7
set_property IOSTANDARD LVCMOS33 [get_ports {PC[7]}]


set_property PACKAGE_PIN V21 [get_ports {PD[0]}]  		;# PD0/FD8
set_property IOSTANDARD LVCMOS33 [get_ports {PD[0]}]

set_property PACKAGE_PIN V22 [get_ports {PD[1]}]  		;# PD1/FD9
set_property IOSTANDARD LVCMOS33 [get_ports {PD[1]}]

set_property PACKAGE_PIN U20 [get_ports {PD[2]}]  		;# PD2/FD10
set_property IOSTANDARD LVCMOS33 [get_ports {PD[2]}]

set_property PACKAGE_PIN U22 [get_ports {PD[3]}]  		;# PD3/FD11
set_property IOSTANDARD LVCMOS33 [get_ports {PD[3]}]

set_property PACKAGE_PIN R20 [get_ports {PD[4]}]  		;# PD4/FD12
set_property IOSTANDARD LVCMOS33 [get_ports {PD[4]}]

set_property PACKAGE_PIN R22 [get_ports {PD[5]}]  		;# PD5/FD13
set_property IOSTANDARD LVCMOS33 [get_ports {PD[5]}]

set_property PACKAGE_PIN P18 [get_ports {PD[6]}]  		;# PD6/FD14
set_property IOSTANDARD LVCMOS33 [get_ports {PD[6]}]

set_property PACKAGE_PIN P19 [get_ports {PD[7]}]  		;# PD7/FD15
set_property IOSTANDARD LVCMOS33 [get_ports {PD[7]}]


set_property PACKAGE_PIN B22 [get_ports {TxD1}]  		;# TxD1
set_property IOSTANDARD LVCMOS33 [get_ports {TxD1}]

set_property PACKAGE_PIN A21 [get_ports {RxD1}]  		;# RxD1
set_property IOSTANDARD LVCMOS33 [get_ports {RxD1}]


set_property PACKAGE_PIN N22 [get_ports {SLRD}]  		;# RDY0/SLRD
set_property IOSTANDARD LVCMOS33 [get_ports {SLRD}]

set_property PACKAGE_PIN M22 [get_ports {SLWR}]  		;# RDY1/SLWR
set_property IOSTANDARD LVCMOS33 [get_ports {SLWR}]

set_property PACKAGE_PIN M21 [get_ports {RDY2}]  		;# RDY2
set_property IOSTANDARD LVCMOS33 [get_ports {RDY2}]

set_property PACKAGE_PIN K21 [get_ports {RDY3}]  		;# RDY3
set_property IOSTANDARD LVCMOS33 [get_ports {RDY3}]

set_property PACKAGE_PIN K22 [get_ports {RDY4}]  		;# RDY4
set_property IOSTANDARD LVCMOS33 [get_ports {RDY4}]

set_property PACKAGE_PIN J21 [get_ports {RDY5}]  		;# RDY5
set_property IOSTANDARD LVCMOS33 [get_ports {RDY5}]


set_property PACKAGE_PIN F20 [get_ports {FLAGA}]  		;# CTL0/FLAGA
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGA}]

set_property PACKAGE_PIN F19 [get_ports {FLAGB}]  		;# CTL1/FLAGB
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGB}]

set_property PACKAGE_PIN F18 [get_ports {FLAGC}]  		;# CTL2/FLAGC
set_property IOSTANDARD LVCMOS33 [get_ports {FLAGC}]

set_property PACKAGE_PIN D19 [get_ports {CTL3}]  		;# CTL3
set_property IOSTANDARD LVCMOS33 [get_ports {CTL3}]

set_property PACKAGE_PIN E20 [get_ports {CTL4}]  		;# CTL4
set_property IOSTANDARD LVCMOS33 [get_ports {CTL4}]

set_property PACKAGE_PIN N20 [get_ports {CTL5}]  		;# CTL5
set_property IOSTANDARD LVCMOS33 [get_ports {CTL5}]


set_property PACKAGE_PIN M20 [get_ports {MM_A[0]}]  		;# A0
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[0]}]

set_property PACKAGE_PIN M19 [get_ports {MM_A[1]}]  		;# A1
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[1]}]

set_property PACKAGE_PIN M18 [get_ports {MM_A[2]}]  		;# A2
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[2]}]

set_property PACKAGE_PIN N19 [get_ports {MM_A[3]}]  		;# A3
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[3]}]

set_property PACKAGE_PIN T19 [get_ports {MM_A[4]}]  		;# A4
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[4]}]

set_property PACKAGE_PIN T21 [get_ports {MM_A[5]}]  		;# A5
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[5]}]

set_property PACKAGE_PIN T22 [get_ports {MM_A[6]}]  		;# A6
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[6]}]

set_property PACKAGE_PIN R19 [get_ports {MM_A[7]}]  		;# A7
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[7]}]

set_property PACKAGE_PIN P20 [get_ports {MM_A[8]}]  		;# A8
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[8]}]

set_property PACKAGE_PIN P21 [get_ports {MM_A[9]}]  		;# A9
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[9]}]

set_property PACKAGE_PIN P22 [get_ports {MM_A[10]}]  		;# A10
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[10]}]

set_property PACKAGE_PIN J22 [get_ports {MM_A[11]}]  		;# A11
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[11]}]

set_property PACKAGE_PIN H21 [get_ports {MM_A[12]}]  		;# A12
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[12]}]

set_property PACKAGE_PIN H22 [get_ports {MM_A[13]}]  		;# A13
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[13]}]

set_property PACKAGE_PIN G22 [get_ports {MM_A[14]}]  		;# A14
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[14]}]

set_property PACKAGE_PIN F21 [get_ports {MM_A[15]}]  		;# A15
set_property IOSTANDARD LVCMOS33 [get_ports {MM_A[15]}]


set_property PACKAGE_PIN D20 [get_ports {MM_D[0]}]  		;# D0
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[0]}]

set_property PACKAGE_PIN C20 [get_ports {MM_D[1]}]  		;# D1
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[1]}]

set_property PACKAGE_PIN C19 [get_ports {MM_D[2]}]  		;# D2
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[2]}]

set_property PACKAGE_PIN B21 [get_ports {MM_D[3]}]  		;# D3
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[3]}]

set_property PACKAGE_PIN B20 [get_ports {MM_D[4]}]  		;# D4
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[4]}]

set_property PACKAGE_PIN J19 [get_ports {MM_D[5]}]  		;# D5
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[5]}]

set_property PACKAGE_PIN K19 [get_ports {MM_D[6]}]  		;# D6
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[6]}]

set_property PACKAGE_PIN L19 [get_ports {MM_D[7]}]  		;# D7
set_property IOSTANDARD LVCMOS33 [get_ports {MM_D[7]}]


set_property PACKAGE_PIN C22 [get_ports {MM_WR_N}]  		;# WR_N
set_property IOSTANDARD LVCMOS33 [get_ports {MM_WR_N}]

set_property PACKAGE_PIN D21 [get_ports {MM_RD_N}]  		;# RD_N
set_property IOSTANDARD LVCMOS33 [get_ports {MM_RD_N}]

set_property PACKAGE_PIN D22 [get_ports {MM_PSEN_N}]  		;# PSEN_N
set_property IOSTANDARD LVCMOS33 [get_ports {MM_PSEN_N}]


set_property PACKAGE_PIN T18 [get_ports {SD_DAT1}]  		;# SD_DAT1
set_property IOSTANDARD LVCMOS33 [get_ports {SD_DAT1}]

set_property PACKAGE_PIN R17 [get_ports {SD_DAT2}]  		;# SD_DAT2
set_property IOSTANDARD LVCMOS33 [get_ports {SD_DAT2}]


set_property PACKAGE_PIN F22 [get_ports {SCL}]  		;# SCL
set_property IOSTANDARD LVCMOS33 [get_ports {SCL}]

set_property PACKAGE_PIN E22 [get_ports {SDA}]  		;# SDA
set_property IOSTANDARD LVCMOS33 [get_ports {SDA}]


set_property PACKAGE_PIN C18 [get_ports {INT4}]  		;# INT4
set_property IOSTANDARD LVCMOS33 [get_ports {INT4}]

set_property PACKAGE_PIN V17 [get_ports {INT5_N}]  		;# INT5#
set_property IOSTANDARD LVCMOS33 [get_ports {INT5_N}]



# external I/O

set_property PACKAGE_PIN A20 [get_ports {IO_A[0]}]		;# A9 / A20~IO_L16N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[0]}]

set_property PACKAGE_PIN A18 [get_ports {IO_A[1]}]		;# A12 / A18~IO_L66N_SCP0_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[1]}]

set_property PACKAGE_PIN D17 [get_ports {IO_A[2]}]		;# A13 / D17~IO_L65P_SCP3_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[2]}]

set_property PACKAGE_PIN A17 [get_ports {IO_A[3]}]		;# A14 / A17~IO_L64N_SCP4_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[3]}]

set_property PACKAGE_PIN C14 [get_ports {IO_A[4]}]		;# A15 / C14~IO_L46N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[4]}]

set_property PACKAGE_PIN A11 [get_ports {IO_A[5]}]		;# A17 / A11~IO_L35N_GCLK16_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[5]}]

set_property PACKAGE_PIN C13 [get_ports {IO_A[6]}]		;# A18 / C13~IO_L48P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[6]}]

set_property PACKAGE_PIN C12 [get_ports {IO_A[7]}]		;# A19 / C12~IO_L37N_GCLK12_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[7]}]

set_property PACKAGE_PIN C15 [get_ports {IO_A[8]}]		;# A20 / C15~IO_L62P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[8]}]

set_property PACKAGE_PIN C10 [get_ports {IO_A[9]}]		;# A24 / C10~IO_L33N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[9]}]

set_property PACKAGE_PIN D8 [get_ports {IO_A[10]}]		;# A25 / D8~IO_L32N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[10]}]

set_property PACKAGE_PIN A8 [get_ports {IO_A[11]}]		;# A26 / A8~IO_L6N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[11]}]

set_property PACKAGE_PIN C8 [get_ports {IO_A[12]}]		;# A27 / C8~IO_L7N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[12]}]

set_property PACKAGE_PIN C6 [get_ports {IO_A[13]}]		;# A28 / C6~IO_L3N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[13]}]

set_property PACKAGE_PIN A5 [get_ports {IO_A[14]}]		;# A29 / A5~IO_L2N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[14]}]

set_property PACKAGE_PIN B3 [get_ports {IO_A[15]}]		;# A30 / B3~IO_L1P_HSWAPEN_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[15]}]


set_property PACKAGE_PIN A19 [get_ports {IO_B[0]}]		;# B9 / A19~IO_L16P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[0]}]

set_property PACKAGE_PIN B18 [get_ports {IO_B[1]}]		;# B12 / B18~IO_L66P_SCP1_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[1]}]

set_property PACKAGE_PIN C17 [get_ports {IO_B[2]}]		;# B14 / C17~IO_L64P_SCP5_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[2]}]

set_property PACKAGE_PIN D15 [get_ports {IO_B[3]}]		;# B15 / D15~IO_L46P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[3]}]

set_property PACKAGE_PIN C11 [get_ports {IO_B[4]}]		;# B17 / C11~IO_L35P_GCLK17_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[4]}]

set_property PACKAGE_PIN A13 [get_ports {IO_B[5]}]		;# B18 / A13~IO_L48N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[5]}]

set_property PACKAGE_PIN D11 [get_ports {IO_B[6]}]		;# B19 / D11~IO_L37P_GCLK13_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[6]}]

set_property PACKAGE_PIN F10 [get_ports {IO_B[7]}]		;# B20 / F10~IO_L38P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[7]}]

set_property PACKAGE_PIN D10 [get_ports {IO_B[8]}]		;# B24 / D10~IO_L33P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[8]}]

set_property PACKAGE_PIN D9 [get_ports {IO_B[9]}]		;# B25 / D9~IO_L32P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[9]}]

set_property PACKAGE_PIN B8 [get_ports {IO_B[10]}]		;# B26 / B8~IO_L6P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[10]}]

set_property PACKAGE_PIN D7 [get_ports {IO_B[11]}]		;# B27 / D7~IO_L7P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[11]}]

set_property PACKAGE_PIN D6 [get_ports {IO_B[12]}]		;# B28 / D6~IO_L3P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[12]}]

set_property PACKAGE_PIN C5 [get_ports {IO_B[13]}]		;# B29 / C5~IO_L2P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[13]}]

set_property PACKAGE_PIN A6 [get_ports {IO_B[14]}]		;# B30 / A6~IO_L4N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[14]}]


set_property PACKAGE_PIN L20 [get_ports {IO_C[0]}]		;# C3 / L20~IO_L43P_GCLK5_M1DQ4_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[0]}]

set_property PACKAGE_PIN Y11 [get_ports {IO_C[1]}]		;# C20 / Y11~IO_L31P_GCLK31_D14_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[1]}]

set_property PACKAGE_PIN AA12 [get_ports {IO_C[2]}]		;# C21 / AA12~IO_L30P_GCLK1_D13_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[2]}]

set_property PACKAGE_PIN Y10 [get_ports {IO_C[3]}]		;# C22 / Y10~IO_L29N_GCLK2_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[3]}]

set_property PACKAGE_PIN AB10 [get_ports {IO_C[4]}]		;# C23 / AB10~IO_L32N_GCLK28_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[4]}]

set_property PACKAGE_PIN Y13 [get_ports {IO_C[5]}]		;# C24 / Y13~IO_L41P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[5]}]

set_property PACKAGE_PIN W9 [get_ports {IO_C[6]}]		;# C25 / W9~IO_L47P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[6]}]


set_property PACKAGE_PIN V20 [get_ports {IO_D[0]}]		;# D8 / V20~IO_L71N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[0]}]

set_property PACKAGE_PIN Y22 [get_ports {IO_D[1]}]		;# D9 / Y22~IO_L59N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[1]}]

set_property PACKAGE_PIN AA22 [get_ports {IO_D[2]}]		;# D10 / AA22~IO_L63N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[2]}]

set_property PACKAGE_PIN Y21 [get_ports {IO_D[3]}]		;# D11 / Y21~IO_L59P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[3]}]

set_property PACKAGE_PIN W20 [get_ports {IO_D[4]}]		;# D12 / W20~IO_L53P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[4]}]

set_property PACKAGE_PIN AA20 [get_ports {IO_D[5]}]		;# D13 / AA20~IO_L61P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[5]}]

set_property PACKAGE_PIN V19 [get_ports {IO_D[6]}]		;# D14 / V19~IO_L71P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[6]}]

set_property PACKAGE_PIN Y19 [get_ports {IO_D[7]}]		;# D15 / Y19~IO_L67P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[7]}]

set_property PACKAGE_PIN V18 [get_ports {IO_D[8]}]		;# D16 / V18~IO_L73N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[8]}]

set_property PACKAGE_PIN Y15 [get_ports {IO_D[9]}]		;# D17 / Y15~IO_L5P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[9]}]

set_property PACKAGE_PIN V15 [get_ports {IO_D[10]}]		;# D19 / V15~IO_L13N_D10_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[10]}]

set_property PACKAGE_PIN W15 [get_ports {IO_D[11]}]		;# D20 / W15~IO_L14P_D11_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[11]}]

set_property PACKAGE_PIN AA14 [get_ports {IO_D[12]}]		;# D21 / AA14~IO_L15P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[12]}]

set_property PACKAGE_PIN AB12 [get_ports {IO_D[13]}]		;# D22 / AB12~IO_L30N_GCLK0_USERCCLK_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[13]}]

set_property PACKAGE_PIN AA10 [get_ports {IO_D[14]}]		;# D23 / AA10~IO_L32P_GCLK29_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[14]}]

set_property PACKAGE_PIN T14 [get_ports {IO_D[15]}]		;# D24 / T14~IO_L20P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[15]}]

set_property PACKAGE_PIN W12 [get_ports {IO_D[16]}]		;# D25 / W12~IO_L42P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[16]}]


set_property PACKAGE_PIN C16 [get_ports {IO_E[0]}]		;# E13 / C16~IO_L65N_SCP2_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[0]}]

set_property PACKAGE_PIN B16 [get_ports {IO_E[1]}]		;# E14 / B16~IO_L63P_SCP7_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[1]}]

set_property PACKAGE_PIN A16 [get_ports {IO_E[2]}]		;# E15 / A16~IO_L63N_SCP6_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[2]}]

set_property PACKAGE_PIN B12 [get_ports {IO_E[3]}]		;# E16 / B12~IO_L36P_GCLK15_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[3]}]

set_property PACKAGE_PIN A12 [get_ports {IO_E[4]}]		;# E17 / A12~IO_L36N_GCLK14_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[4]}]

set_property PACKAGE_PIN B14 [get_ports {IO_E[5]}]		;# E18 / B14~IO_L50P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[5]}]

set_property PACKAGE_PIN A14 [get_ports {IO_E[6]}]		;# E19 / A14~IO_L50N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[6]}]

set_property PACKAGE_PIN D12 [get_ports {IO_E[7]}]		;# E20 / D12~IO_L47N_0_NC45
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[7]}]

set_property PACKAGE_PIN D13 [get_ports {IO_E[8]}]		;# E21 / D13~IO_L47P_0_NC45
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[8]}]

set_property PACKAGE_PIN A10 [get_ports {IO_E[9]}]		;# E22 / A10~IO_L34N_GCLK18_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[9]}]

set_property PACKAGE_PIN B10 [get_ports {IO_E[10]}]		;# E23 / B10~IO_L34P_GCLK19_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[10]}]

set_property PACKAGE_PIN C9 [get_ports {IO_E[11]}]		;# E24 / C9~IO_L8P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[11]}]

set_property PACKAGE_PIN C7 [get_ports {IO_E[12]}]		;# E25 / C7~IO_L5P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[12]}]

set_property PACKAGE_PIN A7 [get_ports {IO_E[13]}]		;# E26 / A7~IO_L5N_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[13]}]

set_property PACKAGE_PIN B6 [get_ports {IO_E[14]}]		;# E27 / B6~IO_L4P_0
set_property IOSTANDARD LVCMOS33 [get_ports {IO_E[14]}]


set_property PACKAGE_PIN AA21 [get_ports {IO_F[0]}]		;# F10 / AA21~IO_L63P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[0]}]

set_property PACKAGE_PIN AB21 [get_ports {IO_F[1]}]		;# F11 / AB21~IO_L61N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[1]}]

set_property PACKAGE_PIN Y20 [get_ports {IO_F[2]}]		;# F12 / Y20~IO_L67N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[2]}]

set_property PACKAGE_PIN AB20 [get_ports {IO_F[3]}]		;# F13 / AB20~IO_L65N_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[3]}]

set_property PACKAGE_PIN AB19 [get_ports {IO_F[4]}]		;# F14 / AB19~IO_L65P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[4]}]

set_property PACKAGE_PIN AB18 [get_ports {IO_F[5]}]		;# F15 / AB18~IO_L2N_CMPMOSI_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[5]}]

set_property PACKAGE_PIN AA18 [get_ports {IO_F[6]}]		;# F16 / AA18~IO_L2P_CMPCLK_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[6]}]

set_property PACKAGE_PIN AA16 [get_ports {IO_F[7]}]		;# F17 / AA16~IO_L4P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[7]}]

set_property PACKAGE_PIN AB15 [get_ports {IO_F[8]}]		;# F18 / AB15~IO_L5N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[8]}]

set_property PACKAGE_PIN W14 [get_ports {IO_F[9]}]		;# F19 / W14~IO_L16P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[9]}]

set_property PACKAGE_PIN Y16 [get_ports {IO_F[10]}]		;# F20 / Y16~IO_L14N_D12_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[10]}]

set_property PACKAGE_PIN AB14 [get_ports {IO_F[11]}]		;# F21 / AB14~IO_L15N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[11]}]

set_property PACKAGE_PIN AB11 [get_ports {IO_F[12]}]		;# F22 / AB11~IO_L31N_GCLK30_D15_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[12]}]

set_property PACKAGE_PIN W11 [get_ports {IO_F[13]}]		;# F23 / W11~IO_L29P_GCLK3_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[13]}]

set_property PACKAGE_PIN U14 [get_ports {IO_F[14]}]		;# F24 / U14~IO_L20N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[14]}]

set_property PACKAGE_PIN Y12 [get_ports {IO_F[15]}]		;# F25 / Y12~IO_L42N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[15]}]

set_property PACKAGE_PIN Y8 [get_ports {IO_F[16]}]		;# F27 / Y8~IO_L47N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[16]}]

set_property PACKAGE_PIN AB7 [get_ports {IO_F[17]}]		;# F28 / AB7~IO_L63N_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[17]}]

set_property PACKAGE_PIN Y7 [get_ports {IO_F[18]}]		;# F29 / Y7~IO_L63P_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[18]}]

set_property PACKAGE_PIN AB6 [get_ports {IO_F[19]}]		;# F30 / AB6~IO_L64N_D9_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[19]}]

set_property PACKAGE_PIN AA6 [get_ports {IO_F[20]}]		;# F31 / AA6~IO_L64P_D8_2
set_property IOSTANDARD LVCMOS33 [get_ports {IO_F[20]}]
