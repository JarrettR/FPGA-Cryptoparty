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

entity sim_hmac is
end sim_hmac;

architecture SIM of sim_hmac is
    component hmac_main is
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        dat_bi_i        : in    w_input;
        dat_bo_i        : in    w_input;
        value_i         : in    std_ulogic_vector(0 to 31);
        value_load_i    : in    std_ulogic;
        dat_bi_o        : out    w_input;
        dat_bo_o        : out    w_input;
        valid_o         : out    std_ulogic        
    );
    end component;
   
    signal i: integer range 0 to 65535;
    
    signal rst_i: std_logic := '0';
    signal clk_i: std_logic := '0';
    
    signal dat_i: unsigned(0 to 7);
    signal dat_o: unsigned(0 to 7);
    
    type t_char_file is file of character;
    --type t_byte_arr is unsigned(0 to 7);
    
    signal read_arr_byte : handshake_data;
    
    
    constant clock_period : time := 1 ns;
    
begin

    hmac1: hmac_main port map (clk_i,rst_i, cs_i, cont_i, clk_i);
    
    stim_proc: process
    file file_sha1_in : t_char_file open read_mode is "sha1_in.csv";
    variable char_buffer : character;
    begin        
        rst_i <= '0';
        i <= 0;
        
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
        
        --Do it all again
        while SLOE = '0' loop
            wait until rising_edge(clk_i);
        end loop;
        
        rst_i <= '1';
        wait until rising_edge(clk_i);     
        rst_i <= '0';   
        wait until rising_edge(clk_i);  
        while not endfile(file_handshake2) loop
            read(file_handshake2, char_buffer);
            dat_i <= to_unsigned(character'pos(char_buffer), 8);
            i <= i + 1;
            wait until rising_edge(clk_i);
        end loop; 
        file_close(file_handshake2);
        
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