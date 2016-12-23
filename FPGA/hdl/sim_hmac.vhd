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
        secret_i        : in    w_input;
        value_i         : in    w_input;
        value_len_i     : in    std_ulogic_vector(0 to 63);
        load_i          : in    std_ulogic;
        dat_o           : out    w_input;
        valid_o         : out    std_ulogic    
    );
    end component;
   
    signal i: integer range 0 to 65535;
    
    signal rst_i: std_ulogic := '0';
    signal clk_i: std_ulogic := '0';
    
    signal load: std_ulogic := '0';
    signal valid: std_ulogic;
    
    signal secret: w_input;
    signal value: w_input;
    signal value_len: std_ulogic_vector(0 to 63) := X"00000000000002E0";
    
    signal dat_o: w_input;
    
    constant clock_period : time := 1 ns;
    
begin

    hmac1: hmac_main port map (clk_i,rst_i, secret, value, value_len, load, dat_o, valid);
    
    stim_proc: process
    begin        
        rst_i <= '0';
        i <= 0;
        load <= '0';
        
        secret(0) <= X"4A656665"; --Jefe
        secret(1) <= X"00000000";
        secret(2) <= X"00000000";
        secret(3) <= X"00000000";
        secret(4) <= X"00000000";
        secret(5) <= X"00000000";
        secret(6) <= X"00000000";
        secret(7) <= X"00000000";
        secret(8) <= X"00000000";
        secret(9) <= X"00000000";
        secret(10) <= X"00000000";
        secret(11) <= X"00000000";
        secret(12) <= X"00000000";
        secret(13) <= X"00000000";
        secret(14) <= X"00000000";
        secret(15) <= X"00000000";
        
        --what do ya want for nothing?
        value(0) <= X"77686174"; 
        value(1) <= X"20646F20";
        value(2) <= X"79612077";
        value(3) <= X"616E7420";
        value(4) <= X"666F7220";
        value(5) <= X"6E6F7468";
        value(6) <= X"696E673F";
        value(7) <= X"80000000";
        value(8) <= X"00000000";
        value(9) <= X"00000000";
        value(10) <= X"00000000";
        value(11) <= X"00000000";
        value(12) <= X"00000000";
        value(13) <= X"00000000";
        value(14) <= X"00000000";
        value(15) <= X"00000000";
        
        wait until rising_edge(clk_i);	
        rst_i <= '1';
        wait until rising_edge(clk_i);     
        rst_i <= '0';   
        wait until rising_edge(clk_i);  
        load <= '1';
        wait until rising_edge(clk_i);     
        load <= '0';   
        wait until rising_edge(clk_i);  
        
        while valid = '0' loop
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