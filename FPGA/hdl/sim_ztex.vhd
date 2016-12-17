--------------------------------------------------------------------------------
--                             sim_ztex.vhd
--    Simulation testbench for ztex_wrapper
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

library std;
  use std.textio.all;

entity sim_ztex is
end sim_ztex;

architecture SIM of sim_ztex is
    component ztex_wrapper
    port(
        rst_i         : in std_logic;   --RESET
        cs_i          : in std_logic;   --CS
        cont_i        : in std_logic;   --CONT
        clk_i         : in std_logic;   --IFCLK

        dat_i         : in unsigned(0 to 7);  --FD
        dat_o         : out unsigned(0 to 7);  --pc

        SLOE          : out std_logic;  --SLOE
        SLRD          : out std_logic;  --SLRD
        SLWR          : out std_logic;  --SLWR
        FIFOADR0      : out std_logic;  --FIFOADR0
        FIFOADR1      : out std_logic;  --FIFOADR1
        PKTEND        : out std_logic;  --PKTEND
   
        FLAGA         : in std_logic;   --FLAGA   EP2 FIFO Empty flag (FLAGA)
        FLAGB         : in std_logic    --FLAGB
    );
    end component;
   
    signal i: integer range 0 to 65535;
    
    signal rst_i: std_logic := '0';
    signal cs_i: std_logic := '0';
    signal cont_i: std_logic := '0';
    signal clk_i: std_logic := '0';
    
    signal dat_i: unsigned(0 to 7);
    signal dat_o: unsigned(0 to 7);
    
    signal SLOE: std_logic;
    signal SLRD: std_logic;
    signal SLWR: std_logic;
    signal FIFOADR0: std_logic;
    signal FIFOADR1: std_logic;
    signal PKTEND: std_logic;
    
    signal FLAGA: std_logic;
    signal FLAGB: std_logic;
    
    type t_char_file is file of character;
    --type t_byte_arr is unsigned(0 to 7);
    
    signal read_arr_byte : handshake_data;
    
    signal start_mk:     mk_data;
    signal end_mk:     mk_data;
    
    constant clock_period : time := 1 ns;
    
begin

    ZTEX1: ztex_wrapper port map (rst_i, cs_i, cont_i, clk_i,
        dat_i, dat_o,
        SLOE, SLRD, SLWR, FIFOADR0, FIFOADR1, PKTEND, FLAGA, FLAGB);
    
    stim_proc: process
    file file_handshake : t_char_file open read_mode is "wpa2-psk-linksys.hccap";
    variable char_buffer : character;
    begin        
        rst_i <= '0';
        i <= 0;
        
        start_mk(0) <= "00110001"; --0x31, char 1
        start_mk(1) <= "00110000";
        start_mk(2) <= "00110000";
        start_mk(3) <= "00110000";
        start_mk(4) <= "00110000";
        start_mk(5) <= "00110000";
        start_mk(6) <= "00110000";
        start_mk(7) <= "00110000";
        start_mk(8) <= "00110000";
        start_mk(9) <= "00110001";
        
        end_mk(0) <= "00110001"; --0x31, char 1
        end_mk(1) <= "00110000";
        end_mk(2) <= "00110000";
        end_mk(3) <= "00110000";
        end_mk(4) <= "00110000";
        end_mk(5) <= "00110000";
        end_mk(6) <= "00110000";
        end_mk(7) <= "00110010";
        end_mk(8) <= "00110000";
        end_mk(9) <= "00110000";
        
        wait until rising_edge(clk_i);	
        rst_i <= '1';
        wait until rising_edge(clk_i);     
        rst_i <= '0';   
        wait until rising_edge(clk_i);  
        while not endfile(file_handshake) loop
            read(file_handshake, char_buffer);
            dat_i <= to_unsigned(character'pos(char_buffer), 8);
            i <= i + 1;
            wait until rising_edge(clk_i);
        end loop; 
        file_close(file_handshake);
        
        for x in 0 to 9 loop
            dat_i <= start_mk(x);
            i <= i + 1;
            wait until rising_edge(clk_i);
        end loop; 
        for x in 0 to 9 loop
            dat_i <= end_mk(x);
            i <= i + 1;
            wait until rising_edge(clk_i);
        end loop; 
        
         wait;
    end process;

    --ssid_dat <= ssid_data(handshake_dat(0 to 35));      --36


   clock_process: process
   begin
		clk_i <= '0';
		wait for clock_period/2;
		clk_i <= '1';
		wait for clock_period/2;
   end process;
    
end SIM; 