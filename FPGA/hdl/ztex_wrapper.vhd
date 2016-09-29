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
        RESET         : in std_logic;
        CS            : in std_logic;
        CONT          : in std_logic;
        IFCLK         : in std_logic;

        FD            : out std_logic_vector(15 downto 0); 

        SLOE          : out std_logic;
        SLRD          : out std_logic;
        SLWR          : out std_logic;
        FIFOADR0      : out std_logic;
        FIFOADR1      : out std_logic;
        PKTEND        : out std_logic;

        FLAGB         : in std_logic
    );
end ztex_wrapper;

architecture RTL of ztex_wrapper is
    component wpa2_main
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        ssid_dat_i      : in    w_input;
        ssid_load_i     : in    std_ulogic;
        ssid_length_i   : in    integer range 0 to 63;
        mk_dat_i        : in    mk_data;
        mk_load_i       : in    std_ulogic;
        mk_length_i     : in    integer range 0 to 63;
        pmk_dat_o       : out   w_output;
        pmk_valid_o     : out   std_ulogic
    );
    end component;
    
    -- Fixed input for benchmarking
    -- Manually set+programmed for each SSID :(
    --component gen_ssid
    --port(
    --    clk_i          : in    std_ulogic;
    --    rst_i          : in    std_ulogic;
    --    complete_o     : out    std_ulogic;
    --    dat_mk_o       : out    mk_data
    --);
    --end component;
   
	type state_type is (STATE_IDLE, STATE_SSID, STATE_MK, STATE_PROCESS, STATE_OUT);
    
	signal state       : state_type := STATE_IDLE;
   
    signal w_load:  unsigned(0 to 23);
    signal w_load_temp:  unsigned(0 to 23);
    
    signal w_mk:   mk_data;
    signal w_pmk:  pmk_data;
    
    --PMK
    signal w_pmk1: w_output;
    signal w_pmk2: w_input;
    signal w_pmk3: w_input;
    signal w_pmk4: w_input;
    signal w_pmk5: w_input;
    
    signal pmk1_valid: std_ulogic;
    
    --SSID
    signal ssid_w: w_input;
    signal ssid_load: std_ulogic;

    signal ssid_len : integer range 0 to 63;
    signal i_len : integer range 0 to 15;
    signal i_word : integer range 0 to 3;
    signal i_mux : integer range 0 to 1;
    signal latch_input: std_ulogic_vector(0 to 1);
    
    -- synthesis translate_off
    signal test_1              : std_ulogic_vector(0 to 31);
    signal test_2              : std_ulogic_vector(0 to 31);
    signal test_3              : std_ulogic_vector(0 to 31);
    signal test_4              : std_ulogic_vector(0 to 31);
    -- synthesis translate_on


begin


    MAIN1: wpa2_main port map (IFCLK,reset_i,ssid_w,ssid_load,ssid_len,w_mk,ssid_load,ssid_len,w_pmk1,pmk1_valid);
    --MAIN2: wpa2_main port map (IFCLK,reset_i,std_ulogic_vector(w_load),latch_input(1),w_pmk);
    
    process(IFCLK)   
    begin
        if (IFCLK'event and IFCLK = '1') then
            if reset_i = '1' then
                latch_input <= "00";
                state <= STATE_IDLE;
                ssid_len <= 0;
                i_len <= 0;
                i_word <= 0;
                i_mux <= 0;
                ssid_load <= '0';
            else
                if state = STATE_IDLE then
                    ssid_len <= to_integer(unsigned(read_i));
                    state <= STATE_SSID;
                elsif state = STATE_SSID then
                    if i_word < 3 then
                        i_word <= i_word + 1;
                        w_load_temp <= rotate_left(unsigned(w_load), 8) + unsigned(read_i);
                    else
                        i_word <= 0;
                        ssid_w(i_len) <= std_ulogic_vector(rotate_left(unsigned(w_load), 8) + unsigned(read_i));
                    end if;
                    if i_len < 15 then
                        i_len <= i_len + 1;
                        ssid_load <= '0';
                    else
                        --Todo: This will later be used to recieve MKs
                        state <= STATE_PROCESS;
                        i_len <= 0;
                        ssid_load <= '1';
                    end if;
                elsif state = STATE_PROCESS then
                    --
                end if;
            end if;
        end if;
    end process;
    
	--write_o <= std_logic_vector( pb_buf ) when select_i = '1' else (others => 'Z');
    w_load <= w_load_temp;
    
end RTL; 