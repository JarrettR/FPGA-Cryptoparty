library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.sha1_pkg.all;

entity ztex_wrapper is
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
        PKTEND    : out std_logic;
        rst_i     : in std_logic

--      SCL     : in std_logic;
--      SDA     : in std_logic
   );
end ztex_wrapper;


architecture RTL of ztex_wrapper is
    
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

	--signal declaration
    --signal pb_buf : std_logic_vector(7 downto 0);
    --signal out_buf : std_logic_vector(7 downto 0);
    signal in_buf : std_logic_vector(7 downto 0);
    signal load: std_ulogic;
    signal sloe_buf: std_ulogic;
    signal slrd_buf: std_ulogic;
    signal slwr_buf: std_ulogic;
    signal pktend_buf: std_ulogic;
    signal fifoadr_buf: std_logic_vector(1 downto 0);
    signal count: integer range 0 to (MK_SIZE * 2) + 1;
    --constant rst : unsigned(7 downto 0) := X"30";  -- Reset

    
    signal direction: std_ulogic;
    
    signal wr_en: std_ulogic;
    signal out_wr: std_ulogic;
    --signal rd_en: std_ulogic;
    signal full_i: std_ulogic;
    signal full_o: std_ulogic;
    signal empty_i: std_ulogic;
    
    --FPGA FIFOs
    signal write_fifo_rd_clk :  std_logic;
    signal write_fifo_din :  std_logic_vector(7 downto 0);
    signal write_fifo_wr_en :  std_logic;
    signal write_fifo_rd_en :  std_logic;
    signal write_fifo_dout :  std_logic_vector(7 downto 0);
    signal write_fifo_full :  std_logic;
    signal write_fifo_empty :  std_logic;
    signal read_fifo_din :  std_logic_vector(7 downto 0);
    signal read_fifo_wr_en :  std_logic;
    signal read_fifo_rd_en :  std_logic;
    signal read_fifo_dout :  std_logic_vector(7 downto 0);
    signal read_fifo_full :  std_logic;
    signal read_fifo_empty :  std_logic;
	
begin
    SLOE <= sloe_buf when CS = '1' else
            --'1' when CS = '1' and in_full = '0' else
            'Z';
    SLRD <= slrd_buf when CS = '1' else 'Z';
    SLWR <= slwr_buf when CS = '1' else 'Z';
    FIFOADR <= fifoadr_buf when CS = '1' else "ZZ";
    empty_i <= not FLAGC when CS = '1' else '1';
    full_i <= not FLAGB when CS = '1' else '0';
    full_o <= read_fifo_full when CS = '1' else '0';
    PKTEND <= pktend_buf when CS = '1' else '0';            --Unused
    pb_o <= write_fifo_dout when CS = '1' else (others => 'Z');
    fifoadr_buf <= "01" when direction = '1' else "00";
      
    sloe_buf <= not read_fifo_wr_en when direction = '1' else '1';
    slrd_buf <= IFCLK when direction = '1' and read_fifo_wr_en = '1' else '1';
    slwr_buf <= IFCLK when direction = '0' and write_fifo_rd_en = '1' else '1';
    
    --Read
    --Read is always enabled when direction is in and FX2LP is not empty
    read_fifo_wr_en <= '1' when direction = '1' and empty_i = '0' else '0';
    
    --Write
    --write_fifo_rd_en <= not write_fifo_empty when direction = '0' else '0';
    

    --Loopback
    --read_fifo_rd_en <= not read_fifo_empty;
    --write_fifo_wr_en <= not read_fifo_empty;
        
    read_fifo : fx2_fifo port map (
		 rst => rst_i,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din => pc_i,
		 wr_en => read_fifo_wr_en,
		 rd_en => read_fifo_rd_en,
		 dout => read_fifo_dout,
		 full => read_fifo_full,
		 empty => read_fifo_empty
	  );
    write_fifo : fx2_fifo port map (
		 rst => rst_i,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din => write_fifo_din,
		 wr_en => write_fifo_wr_en,
		 rd_en => write_fifo_rd_en,
		 dout => write_fifo_dout,
		 full => write_fifo_full,
		 empty => write_fifo_empty
	  );
      
    ztex_comm: process(IFCLK)
    begin
        if IFCLK'event and IFCLK = '1' then
            if rst_i = '1' then
                --slwr_buf <= '1';
                --slrd_buf <= '1';
                --sloe_buf <= '1';
                pktend_buf <= '1';
                direction <= '1';
                read_fifo_rd_en <= '0';
                write_fifo_wr_en <= '0';
                write_fifo_rd_en <= '0';
            else
                --Loopbackb
                if read_fifo_empty = '0' then
                    read_fifo_rd_en <= '1';
                end if;
                if read_fifo_rd_en = '1' then
                    write_fifo_wr_en <= '1';
                end if;
                --Output
                if write_fifo_empty = '0' and direction = '0' then
                    write_fifo_rd_en <= '1';
                else
                    write_fifo_rd_en <= '0';
                end if;

                if read_fifo_dout = X"08" then
                    write_fifo_din <= X"CE";
                elsif read_fifo_dout = X"18" then
                    write_fifo_din <= read_fifo_dout;
                    direction <= '0';
                else
                    write_fifo_din <= read_fifo_dout;
                end if;
            end if;
        end if;
    end process ztex_comm;
    
end RTL;
