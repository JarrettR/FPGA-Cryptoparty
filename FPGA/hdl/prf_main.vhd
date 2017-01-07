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
    pmk_i           : in    pmk_data;
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
    
    signal state           : state_type := STATE_IDLE;
        
    signal pmk              : pmk_data;
    signal ssid            : ssid_data;
    signal ssid_length     : std_ulogic_vector(0 to 63);
        
    signal mk_in              : w_input;
    signal out_x1              : w_output;
    signal out_x2              : w_output;
    signal f1              : w_output;
    signal f2              : w_output;
    signal f1_con              : w_output;
    signal f2_con              : w_output;
    signal x1              : w_input;
    signal x2              : w_input;
    signal x1_in              : w_input;
    signal x2_in              : w_input;
    signal a              : w_input := X"5061697277697365206b657920657870616e73696f6e"; --Pairwise key expansion
    --signal mk              : w_input;
    --pmk: 5df920b5481ed70538dd5fd02423d7e2522205feeebb974cad08a52b5613ede2
    --a: Pairwise key expansion
    --b: 000b86c2a4850013ce5598efae12a150652e9bc22063720c5081e9eb74077fb19fffe871dc4ca1e6f448af85e8dfa16b8769957d8249a4ec68d2b7641d3782162ef0dc37b014cc48343e8dd2
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f8361
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f83611dc93e2657cecf69a3651bc4fca5880ce9081345
    --r: 5e9805e89cb0e84b45e5f9e4a1a80d9d9958c24e2b5ca71661334a890814f53e1d035e8beb4f83611dc93e2657cecf69a3651bc4fca5880ce9081345c5411d489313b29e4aaf287d5231a342b777a67a
  
    signal valid        :    std_ulogic;
    signal valid_x1        :    std_ulogic;
    signal valid_x2        :    std_ulogic;
    signal load_x1        :    std_ulogic;
    signal load_x2        :    std_ulogic;
     
    signal i: integer range 0 to 4096;
    
    begin
    
        HMAC: hmac_main port map (clk_i,rst_i,mk_in,x1_in,ssid_length,load_x1,out_x1,valid_x1);
    
    
        process(clk_i)   
        begin
            if (clk_i'event and clk_i = '1') then
                if rst_i = '1' then
                    state <= STATE_IDLE;
                    i <= 0;
                    valid_o <= '0';
                elsif load_i = '1' and state = STATE_IDLE then
                    i <= 0;
                    valid_o <= '0';
                    mk <= mk_i;
                    for x in 0 to 1 loop
                        mk_in(x) <= std_ulogic_vector(mk_i(x*4)) & std_ulogic_vector(mk_i(x * 4 + 1)) & std_ulogic_vector(mk_i(x * 4 + 2)) & std_ulogic_vector(mk_i(x * 4 + 3));
                    end loop;
                    --Todo: Fix this, it is dumb
                    mk_in(2) <= std_ulogic_vector(mk_i(8)) & std_ulogic_vector(mk_i(9)) & X"0000";
                    for x in 3 to 15 loop
                        mk_in(x) <= X"00000000";
                    end loop;
                    
                    for x in 0 to 4 loop
                        f1(x) <= X"00000000";
                        f2(x) <= X"00000000";
                    end loop;
                    
                    ssid <= ssid_i;
                    --Todo: Fix this, it is dumb too
                    x1_in(0) <= std_ulogic_vector(ssid_i(0)) & std_ulogic_vector(ssid_i(1)) & std_ulogic_vector(ssid_i(2)) & std_ulogic_vector(ssid_i(3));
                    x1_in(1) <= std_ulogic_vector(ssid_i(4)) & std_ulogic_vector(ssid_i(5)) & std_ulogic_vector(ssid_i(6)) & X"00";
                    x1_in(2) <= X"00000180";
                    x2_in(0) <= std_ulogic_vector(ssid_i(0)) & std_ulogic_vector(ssid_i(1)) & std_ulogic_vector(ssid_i(2)) & std_ulogic_vector(ssid_i(3));
                    x2_in(1) <= std_ulogic_vector(ssid_i(4)) & std_ulogic_vector(ssid_i(5)) & std_ulogic_vector(ssid_i(6)) & X"00";
                    x2_in(2) <= X"00000280";
                    for x in 3 to 15 loop
                        x1_in(x) <= X"00000000";
                        x2_in(x) <= X"00000000";
                    end loop;
                    ssid_length <= X"0000000000000258";
                    state <= STATE_X_START;
                elsif state = STATE_X_START then
                    load_x1 <= '1';
                    load_x2 <= '1';
                    state <= STATE_X_PROCESS;
                elsif state = STATE_X_PROCESS then
                    load_x1 <= '0';
                    load_x2 <= '0';
                    if valid_x1 = '1' and valid_x2 = '1' then
                        if i = 4095 then
                            state <= STATE_CLEANUP;
                        else
                            i <= i + 1;
                            for x in 0 to 4 loop
                                x1_in(x) <= out_x1(x);
                                x2_in(x) <= out_x2(x);
                                
                                f1(x) <= f1_con(x) xor out_x1(x);
                                f2(x) <= f2_con(x) xor out_x2(x);
                            end loop;
                            x1_in(5) <= X"80000000";
                            x2_in(5) <= X"80000000";
                            for x in 6 to 15 loop
                                x1_in(x) <= X"00000000";
                                x2_in(x) <= X"00000000";
                            end loop;
                            ssid_length <= X"00000000000002A0";
                            state <= STATE_X_START;
                        end if;
                    end if;
                elsif state = STATE_CLEANUP then
                    for x in 0 to 4 loop
                        f1(x) <= f1_con(x) xor out_x1(x);
                        f2(x) <= f2_con(x) xor out_x2(x);
                    end loop;
                    state <= STATE_FINISHED;
                elsif state = STATE_FINISHED then
                    valid_o <= '1';
                    state <= STATE_IDLE;
                end if;
            end if;
        end process;
        
        f1_con <= f1;
        f2_con <= f2;

end RTL; 