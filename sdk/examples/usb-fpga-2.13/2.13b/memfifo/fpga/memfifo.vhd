library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-- 
--   Top level module: glues everything together.    
--  

entity memfifo is 
     port (
        fxclk_in : in std_logic;
        ifclk_in : in std_logic;
        reset    : in std_logic;
        mode     : in std_logic_vector(1 downto 0);
        -- debug
        led1 : out std_logic_vector(9 downto 0);
        led2 : out std_logic_vector(19 downto 0);
        SW8  : in std_logic;
        SW10 : in std_logic;
        -- ddr3
        ddr3_dq      : inout std_logic_vector(15 downto 0);
        ddr3_dqs_n   : inout std_logic_vector(1 downto 0);
        ddr3_dqs_p   : inout std_logic_vector(1 downto 0);
        ddr3_addr    : out std_logic_vector(13 downto 0);
        ddr3_ba      : out std_logic_vector(2 downto 0);
        ddr3_ras_n   : out std_logic;
        ddr3_cas_n   : out std_logic;
        ddr3_we_n    : out std_logic;
        ddr3_reset_n : out std_logic;
        ddr3_ck_p    : out std_logic_vector(0 downto 0);
        ddr3_ck_n    : out std_logic_vector(0 downto 0);
        ddr3_cke     : out std_logic_vector(0 downto 0);
        ddr3_dm      : out std_logic_vector(1 downto 0);
        ddr3_odt     : out std_logic_vector(0 downto 0);
        -- ez-usb
        fd        : inout std_logic_vector(15 downto 0);
        SLWR      : out std_logic;
        SLRD      : out std_logic;
        SLOE      : out std_logic;
        FIFOADDR0 : out std_logic;
        FIFOADDR1 : out std_logic;
        PKTEND    : out std_logic;
        FLAGA     : in std_logic;
        FLAGB     : in std_logic
    );
end memfifo; 

architecture RTL of memfifo is 


component dram_fifo
    generic (
	-- fifo parameters, see "7 Series Memory Resources" user guide (ug743)
        ALMOST_EMPTY_OFFSET1 : INTEGER := 16; 
        ALMOST_EMPTY_OFFSET2 : INTEGER := 16;
        ALMOST_FULL_OFFSET1 : INTEGER := 16;
        ALMOST_FULL_OFFSET2 : INTEGER := 16;
        FIRST_WORD_FALL_THROUGH : String := "TRUE";
        -- clock dividers for PLL outputs not used for memory interface, VCO frequency is 1200 MHz
        CLKOUT2_DIVIDE : INTEGER := 1;
        CLKOUT3_DIVIDE : INTEGER := 1;
        CLKOUT4_DIVIDE : INTEGER := 1;
        CLKOUT5_DIVIDE : INTEGER := 1;
        CLKOUT2_PHASE : INTEGER := 0;
        CLKOUT3_PHASE : INTEGER := 0;
        CLKOUT4_PHASE : INTEGER := 0;
        CLKOUT5_PHASE : INTEGER := 0
    );
    port (
        fxclk_in  : in std_logic;	-- 48 MHz input clock pin
        reset     : in std_logic;	-- reset in
        reset_out : out std_logic;	-- reset output
        -- PLL clock outputs not used for memory interface
        clkout2 : out std_logic;	
        clkout3 : out std_logic;
        clkout4 : out std_logic;
        clkout5 : out std_logic;

	-- ddr3 pins
        ddr3_dq      : inout std_logic_vector(15  downto 0);
        ddr3_dqs_n   : inout std_logic_vector(1  downto 0);
        ddr3_dqs_p   : inout std_logic_vector(1  downto 0);
        ddr3_addr    : out std_logic_vector(13  downto 0);
        ddr3_ba      : out std_logic_vector(2  downto 0);
        ddr3_ras_n   : out std_logic;
        ddr3_cas_n   : out std_logic;
        ddr3_we_n    : out std_logic;
        ddr3_reset_n : out std_logic;
        ddr3_ck_p    : out std_logic_vector(0  downto 0);
        ddr3_ck_n    : out std_logic_vector(0  downto 0);
        ddr3_cke     : out std_logic_vector(0  downto 0);
        ddr3_dm      : out std_logic_vector(1  downto 0);
        ddr3_odt     : out std_logic_vector(0  downto 0);

	-- input fifo interface, see "7 Series Memory Resources" user guide (ug743)
        DI          : in std_logic_vector(127  downto 0);
        FULL        : out std_logic;
        ALMOSTFULL1 : out std_logic;
        ALMOSTFULL2 : out std_logic;
        WRERR       : out std_logic;
        WRCLK       : in std_logic;
        WREN        : in std_logic;

	-- output fifo interface, see "7 Series Memory Resources" user guide (ug743)
        DO           : out std_logic_vector(127  downto 0);
        EMPTY        : out std_logic;
        ALMOSTEMPTY1 : out std_logic;
        ALMOSTEMPTY2 : out std_logic;
        RDERR        : out std_logic;
        RDCLK        : in std_logic;
        RDEN         : in std_logic;

	-- free memory
        mem_free_out : out std_logic_vector(24 downto 0);

	-- for debugging
        status       : out std_logic_vector(9  downto 0)
    );
end component; 

component ezusb_io 
    generic (
        OUTEP : INTEGER := 2;                                 -- EP for FPGA -> EZ-USB transfers
        INEP  : INTEGER := 6                                  -- EP for EZ-USB -> FPGA transfers 
    );                                                         
    port (                                                     
        ifclk     : out std_logic;                            
        reset     : in std_logic;                             -- asynchronous reset input
        reset_out : out std_logic;                            -- synchronous reset output
        -- pins                                               
        ifclk_in   : in std_logic;                             
        fd         : inout std_logic_vector(15  downto 0);      
        SLWR       : out std_logic;                           
        PKTEND     : out std_logic;                                 
        SLRD       : out std_logic;                               
        SLOE       : out std_logic;                                 
        FIFOADDR   : out std_logic_vector(1  downto 0);             
        EMPTY_FLAG : in std_logic;                             
        FULL_FLAG  : in std_logic;                             
	-- signals for FPGA -> EZ-USB transfer                 
        DI        : in std_logic_vector(15  downto 0);         -- data written to EZ-USB
        DI_valid  : in std_logic;                              -- 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
        DI_ready  : out std_logic;                             -- 1 if new data are accepted
        DI_enable : in std_logic;                              -- setting to 0 disables FPGA -> EZ-USB transfers
        pktend_timeout : in std_logic_vector(15  downto 0);    -- timeout in multiples of 65536 clocks before a short packet committed
                                                               -- setting to 0 disables this feature
	-- signals for EZ-USB -> FPGA transfer                                                                                                                          		
        DO       : out std_logic_vector(15  downto 0);         -- data read from EZ-USB
        DO_valid : out std_logic;                              -- 1 indicated valid data
        DO_ready : in std_logic;                               -- setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0  
                                                               -- set to 0 to disable data reads    									
        -- debug output
        status : out std_logic_vector(3  downto 0)
    );
end component; 


signal reset2      : std_logic;
signal reset_mem   : std_logic;
signal reset_usb   : std_logic;
signal ifclk       : std_logic;
signal reset_ifclk : std_logic;
signal mem_free    : std_logic_vector(24 downto 0);
signal status      : std_logic_vector(9 downto 0);
signal if_status   : std_logic_vector(3 downto 0);
signal mode_buf    : std_logic_vector(1 downto 0);
    
-- input fifo
signal DI           : std_logic_vector(127 downto 0);
signal FULL         : std_logic;
signal WRERR        : std_logic;
signal USB_DO_valid : std_logic;
signal DO_ready     : std_logic;
signal WREN         : std_logic;
signal wrerr_buf    : std_logic;
signal USB_DO       : std_logic_vector(15 downto 0);
signal in_data      : std_logic_vector(127 downto 0);
signal wr_cnt       : std_logic_vector(3 downto 0);
signal test_cnt     : std_logic_vector(6 downto 0);
signal test_cs      : std_logic_vector(13 downto 0);
signal in_valid     : std_logic;
signal test_sync    : std_logic;
signal clk_div      : std_logic_vector(1 downto 0);

-- output fifo
signal DO           : std_logic_vector(127 downto 0);
signal EMPTY        : std_logic;
signal RDERR        : std_logic;
signal USB_DI_ready : std_logic;
signal RDEN         : std_logic;
signal rderr_buf    : std_logic;
signal USB_DI_valid : std_logic;
signal rd_buf       : std_logic_vector(127 downto 0);
signal rd_cnt       : std_logic_vector(2 downto 0);


begin
    dram_fifo_inst : dram_fifo 
    generic map (
        FIRST_WORD_FALL_THROUGH => "TRUE",  			-- Sets the FIFO FWFT to FALSE, TRUE
	ALMOST_EMPTY_OFFSET2    => 8
    ) 
    port map (
	fxclk_in  => fxclk_in,					-- 48 MHz input clock pin
        reset     => reset2,
        reset_out => reset_mem,					-- reset output
      	clkout2   => open,	 				-- PLL clock outputs not used for memory interface
      	clkout3   => open,	
      	clkout4   => open,
      	clkout5   => open,
	-- Memory interface ports
	ddr3_dq      => ddr3_dq,
        ddr3_dqs_n   => ddr3_dqs_n,
        ddr3_dqs_p   => ddr3_dqs_p,
        ddr3_addr    => ddr3_addr,
        ddr3_ba      => ddr3_ba,
        ddr3_ras_n   => ddr3_ras_n,
        ddr3_cas_n   => ddr3_cas_n,
        ddr3_we_n    => ddr3_we_n,
        ddr3_reset_n => ddr3_reset_n,
        ddr3_ck_p    => ddr3_ck_p,
        ddr3_ck_n    => ddr3_ck_n,
        ddr3_cke     => ddr3_cke,
	ddr3_dm      => ddr3_dm,
        ddr3_odt     => ddr3_odt,
	-- input fifo interface, see "7 Series Memory Resources" user guide (ug743)
	DI          => DI,
        FULL        => FULL,           -- 1-bit output: Full flag
        ALMOSTFULL1 => open,  	       -- 1-bit output: Almost full flag
        ALMOSTFULL2 => open,  	       -- 1-bit output: Almost full flag
        WRERR       => WRERR,          -- 1-bit output: Write error
        WREN        => WREN,           -- 1-bit input: Write enable
        WRCLK       => ifclk,          -- 1-bit input: Rising edge write clock.
	-- output fifo interface, see "7 Series Memory Resources" user guide (ug743)
	DO           => DO,
	EMPTY        => EMPTY,         -- 1-bit output: Empty flag
        ALMOSTEMPTY1 => open,          -- 1-bit output: Almost empty flag
        ALMOSTEMPTY2 => open,          -- 1-bit output: Almost empty flag
        RDERR        => RDERR,         -- 1-bit output: Read error
        RDCLK        => ifclk,         -- 1-bit input: Read clock
        RDEN         => RDEN,          -- 1-bit input: Read enable
	-- free memory
	mem_free_out => mem_free,
	-- for debugging
	status       => status
    );

    ezusb_io_inst : ezusb_io 
    generic map (
	OUTEP => 2,		        -- EP for FPGA -> EZ-USB transfers
	INEP  => 6 		        -- EP for EZ-USB -> FPGA transfers 
    ) 
    port map (
	ifclk     => ifclk,
        reset     => reset,   		-- asynchronous reset input
        reset_out => reset_usb,		-- synchronous reset output
        -- pins
        ifclk_in   => ifclk_in,
        fd	   => fd,
	SLWR	   => SLWR,
	SLRD       => SLRD,
	SLOE       => SLOE, 
	PKTEND     => PKTEND,
	FIFOADDR(0)=> FIFOADDR0, 
	FIFOADDR(1)=> FIFOADDR1, 
	EMPTY_FLAG => FLAGA,
	FULL_FLAG  => FLAGB,
	-- signals for FPGA -> EZ-USB transfer
	DI	       => rd_buf(15 downto 0),	-- data written to EZ-USB
	DI_valid       => USB_DI_valid,		-- 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
	DI_ready       => USB_DI_ready,		-- 1 if new data are accepted
	DI_enable      => '1',			-- setting to 0 disables FPGA -> EZ-USB transfers
        pktend_timeout => conv_std_logic_vector(90,16),		-- timeout in multiples of 65536 clocks (approx. 0.1s @ 48 MHz) before a short packet committed
    						-- setting to 0 disables this feature
	-- signals for EZ-USB -> FPGA transfer
	DO       => USB_DO,			-- data read from EZ-USB
	DO_valid => USB_DO_valid,		-- 1 indicated valid data
	DO_ready => DO_ready,			-- setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
        -- debug output
	status	 => if_status
    );

    reset2 <= reset or reset_usb;
    DO_ready <= '1' when ( (mode_buf="00") and (reset_ifclk='0') and (FULL='0') ) else '0';
    
    -- debug board LEDs    
    led1 <= status when (SW10='1') else (EMPTY & FULL & wrerr_buf & rderr_buf & if_status & FLAGB & FLAGA);

    led2(0) <= '1' when mem_free /= ( '1' & conv_std_logic_vector(0,24) ) else '0';
    led2(1) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(30,5) else '0';
    led2(2) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(29,5) else '0';
    led2(3) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(27,5) else '0';
    led2(4) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(25,5) else '0';
    led2(5) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(24,5) else '0';
    led2(6) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(22,5) else '0';
    led2(7) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(20,5) else '0';
    led2(8) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(19,5) else '0';
    led2(9) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(17,5) else '0';
    led2(10) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(15,5) else '0';
    led2(11) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(13,5) else '0';
    led2(12) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(12,5) else '0';
    led2(13) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(10,5) else '0';
    led2(14) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(8,5) else '0';
    led2(15) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(7,5) else '0';
    led2(16) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(5,5) else '0';
    led2(17) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(3,5) else '0';
    led2(18) <= '1' when mem_free(23 downto 19) < conv_std_logic_vector(2,5) else '0';
    led2(19) <= '1' when mem_free = conv_std_logic_vector(0,25) else '0';
    
    test_sync <= '1' when ( (wr_cnt="1110") or (wr_cnt(0)='1') ) else '0';

    dpifclk: process
    begin
        wait until ( ifclk'EVENT and (ifclk = '1') );

	-- reset
        reset_ifclk <= (reset or reset_usb) or reset_mem;
        if ( reset_ifclk = '1' ) then 
            rderr_buf <= '0';
            wrerr_buf <= '0';
        else 
            rderr_buf <= rderr_buf or RDERR;
            wrerr_buf <= wrerr_buf or WRERR;
        end if;

	-- FPGA -> EZ-USB FIFO
        if ( reset_ifclk = '1' ) then 
            rd_cnt <= (others => '0');
            USB_DI_valid <= '0';
        else 
            if ( USB_DI_ready = '1' ) then 
                USB_DI_valid <= not EMPTY;
                if ( EMPTY = '0' ) then 
                    if ( rd_cnt = "000" ) then 
                        rd_buf <= DO;
                    else 
                        rd_buf(111 downto 0) <= rd_buf(127 downto 16);
                    end if;
                    rd_cnt <= rd_cnt + 1;
                end if;
            end if;
        end if;

	if ( (reset_ifclk = '0') and (USB_DI_ready = '1') and (EMPTY = '0') and (rd_cnt = "000")) then
	    RDEN <= '1';
	else
	    RDEN <= '0';
	end if;
	
	-- data source
        if ( reset_ifclk = '1' ) then 
            in_data <= (others => '0');
            in_valid <= '0';
            wr_cnt <= (others => '0');
            test_cnt <=(others => '0');
            test_cs <= conv_std_logic_vector(47,14);
            WREN <= '0';
            clk_div <= "11";
        else 
            if ( FULL = '0' ) then 
                if ( in_valid = '1' ) then 
                    DI <= in_data;
                end if;
                if ( mode_buf = "00" ) then 
                    if ( USB_DO_valid = '1' ) then 
                        in_data <= USB_DO & in_data(127  downto 16);
                        if ( wr_cnt(2 downto 0) = "111") then 
                    	    in_valid <= '1';
                        else 
                    	    in_valid <= '0';
                    	end if;
                        wr_cnt <= wr_cnt + 1;
                    else 
                        in_valid <= '0';
                    end if;
                else 
                    if ( clk_div = "00" ) then 
                        if ( ( wr_cnt = "1111"  )  ) then 
                            test_cs <= conv_std_logic_vector(47,14);
                            in_data(126 downto 120) <= test_cs(6 downto 0) xor test_cs(13 downto 7);
                            in_valid <= '1';
                        else 
                            test_cnt <= test_cnt + conv_std_logic_vector(111,7);
                            test_cs <= test_cs + ( test_sync & test_cnt );
                            in_data(126  downto 120 ) <= test_cnt;
                            in_valid <= '0';
                        end if;
                        in_data(127 ) <= test_sync;
                        in_data(119  downto 0 ) <= in_data(127 downto 8 );
                        wr_cnt <= wr_cnt + 1;
                    else 
                        in_valid <= '0';
                    end if;
                end if;
                if ( (mode_buf = "01") or ( (mode_buf = "11") and (SW8='1') ) ) then 
                    clk_div <= "00";
                else 
                    clk_div <= clk_div + 1;
                end if;
            end if;
        end if;
        if ( (reset_ifclk ='0') and (in_valid = '1') and (FULL='0') ) then
    	    WREN <='1';
    	else
    	    WREN <='0';
    	end if;
        mode_buf <= mode;
    end process dpifclk;

end RTL;

