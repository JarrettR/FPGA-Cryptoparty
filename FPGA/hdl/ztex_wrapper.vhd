--------------------------------------------------------------------------------
--                             ztex_wrapper.vhd
--    Overall wrapper for use with ZTEX 1.15y FPGA Bitcoin miners
--    Copyright (C) 2016  Jarrett Rainier
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity ztex_wrapper is

port(
    fxclk_i               : in    std_ulogic;
    select_i              : in    std_ulogic;
    reset_i               : in    std_ulogic;
    clk_reset_i           : in    std_ulogic;
    pll_stop_i            : in    std_ulogic;
    dcm_progclk_i         : in    std_ulogic;
    dcm_progdata_i        : in    std_ulogic;
    dcm_progen_i          : in    std_ulogic;
    rd_clk_i              : in    std_ulogic;
    wr_clk_i              : in    std_ulogic;
    wr_start_i            : in    std_ulogic;
    read_i                : out    std_ulogic_vector(0 to 7);
    write_o               : out    std_ulogic_vector(0 to 7)
    
    );
end ztex_wrapper;

architecture RTL of ztex_wrapper is
    component wpa2_main

    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        dat_i           : in    std_ulogic_vector(0 to 31);
        valid_i         : in    std_ulogic;
        dat_w_o         : out    w_input
        
    );
    end component;
   
    signal w_load: w_input;


begin

    MAIN1: wpa2_main port map (clk_i,rst_i,dat_i,sot_in,w_load);
    
    process(fxclk_i)   
    begin
        if (fxclk_i'event and fxclk_i = '1') then
            --- 
        end if;
    end process;
    
    ---

end RTL; 