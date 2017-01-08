--------------------------------------------------------------------------------
--                        prf_main.vhd
--    Pseudorandom function. PMK, MACs, and Nonces in, PTK out
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


entity prf_main is

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
end prf_main;

architecture RTL of prf_main is
    component hmac_main
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        secret_i        : in    w_input;
        value_i         : in    w_input;
        value_len_i     : in    std_ulogic_vector(0 to 63);
        load_i          : in    std_ulogic;
        dat_o           : out    w_output;
        valid_o         : out    std_ulogic
        );
    end component;

    
    type state_type is (STATE_IDLE,
                        STATE_X_START, STATE_X_PROCESS,
                        STATE_CLEANUP, STATE_FINISHED);
    
    signal state          : state_type := STATE_IDLE;
        
    --signal pmk            : w_input;
    signal ssid_length    : std_ulogic_vector(0 to 63);
        
    signal mk_in          : w_input;
    signal out_x1         : w_output;
    signal out_x2         : w_output;
    signal f1             : w_output;
    signal f2             : w_output;
    signal f1_con         : w_output;
    signal f2_con         : w_output;
    signal x1             : w_input;
    signal x2             : w_input;
    signal x1_in          : w_input;
    signal x2_in          : w_input;
    signal r              : w_input;
    
    constant a              : w_input := (others=>(X"00000000"));--X"50616972", X"77697365", X"206b6579", X"20657870", X"616e7369", X"6f6e0000" others=>(others=>('0')); --Pairwise key expansion
        
    --pmk: 5df920b5481ed70538dd5fd02423d7e2522205feeebb974cad08a52b5613ede2
    --a: Pairwise key expansion
    --b: 000b86c2a4850013ce5598efae12a150652e9bc22063720c5081e9eb74077fb19fffe871dc4ca1e6f448af85e8dfa16b8769957d8249a4ec68d2b7641d3782162ef0dc37b014cc48343e8dd2
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f8361
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f83611dc93e2657cecf69a3651bc4fca5880ce9081345
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f83611dc93e2657cecf69a3651bc4fca5880ce9081345c5411d489313b29e4aaf287d5231a342b777a67a
  
    signal valid        :    std_ulogic;
    signal valid_x1        :    std_ulogic;
    signal load        :    std_ulogic;
     
    signal i: integer range 0 to 4096;
    
    begin
    
        HMAC: hmac_main port map (clk_i,rst_i,pmk_i,a,ssid_length,load,out_x1,valid_x1);
    
        process(clk_i)   
        begin
            if (clk_i'event and clk_i = '1') then
                if rst_i = '1' then
                    state <= STATE_IDLE;
                    i <= 0;
                    ptk_valid_o <= '0';
                elsif load_i = '1' and state = STATE_IDLE then
                    i <= 0;
                    ptk_valid_o <= '0';
                    state <= STATE_FINISHED;
                elsif state = STATE_FINISHED then
                    ptk_valid_o <= '1';
                    state <= STATE_IDLE;
                end if;
            end if;
        end process;
        
        f1_con <= f1;
        f2_con <= f2;

end RTL; 