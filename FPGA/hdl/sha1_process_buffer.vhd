library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_load is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    w              : in    w_type;
    dat_o          : out    std_ulogic_vector(0 to 31)
    
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
    GEN_REG: for i in 16 to 79 generate
        w_temp(i) <= (w(i - 3)(1 to 31) & w(i - 3)(0)) XOR
            (w(i - 8)(1 to 31) & w(i - 8)(0)) XOR
            (w(i - 14)(1 to 31) & w(i - 14)(0)) XOR
            (w(i - 16)(1 to 31) & w(i - 16)(0));
    end generate GEN_REG;
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
        
            w(0) <= dat_i;
            
            for i in 1 to 15 loop
                w(i) <= w(i - 1);
            end loop;
            for i in 16 to 79 loop
                w(i) <= (w(i - 3)(1 to 31) & w(i - 3)(0)) XOR
                    (w(i - 8)(1 to 31) & w(i - 8)(0)) XOR
                    (w(i - 14)(1 to 31) & w(i - 14)(0)) XOR
                    (w(i - 16)(1 to 31) & w(i - 16)(0));
            end loop;
            
        end if;
    end process;	
    
    --GEN_REG: for i in 16 to 79 generate
    --REGX : sha1_p_input port map
    --    (clk_i, w(13), w(8), w(2), w_in(0), w_in(0));
    --    (clk_i, w(i - 3), w(i - 8), w(i - 14), w_in(i - 16), w_in(i));
    --end generate GEN_REG;
    
    --dat_o <= "00110011001100110011001100110011" XOR "11001100110011001100110011001100" XOR "11001100110011001100110011001100" XOR "00110011001100110011001100110011";
    --dat_o <= w(16 - 3) XOR w(16 - 8) XOR w(16 - 14) XOR w(16 - 16);
    --dat_o <= w(15)(3 to 31) & w(15)(0 to 2); --w(15); 
    dat_o <= w(16); 

end RTL; 