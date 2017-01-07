----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/26/2016 11:44:06 PM
-- Design Name: 
-- Module Name: sim_prf - Behavioral
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

entity sim_prf is
end sim_prf;

architecture Behavioral of sim_prf is
    component prf_main is
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        pmk_i           : in    pmk_data;
        anonce_dat      : in    nonce_data;
        cnonce_dat      : in    nonce_data;
        amac_dat        : in    mac_data;
        cmac_dat        : in    mac_data;
        ptk_dat_o        : out   ptk_data;
        ptk_valid_o      : out   std_ulogic
    );
    end component;

    signal valid             : std_ulogic;
    signal load              : std_ulogic := '0';
    signal clk_i             : std_ulogic := '0';
    signal rst_i             : std_ulogic := '0';
    signal pmk                : pmk_data;
    signal anonce            : nonce_data;
    signal cnonce            : nonce_data;
    signal amac_dat          : mac_data;
    signal cmac_dat          : mac_data;
    signal ptk               : ptk_data;
        
        
    --pmk: 5df920b5481ed70538dd5fd02423d7e2522205feeebb974cad08a52b5613ede2
    --a: 5061697277697365206b657920657870616e73696f6e
    --b: 000b86c2a4850013ce5598efae12a150652e9bc22063720c5081e9eb74077fb19fffe871dc4ca1e6f448af85e8dfa16b8769957d8249a4ec68d2b7641d3782162ef0dc37b014cc48343e8dd2
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f8361
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f83611dc93e2657cecf69a3651bc4fca5880ce9081345
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f83611dc93e2657cecf69a3651bc4fca5880ce9081345c5411d489313b29e4aaf287d5231a342b777a67a
    --ptk: 5e9805e89cb0e84b45e5f9e4a1a80d9d
    
    
    signal i: integer range 0 to 65535;
    constant clock_period : time := 1 ns;
    
 begin      
    prf: prf_main port map (clk_i,rst_i,pmk,anonce, cnonce,amac_dat,cmac_dat,ptk,valid);
    
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
