# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLK 
create_clock -name clk_in -period 38.462 [get_ports clk_in]
set_property PACKAGE_PIN T7 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]


set_property PACKAGE_PIN R11 [get_ports {SPI_CLK}]  		;# SPI_CLK
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CLK}]

set_property PACKAGE_PIN T10 [get_ports {SPI_DIN}]  		;# SPI_DIN
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_DIN}]

set_property PACKAGE_PIN P10 [get_ports {SPI_DOUT}]  		;# SPI_DOUT
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_DOUT}]

set_property PACKAGE_PIN T3 [get_ports {SPI_CS_N}]  		;# SPI_CS_N
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CS_N}]

set_property PACKAGE_PIN T5 [get_ports {SPI_CS1_N}]  		;# SPI_CS1_N
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CS1_N}]

set_property PACKAGE_PIN T9 [get_ports {SPI_CS2_N}]  		;# SPI_CS2_N
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CS2_N}]


set_property PACKAGE_PIN T4 [get_ports {MR_N}]  		;# MR_N
set_property IOSTANDARD LVCMOS33 [get_ports {MR_N}]



# external I/O

set_property PACKAGE_PIN T12 [get_ports {IO_A[0]}]		;# A3 / T12~IO_L52N_M1DQ15_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[0]}]

set_property PACKAGE_PIN T14 [get_ports {IO_A[1]}]		;# A4 / T14~IO_L51P_M1DQ12_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[1]}]

set_property PACKAGE_PIN T15 [get_ports {IO_A[2]}]		;# A5 / T15~IO_L50N_M1UDQSN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[2]}]

set_property PACKAGE_PIN R16 [get_ports {IO_A[3]}]		;# A6 / R16~IO_L49N_M1DQ11_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[3]}]

set_property PACKAGE_PIN P16 [get_ports {IO_A[4]}]		;# A7 / P16~IO_L48N_M1DQ9_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[4]}]

set_property PACKAGE_PIN N16 [get_ports {IO_A[5]}]		;# A8 / N16~IO_L45N_A0_M1LDQSN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[5]}]

set_property PACKAGE_PIN M16 [get_ports {IO_A[6]}]		;# A9 / M16~IO_L46N_FOE_B_M1DQ3_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[6]}]

set_property PACKAGE_PIN L13 [get_ports {IO_A[7]}]		;# A10 / L13~IO_L53N_VREF_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[7]}]

set_property PACKAGE_PIN L16 [get_ports {IO_A[8]}]		;# A11 / L16~IO_L47N_LDC_M1DQ1_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[8]}]

set_property PACKAGE_PIN M13 [get_ports {IO_A[9]}]		;# A12 / M13~IO_L74P_AWAKE_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[9]}]

set_property PACKAGE_PIN K16 [get_ports {IO_A[10]}]		;# A13 / K16~IO_L44N_A2_M1DQ7_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[10]}]

set_property PACKAGE_PIN K14 [get_ports {IO_A[11]}]		;# A14 / K14~IO_L41N_GCLK8_M1CASN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[11]}]

set_property PACKAGE_PIN J16 [get_ports {IO_A[12]}]		;# A18 / J16~IO_L43N_GCLK4_M1DQ5_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[12]}]

set_property PACKAGE_PIN H16 [get_ports {IO_A[13]}]		;# A19 / H16~IO_L37N_A6_M1A1_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[13]}]

set_property PACKAGE_PIN J12 [get_ports {IO_A[14]}]		;# A20 / J12~IO_L40N_GCLK10_M1A6_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[14]}]

set_property PACKAGE_PIN H14 [get_ports {IO_A[15]}]		;# A21 / H14~IO_L39N_M1ODT_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[15]}]

set_property PACKAGE_PIN G16 [get_ports {IO_A[16]}]		;# A22 / G16~IO_L36N_A8_M1BA1_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[16]}]

set_property PACKAGE_PIN F12 [get_ports {IO_A[17]}]		;# A23 / F12~IO_L30P_A21_M1RESET_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[17]}]

set_property PACKAGE_PIN F16 [get_ports {IO_A[18]}]		;# A24 / F16~IO_L35N_A10_M1A2_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[18]}]

set_property PACKAGE_PIN F14 [get_ports {IO_A[19]}]		;# A25 / F14~IO_L32N_A16_M1A9_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[19]}]

set_property PACKAGE_PIN E16 [get_ports {IO_A[20]}]		;# A26 / E16~IO_L34N_A12_M1BA2_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[20]}]

set_property PACKAGE_PIN E13 [get_ports {IO_A[21]}]		;# A27 / E13~IO_L1P_A25_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[21]}]

set_property PACKAGE_PIN D16 [get_ports {IO_A[22]}]		;# A28 / D16~IO_L31N_A18_M1A12_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[22]}]

set_property PACKAGE_PIN C16 [get_ports {IO_A[23]}]		;# A29 / C16~IO_L33N_A14_M1A4_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[23]}]

set_property PACKAGE_PIN B16 [get_ports {IO_A[24]}]		;# A30 / B16~IO_L29N_A22_M1A14_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[24]}]


set_property PACKAGE_PIN R12 [get_ports {IO_B[0]}]		;# B3 / R12~IO_L52P_M1DQ14_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[0]}]

set_property PACKAGE_PIN T13 [get_ports {IO_B[1]}]		;# B4 / T13~IO_L51N_M1DQ13_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[1]}]

set_property PACKAGE_PIN R14 [get_ports {IO_B[2]}]		;# B5 / R14~IO_L50P_M1UDQS_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[2]}]

set_property PACKAGE_PIN R15 [get_ports {IO_B[3]}]		;# B6 / R15~IO_L49P_M1DQ10_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[3]}]

set_property PACKAGE_PIN P15 [get_ports {IO_B[4]}]		;# B7 / P15~IO_L48P_HDC_M1DQ8_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[4]}]

set_property PACKAGE_PIN N14 [get_ports {IO_B[5]}]		;# B8 / N14~IO_L45P_A1_M1LDQS_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[5]}]

set_property PACKAGE_PIN M15 [get_ports {IO_B[6]}]		;# B9 / M15~IO_L46P_FCS_B_M1DQ2_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[6]}]

set_property PACKAGE_PIN L12 [get_ports {IO_B[7]}]		;# B10 / L12~IO_L53P_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[7]}]

set_property PACKAGE_PIN L14 [get_ports {IO_B[8]}]		;# B11 / L14~IO_L47P_FWE_B_M1DQ0_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[8]}]

set_property PACKAGE_PIN K12 [get_ports {IO_B[9]}]		;# B12 / K12~IO_L42P_GCLK7_M1UDM_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[9]}]

set_property PACKAGE_PIN K15 [get_ports {IO_B[10]}]		;# B13 / K15~IO_L44P_A3_M1DQ6_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[10]}]

set_property PACKAGE_PIN J13 [get_ports {IO_B[11]}]		;# B14 / J13~IO_L41P_GCLK9_IRDY1_M1RASN_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[11]}]

set_property PACKAGE_PIN J14 [get_ports {IO_B[12]}]		;# B18 / J14~IO_L43P_GCLK5_M1DQ4_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[12]}]

set_property PACKAGE_PIN H15 [get_ports {IO_B[13]}]		;# B19 / H15~IO_L37P_A7_M1A0_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[13]}]

set_property PACKAGE_PIN G12 [get_ports {IO_B[14]}]		;# B20 / G12~IO_L38P_A5_M1CLK_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[14]}]

set_property PACKAGE_PIN H13 [get_ports {IO_B[15]}]		;# B21 / H13~IO_L39P_M1A3_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[15]}]

set_property PACKAGE_PIN G14 [get_ports {IO_B[16]}]		;# B22 / G14~IO_L36P_A9_M1BA0_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[16]}]

set_property PACKAGE_PIN G11 [get_ports {IO_B[17]}]		;# B23 / G11~IO_L30N_A20_M1A11_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[17]}]

set_property PACKAGE_PIN F15 [get_ports {IO_B[18]}]		;# B24 / F15~IO_L35P_A11_M1A7_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[18]}]

set_property PACKAGE_PIN F13 [get_ports {IO_B[19]}]		;# B25 / F13~IO_L32P_A17_M1A8_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[19]}]

set_property PACKAGE_PIN E15 [get_ports {IO_B[20]}]		;# B26 / E15~IO_L34P_A13_M1WE_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[20]}]

set_property PACKAGE_PIN E12 [get_ports {IO_B[21]}]		;# B27 / E12~IO_L1N_A24_VREF_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[21]}]

set_property PACKAGE_PIN D14 [get_ports {IO_B[22]}]		;# B28 / D14~IO_L31P_A19_M1CKE_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[22]}]

set_property PACKAGE_PIN C15 [get_ports {IO_B[23]}]		;# B29 / C15~IO_L33P_A15_M1A10_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[23]}]

set_property PACKAGE_PIN B15 [get_ports {IO_B[24]}]		;# B30 / B15~IO_L29P_A23_M1A13_1
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[24]}]


set_property PACKAGE_PIN R2 [get_ports {IO_C[0]}]		;# C3 / R2~IO_L32P_M3DQ14_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[0]}]

set_property PACKAGE_PIN P2 [get_ports {IO_C[1]}]		;# C4 / P2~IO_L33P_M3DQ12_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[1]}]

set_property PACKAGE_PIN N3 [get_ports {IO_C[2]}]		;# C5 / N3~IO_L34P_M3UDQS_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[2]}]

set_property PACKAGE_PIN M5 [get_ports {IO_C[3]}]		;# C6 / M5~IO_L2P_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[3]}]

set_property PACKAGE_PIN M4 [get_ports {IO_C[4]}]		;# C7 / M4~IO_L1P_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[4]}]

set_property PACKAGE_PIN M2 [get_ports {IO_C[5]}]		;# C8 / M2~IO_L35P_M3DQ10_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[5]}]

set_property PACKAGE_PIN L5 [get_ports {IO_C[6]}]		;# C9 / L5~IO_L45N_M3ODT_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[6]}]

set_property PACKAGE_PIN L3 [get_ports {IO_C[7]}]		;# C10 / L3~IO_L36P_M3DQ8_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[7]}]

set_property PACKAGE_PIN K2 [get_ports {IO_C[8]}]		;# C11 / K2~IO_L37P_M3DQ0_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[8]}]

set_property PACKAGE_PIN J4 [get_ports {IO_C[9]}]		;# C12 / J4~IO_L42N_GCLK24_M3LDM_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[9]}]

set_property PACKAGE_PIN J3 [get_ports {IO_C[10]}]		;# C13 / J3~IO_L38P_M3DQ2_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[10]}]

set_property PACKAGE_PIN H5 [get_ports {IO_C[11]}]		;# C14 / H5~IO_L43N_GCLK22_IRDY2_M3CASN_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[11]}]

set_property PACKAGE_PIN H4 [get_ports {IO_C[12]}]		;# C15 / H4~IO_L44P_GCLK21_M3A5_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[12]}]

set_property PACKAGE_PIN H2 [get_ports {IO_C[13]}]		;# C19 / H2~IO_L39P_M3LDQS_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[13]}]

set_property PACKAGE_PIN G3 [get_ports {IO_C[14]}]		;# C20 / G3~IO_L40P_M3DQ6_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[14]}]

set_property PACKAGE_PIN F5 [get_ports {IO_C[15]}]		;# C21 / F5~IO_L55N_M3A14_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[15]}]

set_property PACKAGE_PIN F2 [get_ports {IO_C[16]}]		;# C22 / F2~IO_L41P_GCLK27_M3DQ4_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[16]}]

set_property PACKAGE_PIN F4 [get_ports {IO_C[17]}]		;# C23 / F4~IO_L53P_M3CKE_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[17]}]

set_property PACKAGE_PIN E2 [get_ports {IO_C[18]}]		;# C24 / E2~IO_L46P_M3CLK_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[18]}]

set_property PACKAGE_PIN E4 [get_ports {IO_C[19]}]		;# C25 / E4~IO_L54P_M3RESET_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[19]}]

set_property PACKAGE_PIN D3 [get_ports {IO_C[20]}]		;# C26 / D3~IO_L49P_M3A7_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[20]}]

set_property PACKAGE_PIN C3 [get_ports {IO_C[21]}]		;# C27 / C3~IO_L48P_M3BA0_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[21]}]

set_property PACKAGE_PIN C1 [get_ports {IO_C[22]}]		;# C28 / C1~IO_L50P_M3WE_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[22]}]

set_property PACKAGE_PIN B3 [get_ports {IO_C[23]}]		;# C29 / B3~IO_L83P_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[23]}]

set_property PACKAGE_PIN A3 [get_ports {IO_C[24]}]		;# C30 / A3~IO_L83N_VREF_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[24]}]


set_property PACKAGE_PIN R1 [get_ports {IO_D[0]}]		;# D3 / R1~IO_L32N_M3DQ15_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[0]}]

set_property PACKAGE_PIN P1 [get_ports {IO_D[1]}]		;# D4 / P1~IO_L33N_M3DQ13_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[1]}]

set_property PACKAGE_PIN N1 [get_ports {IO_D[2]}]		;# D5 / N1~IO_L34N_M3UDQSN_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[2]}]

set_property PACKAGE_PIN N4 [get_ports {IO_D[3]}]		;# D6 / N4~IO_L2N_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[3]}]

set_property PACKAGE_PIN M3 [get_ports {IO_D[4]}]		;# D7 / M3~IO_L1N_VREF_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[4]}]

set_property PACKAGE_PIN M1 [get_ports {IO_D[5]}]		;# D8 / M1~IO_L35N_M3DQ11_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[5]}]

set_property PACKAGE_PIN L4 [get_ports {IO_D[6]}]		;# D9 / L4~IO_L45P_M3A3_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[6]}]

set_property PACKAGE_PIN L1 [get_ports {IO_D[7]}]		;# D10 / L1~IO_L36N_M3DQ9_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[7]}]

set_property PACKAGE_PIN K1 [get_ports {IO_D[8]}]		;# D11 / K1~IO_L37N_M3DQ1_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[8]}]

set_property PACKAGE_PIN K3 [get_ports {IO_D[9]}]		;# D12 / K3~IO_L42P_GCLK25_TRDY2_M3UDM_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[9]}]

set_property PACKAGE_PIN J1 [get_ports {IO_D[10]}]		;# D13 / J1~IO_L38N_M3DQ3_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[10]}]

set_property PACKAGE_PIN K5 [get_ports {IO_D[11]}]		;# D14 / K5~IO_L47P_M3A0_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[11]}]

set_property PACKAGE_PIN H3 [get_ports {IO_D[12]}]		;# D15 / H3~IO_L44N_GCLK20_M3A6_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[12]}]

set_property PACKAGE_PIN H1 [get_ports {IO_D[13]}]		;# D19 / H1~IO_L39N_M3LDQSN_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[13]}]

set_property PACKAGE_PIN G1 [get_ports {IO_D[14]}]		;# D20 / G1~IO_L40N_M3DQ7_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[14]}]

set_property PACKAGE_PIN G5 [get_ports {IO_D[15]}]		;# D21 / G5~IO_L51N_M3A4_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[15]}]

set_property PACKAGE_PIN F1 [get_ports {IO_D[16]}]		;# D22 / F1~IO_L41N_GCLK26_M3DQ5_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[16]}]

set_property PACKAGE_PIN F3 [get_ports {IO_D[17]}]		;# D23 / F3~IO_L53N_M3A12_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[17]}]

set_property PACKAGE_PIN E1 [get_ports {IO_D[18]}]		;# D24 / E1~IO_L46N_M3CLKN_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[18]}]

set_property PACKAGE_PIN E3 [get_ports {IO_D[19]}]		;# D25 / E3~IO_L54N_M3A11_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[19]}]

set_property PACKAGE_PIN D1 [get_ports {IO_D[20]}]		;# D26 / D1~IO_L49N_M3A2_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[20]}]

set_property PACKAGE_PIN C2 [get_ports {IO_D[21]}]		;# D27 / C2~IO_L48N_M3BA1_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[21]}]

set_property PACKAGE_PIN B1 [get_ports {IO_D[22]}]		;# D28 / B1~IO_L50N_M3BA2_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[22]}]

set_property PACKAGE_PIN B2 [get_ports {IO_D[23]}]		;# D29 / B2~IO_L52P_M3A8_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[23]}]

set_property PACKAGE_PIN A2 [get_ports {IO_D[24]}]		;# D30 / A2~IO_L52N_M3A9_3
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[24]}]
