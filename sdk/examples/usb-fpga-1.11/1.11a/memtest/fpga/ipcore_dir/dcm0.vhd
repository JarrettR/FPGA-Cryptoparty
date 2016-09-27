-- file: dcm0.vhd
--
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2008, 2009 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--
------------------------------------------------------------------------------
-- User entered comments
------------------------------------------------------------------------------
-- None
--
------------------------------------------------------------------------------
-- Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
-- Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
------------------------------------------------------------------------------
-- CLK_OUT1   200.000      0.000       N/A      217.125        N/A
-- CLK_OUT2    50.000      0.000       N/A      207.125        N/A
--
------------------------------------------------------------------------------
-- Input Clock   Input Freq (MHz)   Input Jitter (UI)
------------------------------------------------------------------------------
-- primary          48.000            0.010

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity dcm0 is
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic;
  CLK_VALID         : out    std_logic
 );
end dcm0;

architecture xilinx of dcm0 is
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of xilinx : architecture is "dcm0,clk_wiz_v1_4,{component_name=dcm0,use_phase_alignment=false,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,feedback_source=FDBK_AUTO,diff_ext_feedback=false,primtype_sel=DCM_CLKGEN,num_out_clk=2,clkin1_period=20.83333,clkin2_period=20.83333,use_power_down=false}";
  -- Input clock buffering / unused connectors
  signal clkin1            : std_logic;
  -- Output clock buffering / unused connectors
  signal clkfx             : std_logic;
  signal clkfx180_unused   : std_logic;
  signal clkfxdv           : std_logic;
  signal clkfbout          : std_logic;
  -- Dynamic programming unused signals
  signal progdone_unused   : std_logic;
  signal locked_internal   : std_logic;
  signal status_internal   : std_logic_vector(2 downto 1);

begin


  -- Input buffering
  --------------------------------------
  clkin1_buf : IBUFG
  port map
   (O => clkin1,
    I => CLK_IN1);


  -- Clocking primitive
  --------------------------------------
  -- Instantiation of the DCM primitive
  --    * Unused inputs are tied off
  --    * Unused outputs are labeled unused
  dcm_clkgen_inst: DCM_CLKGEN
  generic map
   (CLKFXDV_DIVIDE        => 4,
    CLKFX_DIVIDE          => 6,
    CLKFX_MULTIPLY        => 25,
    SPREAD_SPECTRUM       => "NONE",
    STARTUP_WAIT          => FALSE,
    CLKIN_PERIOD          => 20.83333,
    CLKFX_MD_MAX          => 0.000)
  port map
   -- Input clock
   (CLKIN                 => clkin1,
    -- Output clocks
    CLKFX                 => clkfx,
    CLKFX180              => clkfx180_unused,
    CLKFXDV               => clkfxdv,
   -- Ports for dynamic phase shift
    PROGCLK               => '0',
    PROGEN                => '0',
    PROGDATA              => '0',
    PROGDONE              => progdone_unused,
   -- Other control and status signals
    FREEZEDCM             => '0',
    LOCKED                => locked_internal,
    STATUS                => status_internal,
    RST                   => RESET);

  LOCKED                <= locked_internal;
  CLK_VALID             <= ( locked_internal and ( not status_internal(2) ) );

  -- Output buffering
  -------------------------------------


  clkout1_buf : AUTOBUF
  generic map
   (BUFFER_TYPE => "BUFG")
  port map
   (O => CLK_OUT1,
    I => clkfx);


  clkout2_buf : AUTOBUF
  generic map
   (BUFFER_TYPE => "BUFG")
  port map
   (O => CLK_OUT2,
    I => clkfxdv);
end xilinx;
