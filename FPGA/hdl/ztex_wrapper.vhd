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
    signal pb_buf : std_logic_vector(7 downto 0);
    signal out_buf : std_logic_vector(7 downto 0);
    signal in_buf : std_logic_vector(7 downto 0);
    signal load: std_ulogic := '0';
    signal sloe_buf: std_ulogic := '0';
    signal slrd_buf: std_ulogic := '0';
    signal slwr_buf: std_ulogic := '0';
    signal fifoadr_buf: std_logic_vector(1 downto 0) := "ZZ";
    signal count: integer range 0 to (MK_SIZE * 2) + 1;
    --constant rst : unsigned(7 downto 0) := X"30";  -- Reset

    
    --fifo signals
    signal start: std_ulogic := '0';
    signal wr_en: std_ulogic := '0';
    signal out_wr: std_ulogic := '0';
    --signal rd_en: std_ulogic := '0';
    signal full_i: std_ulogic := '0';
    signal full_o: std_ulogic := '0';
    signal empty_i: std_ulogic := '0';
    --signal empty_o: std_ulogic := '0';
    signal in_full: std_ulogic := '0';
    signal in_empty: std_ulogic := '0';
    signal in_rd: std_ulogic := '0';
    signal out_rd: std_ulogic := '0';
	
begin
    pb_o <= pb_buf when CS = '1' else (others => 'Z');
    SLOE <= sloe_buf when CS = '1' else 'Z';
    SLRD <= slrd_buf when CS = '1' else 'Z';
    SLWR <= slwr_buf when CS = '1' else 'Z';
    FIFOADR <= fifoadr_buf when CS = '1' else "ZZ";
    empty_i <= FLAGC when CS = '1' else '0';
    full_i <= FLAGB when CS = '1' else '0'; --Todo reverse polarity
    --out_rd <= std_logic_vector( sck_i ) when CS = '1' else (others => 'Z');
    
    in_fifo : fx2_fifo
	  port map (
		 rst => rst_i,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din => pc_i,
		 wr_en => empty_i,
		 rd_en => in_rd,
		 dout => in_buf,
		 full => in_full,
		 empty => in_empty
	  );
    out_fifo : fx2_fifo
	  port map (
		 rst => rst_i,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din => out_buf,
		 wr_en => out_wr,
		 rd_en => full_i,
		 dout => pb_buf,
		 full => full_o,
		 empty => slrd_buf
	  );
      
      
    ztex_comm: process(IFCLK)
    begin
        if IFCLK'event and IFCLK = '1' then
            if rst_i = '1' then
                start <= '1';
                load <= '0';
                in_rd <= '0';
                fifoadr_buf <= "01";
                out_buf <= x"35";
                slwr_buf <= '0';
            else
                if ( empty_i = '0' ) then
                    slwr_buf <= not slwr_buf;
                else
                    slwr_buf <= '0';
                end if;
            end if;
        end if;
    end process ztex_comm;
    
end RTL;
