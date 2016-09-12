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
use ieee.numeric_std.all;
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
    read_i                : in    std_ulogic_vector(0 to 7);
    write_o               : out    std_ulogic_vector(0 to 7)
    
    );
end ztex_wrapper;

architecture RTL of ztex_wrapper is
    component wpa2_main
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        dat_ssid_i      : in    std_ulogic_vector(0 to 31);
        valid_ssid_i    : in    std_ulogic;
        dat_mk_i        : in    std_ulogic_vector(0 to 31);
        valid_mk_i      : in    std_ulogic;
        dat_pmk_o       : out   w_output;
        valid_pmk_o     : out   std_ulogic
    );
    end component;
    
    -- Fixed input format for benchmarking
    -- Will only work if password happens to be ten ascii digits, 0-f
    component gen_tenhex
    port(
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        complete_o     : out    std_ulogic;
        dat_mk_o       : out    mk_data
    );
    end component;
    
    -- Fixed input for benchmarking
    -- Manually set+programmed for each SSID :(
    component gen_ssid
    port(
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        complete_o     : out    std_ulogic;
        dat_mk_o       : out    mk_data
    );
    end component;
   
	type state_type is (STATE_IDLE, STATE_SSID, STATE_MK, STATE_OUT);
    
	signal state       : state_type := STATE_IDLE;
   
    signal b_load:  unsigned(0 to 31);
    signal b_load_temp:  unsigned(0 to 31);
    signal w_load:  unsigned(0 to 31);
    
    signal w_mk:   mk_data;
    signal w_pmk:  pmk_data;
    
    --PMK
    signal w_secret1: w_input;
    signal w_secret2: w_input;
    signal w_secret3: w_input;
    signal w_secret4: w_input;
    signal w_secret5: w_input;
    
    --SSID
    signal w_value: w_input;

    signal i : integer range 0 to 16;
    
    signal i_mux : integer range 0 to 1;
    signal latch_input: std_ulogic_vector(0 to 1);
    
    -- synthesis translate_off
    signal test_1              : std_ulogic_vector(0 to 31);
    signal test_2              : std_ulogic_vector(0 to 31);
    signal test_3              : std_ulogic_vector(0 to 31);
    signal test_4              : std_ulogic_vector(0 to 31);
    -- synthesis translate_on


begin

    MAIN1: wpa2_main port map (fxclk_i,reset_i,std_ulogic_vector(w_load),latch_input(0),w_pmk);
    --MAIN2: wpa2_main port map (fxclk_i,reset_i,std_ulogic_vector(w_load),latch_input(0),w_pmk);
    
    process(fxclk_i)   
    begin
        if (fxclk_i'event and fxclk_i = '1') then
            if reset_i = '1' then
                latch_input <= "00";
                --b_load <= "00000000";
                i <= 0;
                i_mux <= 0;
            else
                if i = 3 then
                    case i_mux is
                        when 0 => latch_input <= "10";
                        when 1 => latch_input <= "01";
                    end case;
                    if i_mux = 1 then
                        i_mux <= 0;
                    else
                        i_mux <= i_mux + 1;
                    end if;
                    
                    w_load <= rotate_left(unsigned(b_load_temp), 8) + unsigned(read_i);
                    
                    i <= 0;
                else
                    b_load <= rotate_left(b_load_temp, 8) + unsigned(read_i);
                    latch_input <= "00";
                    i <= i + 1;
                end if;
            end if;
        end if;
    end process;
    
	write_o <= std_logic_vector( pb_buf ) when select_i = '1' else (others => 'Z');
    b_load_temp <= b_load;
    
end RTL; 