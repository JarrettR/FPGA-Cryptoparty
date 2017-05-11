-- TestBench simulating FX2LP USB interface
-- Waveforms on page 105 http://www.cypress.com/file/126446/download

  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.sha1_pkg.all;

  entity testbench is
  end testbench;

  architecture behavior of testbench is 

    component ztex_wrapper
    port(
        pc_i      : in std_logic_vector(7 downto 0);
        pb_o      : out std_logic_vector(7 downto 0);
        CS      : in std_logic;
        IFCLK     : in std_logic;
        --FXCLK     : in std_logic;
        --sck_i     : in std_logic;
        SLOE     : out std_logic;
        SLRD     : out std_logic;
        SLWR     : out std_logic;
        FIFOADR : out std_logic_vector(1 downto 0);
        FLAGB    : in std_logic;  --Full
        FLAGC    : in std_logic; --Empty
        rst_i     : in std_logic
   );
    end component;

    --signal IOA0 :  std_logic;   --sck
    --signal IOA1 :  std_logic;   --dir_i
    --signal IOA2 :  std_logic;   --empty_o
    signal IFCLK :  std_logic;
    signal IOA7 :  std_logic;   --reset
    signal SLOE :  std_logic;   --Output Enable
    signal SLRD :  std_logic;   --Slave Read
    signal SLWR :  std_logic;   --Slave Write
    signal FLAGB :  std_logic;   --Flag B, Full
    signal FLAGC :  std_logic;   --Flag C, Empty
    signal FIFOADR :  std_logic_vector(1 downto 0);
    signal CS   :  std_logic;   --CS1-4, AB11 on FPGA
    signal IOB  :  std_logic_vector(7 downto 0);
    signal IOC  :  std_logic_vector(7 downto 0);
    signal data  :  std_logic_vector(7 downto 0);
    
    signal slrd_read :  std_logic;   --Read cycle
    signal slwr_read :  std_logic; 
    
    signal setup :  std_logic := '0';   
    
    type data_buffer is array (0 to 255) of std_logic_vector(7 downto 0);
    signal ep2_buff  :  data_buffer; --In
    signal ep2_conc  :  data_buffer;
    signal ep4_buff  :  data_buffer := ((others=> (others=>'0'))); --Out
    signal ep4_conc  :  data_buffer := ((others=> (others=>'0')));
    signal ep4_init  :  data_buffer;
    
    type ep_type is (EP2,
                    EP4,
                    EP6,
                    EP8
                    );
    signal endpoint : ep_type := EP2;
    
    constant clk_period : time := 1 ns;
    
begin
    -- component instantiation
    uut: ztex_wrapper port map(
        pc_i => IOC,
        pb_o => IOB,
        CS => CS,
        IFCLK => IFCLK,
        SLOE => SLOE,
        SLRD => SLRD,
        SLWR => SLWR,
        FLAGB => FLAGB,
        FLAGC => FLAGC,
        FIFOADR => FIFOADR,
        --sck_i => IOA0,
        --dir_i => IOA1,
        --empty_o => IOA2,
        rst_i => IOA7
    );
    
    -- Shift register
    reg_gen: for i in 0 to 254 generate
        --ep2_conc(i) <= ep2_buff(i + 1);
        ep4_conc(i) <= ep4_buff(i + 1);
        --ep4_conc(i) <= ep4_init(i + 1) when setup = '1' else ep4_buff(i + 1);
    end generate reg_gen;

    -- Endpoint identification
    with FIFOADR select endpoint <=
        EP2 when "00",
        EP4 when "01",
        EP6 when "10",
        EP8 when "11";

    --  Test Bench Statements
    tb : process
     
    procedure fx_read is
    begin
        --IOA1 <= '1';
        wait for 2 ns; 
        --IOA0 <= '1';
        wait for 2 ns; 
        --IOA0 <= '0';
        wait for 2 ns; 
        data <= IOB;
    end fx_read; 
     
--    procedure fx_write (
--        wr_dat  : in std_logic_vector(7 downto 0)
--        ) is
--    begin
--        IOC <= wr_dat;
--        wait for 2 ns; 
--        FLAGC <= '0';
--        wait for 2 ns; 
--    end fx_write; 
    
    
     begin
        FLAGB <= '0';
        FLAGC <= '0';
        CS <= '0';
        IOA7 <= '0';
        --IOA1 <= '0';
        --IOA0 <= '0';
        slrd_read <= '0';
        slwr_read <= '0';
        for i in 0 to 255 loop
            ep4_init(i) <= std_logic_vector(to_unsigned(i, ep4_buff(i)'length));
        end loop;
        wait for 5 ns;
        --setup <= '0';

        wait for 35 ns; -- wait until global set/reset completes
        
        CS <= '1';
        
        wait for 5 ns; 
        
        --Reset on
        IOA7 <= '1';
        
        wait for 5 ns; 
        
        --Reset off
        IOA7 <= '0';
        
        wait for 10 ns; 
--        
--        --Write
--        fx_write(X"30");
--        fx_read;



        wait; -- will wait forever
    end process tb;
  --  End Test Bench 

    tb_fifo_write: process(SLWR)
    begin
        if SLWR'event and SLWR = '1' then
        
            if endpoint = EP4 then -- Out from host
                for i in 0 to 255 loop
                    --ep4_buff(i) <= ep4_conc(i);
                    if setup = '0' then
                        ep4_buff(i) <= ep4_init(i);
                    else
                        ep4_buff(i) <= ep4_conc(i);
                    end if;
                end loop;
                IOC <= ep4_conc(1);
                setup <= '1';
            end if;
        end if;
    end process;
    
    tb_fifo_read: process(SLRD)
    begin
        if SLRD'event and SLRD = '1' then
            if endpoint = EP2 then -- In to host
                --
            end if;
        end if;
    end process;
    
--    tb_fifo_slave: process(IFCLK)
--    begin
--        if IFCLK'event and IFCLK = '1' then
--            if endpoint = EP2 then -- In to host
--                if SLWR = '1' then -- In to host
--                    --
--                end if;
--            elsif endpoint = EP4 then -- Out from host
--                --
--            end if;
--        end if;
--    end process;
        
    clk_process: process
    begin
        IFCLK <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        IFCLK <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;
  
  end;
