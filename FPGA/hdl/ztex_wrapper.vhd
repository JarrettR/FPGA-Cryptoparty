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
        rst_i         : in std_logic;   --RESET
        CS            : in std_logic;   --CS
        cont_i          : in std_logic;   --CONT
        clk_i         : in std_logic;   --IFCLK

        dat_i         : out std_ulogic_vector(0 to 15);  --FD

        SLOE          : out std_logic;  --SLOE
        SLRD          : out std_logic;  --SLRD
        SLWR          : out std_logic;  --SLWR
        FIFOADR0      : out std_logic;  --FIFOADR0
        FIFOADR1      : out std_logic;  --FIFOADR1
        PKTEND        : out std_logic;  --PKTEND

        FLAGB         : in std_logic    --FLAGB
    );
end ztex_wrapper;

architecture RTL of ztex_wrapper is
    component wpa2_main
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        cont_i          : in    std_ulogic;
        ssid_dat_i      : in    w_input;
        data_dat_i      : in    w_input;
        pke_dat_i       : in    w_input;
        mic_dat_i       : in    w_input;
        pmk_dat_o       : out   w_output;
        pmk_valid_o     : out   std_ulogic;
        wpa2_complete_o : out   std_ulogic
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
    
    signal wpa2_complete:  std_ulogic;
    
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

begin

    MAIN1: wpa2_main port map (clk_i,rst_i,cont_i, ssid_w,ssid_w,ssid_w,ssid_w,w_pmk1,pmk1_valid,wpa2_complete);
    --MAIN2: wpa2_main port map (clk_i,rst_i,std_ulogic_vector(w_load),latch_input(1),w_pmk);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                latch_input <= "00";
                state <= STATE_IDLE;
                ssid_len <= 0;
                i_len <= 0;
                i_word <= 0;
                i_mux <= 0;
                ssid_load <= '0';
            else
                if state = STATE_IDLE then
                    --ssid_len <= to_integer(unsigned(dat_i));
                    state <= STATE_SSID;
                end if;
            end if;
        end if;
    end process;
    
	--write_o <= std_logic_vector( pb_buf ) when select_i = '1' else (others => 'Z');
    w_load <= w_load_temp;
    
end RTL; 