----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/26/2016 11:44:06 PM
-- Design Name: 
-- Module Name: sim_pbkdf2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.sha1_pkg.all;

entity sim_pbkdf2 is
end sim_pbkdf2;

architecture Behavioral of sim_pbkdf2 is
    component pbkdf2_main is
    port(
        clk_i               : in    std_ulogic;
        rst_i               : in    std_ulogic;
        load_i              : in    std_ulogic;
        mk_i                : in    mk_data;
        ssid_i              : in    ssid_data;
        dat_o               : out    w_output;
        valid_o             : out    std_ulogic   
    );
    end component;

    signal valid              : std_ulogic;
    signal load              : std_ulogic := '0';
    signal clk_i              : std_ulogic := '0';
    signal rst_i              : std_ulogic := '0';
    signal mk                : mk_data;
    signal ssid              : ssid_data;
    signal dat               : w_output;
        
    signal i: integer range 0 to 65535;
    constant clock_period : time := 1 ns;
    
 begin      
    pbkdf2: pbkdf2_main port map (clk_i,rst_i, load, mk, ssid, dat, valid);
    
    stim_proc: process
    begin        
        rst_i <= '0';
        i <= 0;
        load <= '0';
        
        for x in 0 to 35 loop
            ssid(x) <= X"00";
        end loop; 
        
        --linksys
        --6c 69 6e 6b 73 79 73  
        ssid(0) <= X"6C";
        ssid(1) <= X"69";
        ssid(2) <= X"6E";
        ssid(3) <= X"6B";
        ssid(4) <= X"73";
        ssid(5) <= X"79";
        ssid(6) <= X"73";
        
        --dictionary
        --64 69 63 74 69 6f 6e 61 72 79
        for x in 0 to 9 loop
            mk(x) <= X"00";
        end loop; 
        mk(0) <= X"64";
        mk(1) <= X"69";
        mk(2) <= X"63";
        mk(3) <= X"74";
        mk(4) <= X"69";
        mk(5) <= X"6F";
        mk(6) <= X"6E";
        mk(7) <= X"61";
        mk(8) <= X"72";
        mk(9) <= X"79";
        
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
    
end Behavioral;
