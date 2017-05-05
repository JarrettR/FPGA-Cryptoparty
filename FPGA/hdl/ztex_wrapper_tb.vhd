-- TestBench simulating FX2LP USB interface 

  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.sha1_pkg.all;

  entity testbench is
  end testbench;

  architecture behavior of testbench is 

    component ztex_wrapper
    port(
        pc      : in std_logic_vector(7 downto 0);
        pb      : out std_logic_vector(7 downto 0);
        CS      : in std_logic;
        CLK     : in std_logic;
        IFCLK     : in std_logic;
        sck_i     : in std_logic;
        dir_i     : in std_logic;
        empty_o     : out std_logic;
        rst_i     : in std_logic

        --   SLRD     : in std_logic;
        --   SLWR     : in std_logic;
        --      SCL     : in std_logic;
        --      SDA     : in std_logic
        );
    end component;

    signal clk  :  std_logic := '0';
    signal IOA0 :  std_logic;   --sck
    signal IOA1 :  std_logic;   --dir_i
    signal IOA2 :  std_logic;   --empty_o
    signal IOA7 :  std_logic;   --reset
    signal CS   :  std_logic;   --CS1-4, AB11 on FPGA
    signal IOB  :  std_logic_vector(7 downto 0);
    signal IOC  :  std_logic_vector(7 downto 0);
    signal data  :  std_logic_vector(7 downto 0);
    
    constant clk_period : time := 1 ns;

  begin

  -- component instantiation
          uut: ztex_wrapper port map(
                pc => IOC,
                pb => IOB,
                CS => CS,
                CLK => clk,
                IFCLK => clk,
                sck_i => IOA0,
                dir_i => IOA1,
                empty_o => IOA2,
                rst_i => IOA7
          );


  --  Test Bench Statements
     tb : process
     begin
        CS <= '0';
        IOA7 <= '0';
        IOA1 <= '0';
        IOA0 <= '0';

        wait for 40 ns; -- wait until global set/reset completes
        
        CS <= '1';
        
        wait for 5 ns; 
        
        IOC <= X"30";
        
        wait for 5 ns; 
        
        --Reset on
        IOA7 <= '1';
        
        wait for 5 ns; 
        
        --Reset off
        IOA7 <= '0';
        
        wait for 10 ns; 
        
        --Write direction
        IOA1 <= '0';
        
        wait for 5 ns; 
        
        --sck
        IOA0 <= '1';
        
        wait for 5 ns; 
        
        IOA0 <= '0';
        
        wait for 5 ns; 
        
        --sck
        IOA0 <= '1';
        
        wait for 5 ns; 
        
        IOA0 <= '0';
        
        wait for 5 ns; 
        
        --sck
        IOA0 <= '1';
        
        wait for 5 ns; 
        
        IOA0 <= '0';
        
        wait for 5 ns; 
        
        --sck
        IOA0 <= '1';
        
        wait for 5 ns; 
        
        IOA0 <= '0';
        
        wait for 5 ns; 
        
        --Read direction
        IOA1 <= '1';
        
        wait for 5 ns; 
        
        --sck
        IOA0 <= '1';
        
        wait for 5 ns; 
        
        IOA0 <= '0';
        
        wait for 5 ns; 
        
        data <= IOB;
        
        wait for 5 ns; 


        wait; -- will wait forever
     end process tb;
  --  End Test Bench 

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;
  
  end;
