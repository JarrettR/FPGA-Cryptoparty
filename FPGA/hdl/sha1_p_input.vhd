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
    

end RTL; 