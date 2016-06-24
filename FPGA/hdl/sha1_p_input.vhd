library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sha1_load is

port(


    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(31 downto 0);
    sot_in         : in    std_ulogic;
    dat_o          : out    std_ulogic_vector(511 downto 0);
    
    x : out unsigned(31 downto 0)
    );
end sha1_load;

architecture RTL of sha1_load is

    type wordtable is array (0 to 79) of std_ulogic_vector(511 downto 0);
    signal w		:	wordtable;

begin

    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            w(0) <= dat_i(others => '0');
            x <= resize(a, x'length) + b; 
            dat_o <= dat_i; 
        end if;
    end process;	

end RTL; 