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
        cs_i          : in std_logic;   --CS
        cont_i        : in std_logic;   --CONT
        clk_i         : in std_logic;   --IFCLK

        din_i         : in std_ulogic_vector(0 to 7);  --FD
        dout_i        : out std_ulogic_vector(0 to 7);  --pc

        SLOE          : out std_logic;  --SLOE
        SLRD          : out std_logic;  --SLRD
        SLWR          : out std_logic;  --SLWR
        FIFOADR0      : out std_logic;  --FIFOADR0
        FIFOADR1      : out std_logic;  --FIFOADR1
        PKTEND        : out std_logic;  --PKTEND
   
        FLAGA         : in std_logic    --FLAGA   EP2 FIFO Empty flag (FLAGA)
        FLAGB         : in std_logic    --FLAGB
    );
end ztex_wrapper;

architecture RTL of ztex_wrapper is
    component wpa2_main
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        cont_i          : in    std_ulogic;
        ssid_dat_i      : in    ssid_data;
        data_dat_i      : in    packet_data;
        pke_dat_i       : in    pke_data;
        mic_dat_i       : in    mic_data;
        mk_dat_o        : out   mk_data;
        mk_valid_o     : out   std_ulogic;
        wpa2_complete_o : out   std_ulogic
    );
    end component;
   
	type state_type is (STATE_IDLE, STATE_SSID, STATE_MK, STATE_PROCESS, STATE_OUT);
    
	signal state         : state_type := STATE_IDLE;
   
    --Inputs
    signal ssid_dat      : ssid_data;
    signal data_dat      : packet_data;
    signal pke_dat       : pke_data;
    signal mic_dat       : mic_data;
    signal mk_initial    : mk_data;
    
    signal ssid_len      : integer range 0 to 63;
    signal mk_len        : integer range 0 to 63;
    
    --Outputs
    signal mk_dat        : mk_data;
        
    signal wpa2_complete : std_ulogic;
    signal pmk_valid     : std_ulogic;
    
    --Internal
    signal i_len : integer range 0 to 15;
    signal i_word : integer range 0 to 3;
    signal i_mux : integer range 0 to 1;

begin

    MAIN1: wpa2_main port map (clk_i,rst_i,cont_i, ssid_w,ssid_w,ssid_w,ssid_w,w_pmk1,pmk1_valid,wpa2_complete);
    
    SLOE <= '1'     when cs_i = '1' else 'Z';
    SLRD <= '1'     when cs_i = '1' else 'Z';
    SLWR <= SLWR_R  when cs_i = '1' else 'Z';
    FIFOADR0 <= '0' when cs_i = '1' else 'Z';
    FIFOADR1 <= '0' when cs_i = '1' else 'Z';
    PKTEND <= '1'   when cs_i = '1' else 'Z';		-- no data alignment
    FD <= FD_R      when cs_i = '1' else (others => 'Z');
    
    process(clk_i, rst_i)   
    begin
        if rst_i = '1' then
            GEN_CNT <= ( others => '0' );
            INT_CNT <= ( others => '0' );
            FIFO_WORD <= '0';
            SLWR_R <= '1';
            
            latch_input <= "00";
            state <= STATE_IDLE;
            ssid_len <= 0;
            i_len <= 0;
            i_word <= 0;
            i_mux <= 0;
            ssid_load <= '0';
        elsif (clk_i'event and clk_i = '1') then
            if state = STATE_IDLE then
                --ssid_len <= to_integer(unsigned(din_i));
                state <= STATE_SSID;
            end if;
        end if;
    end process;
    
	--write_o <= std_logic_vector( pb_buf ) when select_i = '1' else (others => 'Z');
    w_load <= w_load_temp;
    
end RTL; 