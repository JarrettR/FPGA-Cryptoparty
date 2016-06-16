library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha1_test is
	port(
        clk                             : in    std_ulogic;
        avalon_st_sink_data             : in    std_ulogic_vector(31 downto 0);
        avalon_st_sink_empty             : in    std_ulogic_vector(2 downto 0);
        avalon_st_sink_valid            : in    std_ulogic;
        avalon_st_sink_startofpacket    : in    std_ulogic;
        avalon_st_sink_endofpacket      : in    std_ulogic;
        avalon_st_source_startofpacket    : out    std_ulogic;
        avalon_st_source_endofpacket      : out    std_ulogic;
        avalon_st_source_empty        : out    std_ulogic;
        avalon_st_source_data           : out    std_ulogic_vector(31 downto 0);
        avalon_st_source_valid          : out    std_ulogic;

        csr_address             : in    std_ulogic_vector(1 downto 0);
        csr_readdata            : out   std_ulogic_vector(31 downto 0);
        csr_readdatavalid       : out   std_ulogic;
        csr_read                : in    std_ulogic;
        csr_write               : in    std_ulogic;
        csr_waitrequest         : out   std_ulogic;
        csr_writedata           : in    std_ulogic_vector(31 downto 0)
	);
end entity sha1_test;

-- iterative
architecture sha1_chunk_arch of sha1_test is
	-- components
	
	-- constants
	constant h0i : std_logic_vector(31 downto 0) := X"67452301";  -- H0 (a)
	constant h1i : std_logic_vector(31 downto 0) := X"EFCDAB89";  -- H1 (b)
	constant h2i : std_logic_vector(31 downto 0) := X"98BADCFE";  -- H2 (c)
	constant h3i : std_logic_vector(31 downto 0) := X"10325476";  -- H3 (d)
	constant h4i : std_logic_vector(31 downto 0) := X"C3D2E1F0";  -- H4 (e)
	
	constant k0 : std_logic_vector(31 downto 0) := X"5A827999";  -- round  0 .. 19
	constant k1 : std_logic_vector(31 downto 0) := X"6ED9EBA1";  -- round 20 .. 39
	constant k2 : std_logic_vector(31 downto 0) := X"8F1BBCDC";  -- round 40 .. 59
	constant k3 : std_logic_vector(31 downto 0) := X"CA62C1D6";  -- round 60 .. 79
	
	-- types
	type state_type is (C_IDLE, C_EXTEND_CHUNK, C_PROCESS_WORD, C_NEXT_ROUND);
	
	-- signals
	
	signal h0         : std_logic_vector(31 downto 0) := h0i;
	signal h1         : std_logic_vector(31 downto 0) := h1i;
	signal h2         : std_logic_vector(31 downto 0) := h2i;
	signal h3         : std_logic_vector(31 downto 0) := h3i;
	signal h4         : std_logic_vector(31 downto 0) := h4i;
    
    
	signal h     : std_logic_vector(159 downto 0) := (others => '0');
	
	signal round        : natural := 0;
	signal w_round      : std_logic_vector( 31 downto 0) := (others => '0');
	signal w_round_temp : std_logic_vector( 31 downto 0) := (others => '0');
	signal w            : std_logic_vector(511 downto 0) := (others => '0');
	signal hash_round   : std_logic_vector(159 downto 0) := h0 & h1 & h2 & h3 & h4;
	
	signal a         : std_logic_vector(31 downto 0) := (others => '0');
	signal b         : std_logic_vector(31 downto 0) := (others => '0');
	signal c         : std_logic_vector(31 downto 0) := (others => '0');
	signal d         : std_logic_vector(31 downto 0) := (others => '0');
	signal e         : std_logic_vector(31 downto 0) := (others => '0');
	signal a_rol     : std_logic_vector(31 downto 0) := (others => '0');
	signal f         : std_logic_vector(31 downto 0) := (others => '0');
	signal k         : std_logic_vector(31 downto 0) := (others => '0');
	signal t         : std_logic_vector(31 downto 0) := (others => '0');
	
	signal ready_extend   : std_logic := '0';
	signal ready_round    : std_logic := '0';
	signal ready_round_q1 : std_logic := '0';
	signal load_pulse     : std_logic := '0';
	signal load_q         : std_logic := '0';
	
	signal state : state_type := C_IDLE;
begin
	-- combinatorial
	-- w[i]  = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1
	w_round_temp <= w( 95 downto  64) xor w(255 downto 224) xor w(447 downto 416) xor w(511 downto 480);
	--load_pulse   <= load and (not load_q);
	-- control process
	sha1_chunk_process : process(clk)
	begin
		if Avalon_ST_Sink_valid = '1' then
            Avalon_ST_Source_valid <= '1';
        end if;
		if Avalon_ST_Sink_startofpacket = '0' then
			h0 <= h(159 downto 128);
			h1 <= h(127 downto 96);
			h2 <= h(95 downto 64);
			h3 <= h(63 downto 32);
			h4 <= h(31 downto 0);
		else
			h0 <= h0i;
			h1 <= h1i;
			h2 <= h2i;
			h3 <= h3i;
			h4 <= h4i;
		end if;
		
		if rising_edge(clk) then
        
			-- state machine
			case state is
			when C_IDLE =>
				a <= h0; 
				b <= h1;
				c <= h2;
				d <= h3;
				e <= h4;
				if load_pulse = '1' then
					state <= C_PROCESS_WORD;
					round <= 0;
				end if;
			when others =>  
				round <= 0;
			end case;
		end if;
	end process sha1_chunk_process;
end sha1_chunk_arch;