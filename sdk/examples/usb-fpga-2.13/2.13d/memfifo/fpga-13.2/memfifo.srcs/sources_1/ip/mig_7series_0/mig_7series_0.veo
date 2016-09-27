//*****************************************************************************
// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor             : Xilinx
// \   \   \/    Version            : 2.0
//  \   \        Application        : MIG
//  /   /        Filename           : mig_7series_0.veo
// /___/   /\    Date Last Modified : $Date: 2011/06/02 08:34:47 $
// \   \  /  \   Date Created       : Tue Sept 21 2010
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : DDR3 SDRAM
// Purpose          : Template file containing code that can be used as a model
//                    for instantiating a CORE Generator module in a HDL design.
// Revision History :
//*****************************************************************************

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

mig_7series_0 # (

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   .BANK_WIDTH                    (3),
                                     // # of memory Bank Address bits.
   .CK_WIDTH                      (1),
                                     // # of CK/CK# outputs to memory.
   .COL_WIDTH                     (10),
                                     // # of memory Column Address bits.
   .CS_WIDTH                      (1),
                                     // # of unique CS outputs to memory.
   .nCS_PER_RANK                  (1),
                                     // # of unique CS outputs per rank for phy
   .CKE_WIDTH                     (1),
                                     // # of CKE outputs to memory.
   .DATA_BUF_ADDR_WIDTH           (5),
   .DQ_CNT_WIDTH                  (4),
                                     // = ceil(log2(DQ_WIDTH))
   .DQ_PER_DM                     (8),
   .DM_WIDTH                      (2),
                                     // # of DM (data mask)
   .DQ_WIDTH                      (16),
                                     // # of DQ (data)
   .DQS_WIDTH                     (2),
   .DQS_CNT_WIDTH                 (1),
                                     // = ceil(log2(DQS_WIDTH))
   .DRAM_WIDTH                    (8),
                                     // # of DQ per DQS
   .ECC                           ("OFF"),
   .DATA_WIDTH                    (16),
   .ECC_TEST                      ("OFF"),
   .PAYLOAD_WIDTH                 (16),
   .nBANK_MACHS                   (4),
   .RANKS                         (1),
                                     // # of Ranks.
   .ODT_WIDTH                     (1),
                                     // # of ODT outputs to memory.
   .ROW_WIDTH                     (14),
                                     // # of memory Row Address bits.
   .ADDR_WIDTH                    (28),
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
   .USE_CS_PORT                   (0),
                                     // # = 1, When Chip Select (CS#) output is enabled
                                     //   = 0, When Chip Select (CS#) output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
   .USE_DM_PORT                   (1),
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
   .USE_ODT_PORT                  (1),
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
   .PHY_CONTROL_MASTER_BANK       (0),
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   .AL                            ("0"),
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
   .nAL                           (0),
                                     // # Additive Latency in number of clock
                                     // cycles.
   .BURST_MODE                    ("8"),
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   .BURST_TYPE                    ("SEQ"),
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
   .CL                            (6),
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
   .CWL                           (5),
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
   .OUTPUT_DRV                    ("HIGH"),
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
   .RTT_NOM                       ("40"),
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     // # = "DISABLED" - RTT_NOM disabled,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
   .RTT_WR                        ("OFF"),
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
   .ADDR_CMD_MODE                 ("1T" ),
                                     // # = "1T", "2T".
   .REG_CTRL                      ("OFF"),
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   .CA_MIRROR                     ("OFF"),
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   .CLKIN_PERIOD                  (2500),
                                     // Input Clock Period
   .CLKFBOUT_MULT                 (2),
                                     // write PLL VCO multiplier
   .DIVCLK_DIVIDE                 (1),
                                     // write PLL VCO divisor
   .CLKOUT0_DIVIDE                (2),
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   .CLKOUT1_DIVIDE                (2),
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   .CLKOUT2_DIVIDE                (32),
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   .CLKOUT3_DIVIDE                (8),
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
   .tCKE                          (5000),
                                     // memory tCKE paramter in pS.
   .tFAW                          (40000),
                                     // memory tRAW paramter in pS.
   .tPRDI                         (1_000_000),
                                     // memory tPRDI paramter in pS.
   .tRAS                          (35000),
                                     // memory tRAS paramter in pS.
   .tRCD                          (13750),
                                     // memory tRCD paramter in pS.
   .tREFI                         (7800000),
                                     // memory tREFI paramter in pS.
   .tRFC                          (160000),
                                     // memory tRFC paramter in pS.
   .tRP                           (13750),
                                     // memory tRP paramter in pS.
   .tRRD                          (7500),
                                     // memory tRRD paramter in pS.
   .tRTP                          (7500),
                                     // memory tRTP paramter in pS.
   .tWTR                          (7500),
                                     // memory tWTR paramter in pS.
   .tZQI                          (128_000_000),
                                     // memory tZQI paramter in nS.
   .tZQCS                         (64),
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   .SIM_BYPASS_INIT_CAL           ("OFF"),
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence
   .SIMULATION                    ("FALSE"),
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   .BYTE_LANES_B0                 (4'b1111),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B1                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B2                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B3                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B4                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .DATA_CTL_B0                   (4'b0011),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B1                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B2                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B3                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B4                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane

   .PHY_0_BITLANES                (48'hFFF_CFF_3DF_2FF),
   .PHY_1_BITLANES                (48'h000_000_000_000),
   .PHY_2_BITLANES                (48'h000_000_000_000),
   .CK_BYTE_MAP                   (144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_02),
   .ADDR_MAP                      (192'h000_000_037_025_03A_024_035_03B_039_027_031_026_023_034_036_038),
   .BANK_MAP                      (36'h033_02A_032),
   .CAS_MAP                       (12'h020),
   .CKE_ODT_BYTE_MAP              (8'h00),
   .CKE_MAP                       (96'h000_000_000_000_000_000_000_02B),
   .ODT_MAP                       (96'h000_000_000_000_000_000_000_030),
   .CS_MAP                        (120'h000_000_000_000_000_000_000_000_000_000),
   .PARITY_MAP                    (12'h000),
   .RAS_MAP                       (12'h021),
   .WE_MAP                        (12'h022),
   .DQS_BYTE_MAP                  (144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_01),
   .DATA0_MAP                     (96'h016_018_014_019_010_017_011_013),
   .DATA1_MAP                     (96'h003_002_005_004_001_006_000_007),
   .DATA2_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA3_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA4_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA5_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA6_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA7_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA8_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA9_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA10_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA11_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA12_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA13_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA14_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA15_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA16_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA17_MAP                    (96'h000_000_000_000_000_000_000_000),
   .MASK0_MAP                     (108'h000_000_000_000_000_000_000_009_012),
   .MASK1_MAP                     (108'h000_000_000_000_000_000_000_000_000),

   .SLOT_0_CONFIG                 (8'b0000_0001),
                                     // Mapping of Ranks.
   .SLOT_1_CONFIG                 (8'b0000_0000),
                                     // Mapping of Ranks.
   .MEM_ADDR_ORDER                ("BANK_ROW_COLUMN"),
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   .IBUF_LPWR_MODE                ("OFF"),
                                     // to phy_top
   .DATA_IO_IDLE_PWRDWN           ("ON"),
                                     // # = "ON", "OFF"
   .DATA_IO_PRIM_TYPE             ("HR_LP"),
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
   .CKE_ODT_AUX                   ("FALSE"),
   .USER_REFRESH                  ("OFF"),
   .WRLVL                         ("ON"),
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
   .ORDERING                      ("NORM"),
                                     // # = "NORM", "STRICT", "RELAXED".
   .CALIB_ROW_ADD                 (16'h0000),
                                     // Calibration row address will be used for
                                     // calibration read and write operations
   .CALIB_COL_ADD                 (12'h000),
                                     // Calibration column address will be used for
                                     // calibration read and write operations
   .CALIB_BA_ADD                  (3'h0),
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   .TCQ                           (100),
   .IODELAY_GRP                   ("MIG_7SERIES_0_IODELAY_MIG"),
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
   .SYSCLK_TYPE                   ("NO_BUFFER"),
                                     // System clock type DIFFERENTIAL or SINGLE_ENDED
   .REFCLK_TYPE                   ("NO_BUFFER"),
                                     // Reference clock type DIFFERENTIAL or SINGLE_ENDED
   .CMD_PIPE_PLUS1                ("ON"),
                                     // add pipeline stage between MC and PHY
   .DRAM_TYPE                       ("DDR3"),
   .CAL_WIDTH                     ("HALF"),
   .STARVE_LIMIT                  (2),
                                     // # = 2,3,4.
   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   .REFCLK_FREQ                   (200.0),
                                     // IODELAYCTRL reference clock frequency
   .DIFF_TERM_REFCLK              ("TRUE"),
                                     // Differential Termination for idelay
                                     // reference clock input pins
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   .tCK                           (2500),
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   .nCK_PER_CLK                   (4),
                                     // # of memory CKs per fabric CLK
   .DIFF_TERM_SYSCLK              ("TRUE"),
                                     // Differential Termination for System
                                     // clock input pins

   
   //***************************************************************************
   // Debug parameters
   //***************************************************************************
   .DEBUG_PORT                      ("OFF"),
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
      
   .RST_ACT_LOW                   (1)
                                     // =1 for active low reset,
                                     // =0 for active high.
   )
  u_mig_7series_0 (

// Memory interface ports
     .ddr3_dq                        (ddr3_dq),
     .ddr3_dqs_n                     (ddr3_dqs_n),
     .ddr3_dqs_p                     (ddr3_dqs_p),
     .ddr3_addr                      (ddr3_addr),
     .ddr3_ba                        (ddr3_ba),
     .ddr3_ras_n                     (ddr3_ras_n),
     .ddr3_cas_n                     (ddr3_cas_n),
     .ddr3_we_n                      (ddr3_we_n),
     .ddr3_reset_n                   (ddr3_reset_n),
     .ddr3_ck_p                      (ddr3_ck_p),
     .ddr3_ck_n                      (ddr3_ck_n),
     .ddr3_cke                       (ddr3_cke),
     .ddr3_cs_n                      (ddr3_cs_n),
     .ddr3_dm                        (ddr3_dm),
     .ddr3_odt                       (ddr3_odt),
// Application interface ports
     .app_addr                       (app_addr),
     .app_cmd                        (app_cmd),
     .app_en                         (app_en),
     .app_wdf_data                   (app_wdf_data),
     .app_wdf_end                    (app_wdf_end),
     .app_wdf_mask                   (app_wdf_mask),
     .app_wdf_wren                   (app_wdf_wren),
     .app_rd_data                    (app_rd_data),
     .app_rd_data_end                (app_rd_data_end),
     .app_rd_data_valid              (app_rd_data_valid),
     .app_rdy                        (app_rdy),
     .app_wdf_rdy                    (app_wdf_rdy),
     .app_sr_req                     (app_sr_req),
     .app_sr_active                  (app_sr_active),
     .app_ref_req                    (app_ref_req),
     .app_ref_ack                    (app_ref_ack),
     .app_zq_req                     (app_zq_req),
     .app_zq_ack                     (app_zq_ack),
     .ui_clk                         (ui_clk),
     .ui_clk_sync_rst                (ui_clk_sync_rst),
     .init_calib_complete            (init_calib_complete),
     .sys_rst                        (sys_rst)
    );

// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file mig_7series_0.v when simulating
// the core, mig_7series_0. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".
