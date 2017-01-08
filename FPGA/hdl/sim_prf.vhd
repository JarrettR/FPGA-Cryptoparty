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
        load_i           : in    std_ulogic;
        pmk_i           : in    w_input;
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
    signal pmk               : w_input;
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
    prf: prf_main port map (clk_i,rst_i,load,pmk,anonce,cnonce,amac_dat,cmac_dat,ptk,valid);
    
    stim_proc: process
    begin        
        rst_i <= '0';
        i <= 0;
        load <= '0';
       
        --Ordinally will come from PBKDF2
        --5df920b5481ed70538dd5fd02423d7e2 522205feeebb974cad08a52b5613ede2
        pmk <= (X"5df920b5",X"481ed705",X"38dd5fd0",X"2423d7e2",
               X"522205fe",X"eebb974c",X"ad08a52b",X"5613ede2",
               others=>(X"00000000"));
        
        --b = min(apMac, cMac) + max(apMac, cMac) + min(apNonce, cNonce) + max(apNonce, cNonce)
        --We're assuming that min/max will be calculated host-side
        --Comes directly from handshake on host
        --000b86c2a485
        amac_dat <= (X"00",X"0b",X"86",X"c2",X"a4",X"85");
        --0013ce5598ef
        cmac_dat <= (X"00",X"13",X"ce",X"55",X"98",X"ef");
        
        --ae12a150652e9bc22063720c5081e9eb 74077fb19fffe871dc4ca1e6f448af85
        anonce <= (X"ae",X"12",X"a1",X"50",X"65",X"2e",X"9b",X"c2",X"20",X"63",X"72",X"0c",X"50",X"81",X"e9",X"eb",
                  X"74",X"07",X"7f",X"b1",X"9f",X"ff",X"e8",X"71",X"dc",X"4c",X"a1",X"e6",X"f4",X"48",X"af",X"85");
        --e8dfa16b8769957d8249a4ec68d2b764 1d3782162ef0dc37b014cc48343e8dd2
        cnonce <= (X"e8",X"df",X"a1",X"6b",X"87",X"69",X"95",X"7d",X"82",X"49",X"a4",X"ec",X"68",X"d2",X"b7",X"64",
                  X"1d",X"37",X"82",X"16",X"2e",X"f0",X"dc",X"37",X"b0",X"14",X"cc",X"48",X"34",X"3e",X"8d",X"d2");
        
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

   clock_process: process
   begin
		clk_i <= '0';
		wait for clock_period/2;
		clk_i <= '1';
		wait for clock_period/2;
   end process;
    
end Behavioral;
