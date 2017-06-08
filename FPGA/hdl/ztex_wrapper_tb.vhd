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
        fd      : inout std_logic_vector(15 downto 0);
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
        PKTEND    : out std_logic;
        RESET     : in std_logic;
        CONT     : in std_logic

--      SCL     : in std_logic;
--      SDA     : in std_logic
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
    signal IOA0 :  std_logic;   --cont
    signal SLOE :  std_logic;   --Output Enable
    signal SLRD :  std_logic;   --Slave Read
    signal SLWR :  std_logic;   --Slave Write
    signal PKTEND :  std_logic;
    signal FLAGB :  std_logic := '1';   --Flag B, Full
    signal FLAGC :  std_logic := '1';   --Flag C, Empty
    signal FIFOADR :  std_logic_vector(1 downto 0);
    signal CS   :  std_logic;   --CS1-4, AB11 on FPGA
    signal FD  :  std_logic_vector(15 downto 0);

    --TB FIFOs
    signal write_fifo_rd_clk :  std_logic;
    signal write_fifo_din :  std_logic_vector(7 downto 0);
    signal write_fifo_wr_en :  std_logic := '0';
    signal write_fifo_rd_en :  std_logic;
    signal write_fifo_dout :  std_logic_vector(7 downto 0);
    signal write_fifo_full :  std_logic := '0';
    signal write_fifo_empty :  std_logic := '0';
    signal read_fifo_wr_clk :  std_logic := '0';
    signal read_fifo_din :  std_logic_vector(7 downto 0);
    signal read_fifo_wr_en :  std_logic := '0';
    signal read_fifo_rd_en :  std_logic := '1';
    signal read_fifo_dout :  std_logic_vector(7 downto 0);
    signal read_fifo_full :  std_logic := '0';
    signal read_fifo_empty :  std_logic := '0';
    
    signal rst :  std_logic := '0';   
    
    signal endpoint2 :  std_logic := '0';
    signal endpoint6 :  std_logic := '0';
    
    type ep_type is (EP2,
                    EP4,
                    EP6,
                    EP8,
                    ERR
                    );
    signal endpoint : ep_type := EP2;
    
    --Simulation labels
    type test_type is (unint,
                    setup,
                    reset_fpga,
                    write_tb_fifo,
                    fifo_printout,
                    reset_tb,
                    write_state_machine_readcmd,
                    read_tb_fifo,
                    tb_complete,
                    ERR
                    );
    signal test_process : test_type := unint;
    
    constant clk_period : time := 1 ns;
    
begin
    -- component instantiation
    uut: ztex_wrapper port map(
		fd => FD,
        CS => CS,
        IFCLK => IFCLK,
        SLOE => SLOE,
        SLRD => SLRD,
        SLWR => SLWR,
        FIFOADR => FIFOADR,
        FLAGB => FLAGB,
        FLAGC => FLAGC,
        PKTEND => PKTEND,
		RESET => IOA7,
		CONT => IOA0
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
		 wr_clk => read_fifo_wr_clk,
		 rd_clk => IFCLK,
		 din => read_fifo_din,
		 wr_en => read_fifo_wr_en,
		 rd_en => read_fifo_rd_en,
		 dout => read_fifo_dout,
		 full => read_fifo_full,
		 empty => read_fifo_empty
	  );
    
    -- Endpoint identification
    with FIFOADR select endpoint <=
        EP2 when "00",
        EP4 when "01",
        EP6 when "10",
        EP8 when "11",
        ERR when others;
        
    endpoint2 <= '1' when endpoint = EP2 else '0';
    endpoint6 <= '1' when endpoint = EP6 else '0';
    
    --SR
    flagb <= '0' when endpoint6 = '1' and write_fifo_full = '1' else
             '0' when endpoint2 = '1' and read_fifo_full = '1' else
             '1';
    flagc <= '0' when endpoint6 = '1' and write_fifo_empty = '1' else
             '0' when endpoint2 = '1' and read_fifo_empty = '1' else
             '1';
    write_fifo_rd_en <= not SLOE when endpoint6 = '1' else
                        --'1' when write_fifo_empty = '1' else
                        '0';
                        
                        --empty/full flags don't get activated unless rd_clk is clocked
    write_fifo_rd_clk <= IFCLK when write_fifo_empty = '1' or endpoint6 = '1' else '0';
                         
    FD <= write_fifo_dout & write_fifo_dout when endpoint6 = '1' else (others => 'Z');
    read_fifo_din <= FD(15 downto 8) when endpoint2 = '1' else X"00";
    
    read_fifo_wr_clk <= IFCLK; -- when endpoint2 = '1' and slwr = '0' else '0';
    read_fifo_wr_en <= endpoint2;
    
    --  Test Bench Statements
    tb : process
     
    procedure fx_reset is
    begin
        --Reset on
        IOA7 <= '1';
        wait for 5 ns; 
        --Reset off
        IOA7 <= '0';
        wait for 5 ns;
    end fx_reset; 
    procedure fx_read is
    begin
        --Read from FPGA(Master)
        --FPGA writes to FX2(Slave)
        read_fifo_rd_en <= '1';
        wait for 30 ns;
    end fx_read; 
     
    procedure fx_write (
        wr_dat  : in std_logic_vector(7 downto 0)
        ) is
    begin
        --Write to FPGA(Master)
        --FPGA reads from FX2(Slave)
        write_fifo_din <= wr_dat;
        wait until rising_edge(IFCLK); 
    end fx_write; 
    
    
     begin
        test_process <= setup;
        rst <= '1';
        FD <= (others => 'Z');
        CS <= '0';
        IOA7 <= '0';
        wait for 5 ns;
        rst <= '0';
        
        --Reset FPGA
        test_process <= reset_fpga;
        IOA0 <= '1';
        CS <= '1';
        fx_reset;
        
        --assert current_value >= min_value
        --    report "current value too low"
        --    severity failure;
        
        test_process <= write_tb_fifo;
        write_fifo_wr_en <= '1';
        for i in 0 to 255 loop
            fx_write(std_logic_vector(to_unsigned(i, 8)));
        end loop;
        write_fifo_wr_en <= '0';

        test_process <= fifo_printout;
        wait for 35 ns;
        --assert current_value >= min_value
        --    report "current value too low"
        --    severity failure;
            
        test_process <= reset_fpga;
        fx_reset;
        wait for 15 ns; 
        
        test_process <= reset_tb;
        rst <= '1';
        wait for 5 ns; 
        rst <= '0';
        
        wait for 5 ns; 
        
        --Fixes a strange clock glitch
        wait for 0.1 ns;
        
        test_process <= write_state_machine_readcmd;
        write_fifo_wr_en <= '1';
        --1 puts FPGA in "read buffer" state
        --2-10 gets written into FPGA FIFO
        for i in 1 to 11 loop
            fx_write(std_logic_vector(to_unsigned(i, 8)));
        end loop;
        --2 puts FPGA in "write buffer" state
        fx_write(X"02");
        write_fifo_wr_en <= '0';
        
        test_process <= read_tb_fifo;
        wait for 5 ns; 
        --Read out entire read_fifo
        fx_read;
        wait for 5 ns; 
        
        
        wait for 30 ns; 
        CS <= '0';
        
        test_process <= tb_complete;
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
