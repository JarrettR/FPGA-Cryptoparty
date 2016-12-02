--------------------------------------------------------------------------------
--                        wpa2_main.vhd
--    Master file, starting at PBKDF2 and cascading down
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


entity wpa2_main is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    cont_i          : in    std_ulogic;
    ssid_dat_i      : in    ssid_data;
    data_dat_i      : in    packet_data;
    anonce_dat      : in    nonce_data;
    cnonce_dat      : in    nonce_data;
    amac_dat        : in    mac_data;
    cmac_dat        : in    mac_data;
    mk_initial      : in   mk_data;
    mk_end          : in   mk_data;
    mk_dat_o        : out   mk_data;
    mk_valid_o      : out   std_ulogic;
    wpa2_complete_o : out   std_ulogic
    );
end wpa2_main;

architecture RTL of wpa2_main is
    
    -- Fixed input format for benchmarking
    -- Generates sample passwords of ten ascii digits, 0-f
    component gen_tenhex
    port(
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        start_val_i    : in    mk_data;
        end_val_i    : in    mk_data;
        init_load_i    : in    std_ulogic;
        complete_o     : out    std_ulogic;
        dat_mk_o       : out    mk_data
    );
    end component;
    
    component wpa2_compare
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        mk_dat_i        : in    mk_data;
        data_dat_i      : in    w_input;
        pke_dat_i       : in    w_input;
        mic_dat_i       : in    w_input;
        pmk_dat_o       : out   pmk_data;
        pmk_valid_o     : out   std_ulogic
    );
    end component;
    
    
    signal w: w_input;
    signal w_temp: w_input;
    
    signal mk_init_load: std_ulogic;
    signal mk: mk_data;
    signal pmk: pmk_data;
    
    --signal i : integer range 0 to 4;
    
    signal gen_complete: std_ulogic := '0';
    signal comp_complete: std_ulogic := '0';
	
    -- synthesis translate_off
    signal test_start1: unsigned(0 to 7);
    signal test_start2: unsigned(0 to 7);
    signal test_start3: unsigned(0 to 7);
    
    signal test_mk1: unsigned(0 to 7);
    signal test_mk2: unsigned(0 to 7);
    signal test_mk3: unsigned(0 to 7);
    
    
    -- synthesis translate_on

begin

    gen1: gen_tenhex port map (clk_i,rst_i,mk_initial,mk_end,mk_init_load,gen_complete,mk);
    comp1: wpa2_compare port map (clk_i,rst_i,mk,w,w,w,pmk,comp_complete);


    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                wpa2_complete_o <= '0';
                mk_init_load <= '1';
            else
                mk_init_load <= '0';
                if gen_complete = '1' or comp_complete = '1' then
                    wpa2_complete_o <= '1';
                end if;
                mk_valid_o <= comp_complete;                
            end if;
        end if;
    end process;
    
    
    
    -- synthesis translate_off
    test_start1 <= mk_initial(0);
    test_start2 <= mk_initial(7);
    test_start3 <= mk_initial(9);
    
    test_mk1 <= mk(0);
    test_mk2 <= mk(8);
    test_mk3 <= mk(9);
    -- synthesis translate_on


end RTL; 