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
    
    COMPONENT fx2_fifo
      PORT (
        rst : IN STD_LOGIC;
        wr_clk : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
      );
    END COMPONENT;

    --signal IOA0 :  std_logic;   --sck
    --signal IOA1 :  std_logic;   --dir_i
    --signal IOA2 :  std_logic;   --empty_o
    signal IFCLK :  std_logic;
    signal IOA7 :  std_logic;   --reset
    signal SLOE :  std_logic;   --Output Enable
    signal SLRD :  std_logic;   --Slave Read
    signal SLWR :  std_logic;   --Slave Write
    signal FLAGB :  std_logic := '1';   --Flag B, Full
    signal FLAGC :  std_logic := '1';   --Flag C, Empty
    signal FIFOADR :  std_logic_vector(1 downto 0);
    signal CS   :  std_logic;   --CS1-4, AB11 on FPGA
    signal IOB  :  std_logic_vector(7 downto 0);
    signal IOC  :  std_logic_vector(7 downto 0);
    signal data  :  std_logic_vector(7 downto 0);
    
    signal slrd_read :  std_logic;   --Read cycle
    signal slwr_read :  std_logic;

    --TB FIFOs
    signal write_fifo_rd_clk :  std_logic;
    signal write_fifo_din :  std_logic_vector(7 downto 0);
    signal write_fifo_wr_en :  std_logic := '0';
    signal write_fifo_rd_en :  std_logic;
    signal write_fifo_dout :  std_logic_vector(7 downto 0);
    signal write_fifo_full :  std_logic := '0';
    signal write_fifo_empty :  std_logic := '0';
    signal read_fifo_din :  std_logic_vector(7 downto 0);
    signal read_fifo_wr_en :  std_logic := '0';
    signal read_fifo_rd_en :  std_logic := '0';
    signal read_fifo_dout :  std_logic_vector(7 downto 0);
    signal read_fifo_full :  std_logic := '0';
    signal read_fifo_empty :  std_logic := '0';
    
    signal rst :  std_logic := '0';   
    
    signal endpoint2 :  std_logic := '0';
    signal endpoint4 :  std_logic := '0';
    
    type ep_type is (EP2,
                    EP4,
                    EP6,
                    EP8,
                    ERR
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
    write_fifo : fx2_fifo port map (
		 rst => rst,
		 wr_clk => IFCLK,
		 rd_clk => write_fifo_rd_clk,
		 din => write_fifo_din,
		 wr_en => write_fifo_wr_en,
		 rd_en => write_fifo_rd_en,
		 dout => write_fifo_dout,
		 full => write_fifo_full,
		 empty => write_fifo_empty
	  );
    read_fifo : fx2_fifo port map (
		 rst => rst,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din => read_fifo_din,
		 wr_en => read_fifo_wr_en,
		 rd_en => read_fifo_rd_en,
		 dout => read_fifo_dout,
		 full => read_fifo_full,
		 empty => read_fifo_empty
	  );
    
    -- Shift register
--    reg_gen: for i in 0 to 254 generate
--        ep2_conc(i + 1) <= ep2_buff(i);
--        ep4_conc(i) <= ep4_buff(i + 1);
--        --ep4_conc(i) <= ep4_init(i + 1) when setup = '1' else ep4_buff(i + 1);
--    end generate reg_gen;

    -- Endpoint identification
    with FIFOADR select endpoint <=
        EP2 when "00",
        EP4 when "01",
        EP6 when "10",
        EP8 when "11",
        ERR when others;
        
    endpoint2 <= '1' when endpoint = EP2 else '0';
    endpoint4 <= '1' when endpoint = EP4 else '0';
    
    --SR
    flagb <= '0' when endpoint4 = '1' and write_fifo_full = '1' else
             '0' when endpoint2 = '1' else --and write_fifo_empty = '1' else
             '1';
    flagc <= '0' when endpoint4 = '1' and write_fifo_empty = '1' else
             '0' when endpoint2 = '1' else --and write_fifo_empty = '1' else
             '1';
    write_fifo_rd_en <= not SLOE when endpoint4 = '1' and write_fifo_empty = '0' else
                        '1' when write_fifo_empty = '1' else
                        '0';
    write_fifo_rd_clk <= slrd when endpoint4 = '1' and write_fifo_empty = '0' else
                         IFCLK when write_fifo_empty = '1' else
                         '0';
    IOC <= write_fifo_dout when endpoint4 = '1' else X"00";
    
    --  Test Bench Statements
    tb : process
     
    procedure fx_read is
    begin
        --Read from FPGA(Master)
--        if endpoint = EP2 then
--            wait until SLWR = '0' and rising_edge(IFCLK); 
--            slwr_read <= '1';
--            --FLAGC <= '1'; -- Not empty
--            ep2_buff(0) <= IOB;
--            wait until SLWR = '1' and rising_edge(IFCLK); 
--            slwr_read <= '0';
--            for i in 1 to 255 loop
--                ep2_buff(i) <= ep2_conc(i);
--            end loop;
--        end if;
    end fx_read; 
     
    procedure fx_write (
        wr_dat  : in std_logic_vector(7 downto 0)
        ) is
    begin
        --Write to FPGA(Master)
        
        write_fifo_din <= wr_dat;
        wait until rising_edge(IFCLK); 
--        if endpoint = EP4 then
--            wait until SLOE = '0' and rising_edge(IFCLK); 
--            slrd_read <= '1';
--            IOC <= ep4_buff(0);
--            wait until SLRD = '0' and rising_edge(IFCLK); 
--            ep4_buff(0) <= ep4_conc(1);
--            IOC <= ep4_conc(1);
--            slrd_read <= '0';
--        end if;
    end fx_write; 
    
    
     begin
        rst <= '1';
        --FLAGB <= '0';
        --FLAGC <= '0';
        IOC <= "ZZZZZZZZ";
        CS <= '0';
        IOA7 <= '0';
        --IOA1 <= '0';
        --IOA0 <= '0';
        slrd_read <= '0';
        slwr_read <= '0';
        --sloe_read <= '0';
        wait for 5 ns;
        rst <= '0';
        
        --Reset FPGA
        wait for 5 ns;
        CS <= '1';
        wait for 5 ns; 
        --Reset on
        IOA7 <= '1';
        wait for 5 ns; 
        --Reset off
        IOA7 <= '0';
        wait for 5 ns; 
        
        write_fifo_wr_en <= '1';
        for i in 0 to 255 loop
            fx_write(std_logic_vector(to_unsigned(i, 8)));
        end loop;
        write_fifo_wr_en <= '0';

        wait for 35 ns; -- wait until global set/reset completes
        
        CS <= '1';
        
        wait for 5 ns; 
        
        --Reset on
        IOA7 <= '1';
        
        wait for 5 ns; 
        
        --Reset off
        IOA7 <= '0';
        
--        wait for 5 ns; 
--        fx_write(X"30");
--        wait for 5 ns; 
--        fx_read;
--        wait for 5 ns; 
--        fx_write(X"31");
--        wait for 5 ns; 
--        fx_read;
--        wait for 5 ns; 
--        fx_write(X"32");
        wait for 5 ns; 
        fx_read;
        wait for 5 ns; 
        
        
        wait for 20 ns; 
        CS <= '0';
--        --Write
--        fx_read;



        wait; -- will wait forever
    end process tb;
  --  End Test Bench 

    clk_process: process
    begin
        IFCLK <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        IFCLK <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    end process;
  
  end;
