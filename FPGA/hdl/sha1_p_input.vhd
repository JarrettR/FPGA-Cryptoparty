library ieee;
use ieee.std_logic_1164.all;


entity sha1_p_input is

port(
    clk_i          : in    std_ulogic;
    dat_1_i          : in    std_ulogic_vector(0 to 31);
    dat_2_i          : in    std_ulogic_vector(0 to 31);
    dat_3_i          : in    std_ulogic_vector(0 to 31);
    dat_4_i          : in    std_ulogic_vector(0 to 31);
    dat_o          : out    std_ulogic_vector(0 to 31)
    );
end sha1_p_input;

architecture RTL of sha1_p_input is

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            --self.CSL(self.W[t - 3] ^ self.W[t - 8]  ^ self.W[t - 14]  ^ self.W[t - 16], 1)
            
            dat_o <= dat_1_i XOR dat_2_i XOR dat_3_i XOR dat_4_i;
            
        end if;
    end process;	
    

end RTL; library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_load is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(0 to 31);
    sot_in         : in    std_ulogic;
    dat_1_o          : out    std_ulogic_vector(0 to 31);
    dat_2_o          : out    std_ulogic_vector(0 to 31);
    dat_3_o          : out    std_ulogic_vector(0 to 31)
    
    );
end sha1_load;

architecture RTL of sha1_load is
    component sha1_p_input
      port (clk_i: in std_ulogic;
        dat_1_i, dat_2_i, dat_3_i, dat_4_i: in std_ulogic_vector(0 to 31);
      dat_o : out std_ulogic_vector(0 to 31));
    end component;
    
    --type w_type is array(0 to 79) of std_ulogic_vector(0 to 31);
    signal w: w_type;
    signal w_temp: w_type;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            for i in 0 to 79 loop
                if i = 0 then
                    w(i) <= dat_i;
                elsif i < 16 then
                    w(i) <= w(i - 1);
                else
                    --These are all one register behind where you'd expect, because they haven't been shifted yet
                    --w(i) <= "11111111111111111111111111111111";
                    w(i) <= w(i - 3);
                    --w(i) <= (w(i - 3)(1 to 31) & w(i - 3)(0)) XOR
                    --    (w(i - 8)(1 to 31) & w(i - 8)(0)) XOR
                    --    (w(i - 14)(1 to 31) & w(i - 14)(0)) XOR
                    --    (w(i - 16)(1 to 31) & w(i - 16)(0));
                end if;
            end loop;
            --w <= w_temp;
        end if;
    end process;
    dat_1_o <= w(15);
    dat_2_o <= w(16);
    dat_3_o <= w(17);	
    
    GEN_REG: for i in 16 to 79 generate
        w_temp(i) <= w(i - 3);
    end generate GEN_REG;
    
    --dat_o <= "00110011001100110011001100110011" XOR "11001100110011001100110011001100" XOR "11001100110011001100110011001100" XOR "00110011001100110011001100110011";
    --dat_o <= w(16 - 3) XOR w(16 - 8) XOR w(16 - 14) XOR w(16 - 16);
    --dat_o <= w(15)(3 to 31) & w(15)(0 to 2); --w(15); 
    --dat_o <= w(20); 

end RTL; 