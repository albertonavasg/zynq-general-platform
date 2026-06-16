library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_bridge is
	generic (
		AXI_DATA_WIDTH : integer := 32;
		AXI_ADDR_WIDTH : integer := 8
	);
	port (
		clk    : in std_logic;
		resetn : in std_logic;

		s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot  : in  std_logic_vector(2 downto 0);
		s_axi_awvalid : in  std_logic;
		s_axi_awready : out std_logic;

		s_axi_wdata	 : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	 : in  std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid : in  std_logic;
		s_axi_wready : out std_logic;

		s_axi_bresp	 : out std_logic_vector(1 downto 0);
		s_axi_bvalid : out std_logic;
		s_axi_bready : in  std_logic;

		s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot  : in  std_logic_vector(2 downto 0);
		s_axi_arvalid : in  std_logic;
		s_axi_arready : out std_logic;

		s_axi_rdata	 : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	 : out std_logic_vector(1 downto 0);
		s_axi_rvalid : out std_logic;
		s_axi_rready : in  std_logic;

        version : in std_logic_vector(31 downto 0);

        sw      : in  std_logic_vector(1 downto 0);
        btn     : in  std_logic_vector(3 downto 0);
        led     : out std_logic_vector(3 downto 0);
        led_bgr : out std_logic_vector(5 downto 0)
	);
end axi_bridge;

architecture rtl of axi_bridge is

    signal axi_awaddr_latched  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    signal axi_awvalid_latched : std_logic;

    signal axi_wdata_latched   : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_wstrb_latched   : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
    signal axi_wvalid_latched  : std_logic;

    signal axi_araddr_latched : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);

    -- 64 registers
    -- 32bit // 4byte
	constant ADDR_MSB  : integer := 7;
	constant ADDR_LSB  : integer := 2;
    constant ADDR_BITS : integer := ADDR_MSB - ADDR_LSB + 1;

	-- Internal registers
    signal slv_reg0  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg1  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg2  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg3  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg4  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg5  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg6  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg7  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg8  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg9  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg10 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg11 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg12 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg13 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg14 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg15 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg16 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg17 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg18 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg19 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg20 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg21 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg22 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg23 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg24 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg25 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg26 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg27 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg28 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg29 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg30 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg31 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg32 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg33 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg34 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg35 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg36 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg37 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg38 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg39 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg40 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg41 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg42 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg43 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg44 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg45 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg46 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg47 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg48 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg49 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg50 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg51 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg52 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg53 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg54 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg55 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg56 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg57 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg58 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg59 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg60 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg61 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg62 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal slv_reg63 : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');

    -- Write Address index
    signal w_addr_index : unsigned(ADDR_BITS-1 downto 0);
    -- Read Address index
    signal r_addr_index : unsigned(ADDR_BITS-1 downto 0);

    -- State machine states
    type waddr_state_t is (waddr_idle, waddr_ack);
    type wdata_state_t is (wdata_idle, wdata_ack);
    type wtrig_state_t is (wtrig_idle, wtrig_ack);
    type read_state_t  is (r_idle, r_ack);

	-- State machine variables
    signal state_waddr : waddr_state_t;
    signal state_wdata : wdata_state_t;
    signal state_wtrig : wtrig_state_t;
    signal state_read  : read_state_t;

    -- Flags
    signal write_enable : std_logic;
    signal write_done   : std_logic;

    function apply_wstrb(
        reg  : std_logic_vector(31 downto 0);
        data : std_logic_vector(31 downto 0);
        strb : std_logic_vector(3 downto 0)
    ) return std_logic_vector is
        variable result : std_logic_vector(31 downto 0) := reg;
    begin
        for i in 0 to 3 loop
            if strb(i) = '1' then
                result(i*8+7 downto i*8) := data(i*8+7 downto i*8);
            end if;
        end loop;
        return result;
    end function;

begin

	-- I/O Connections assignments

	s_axi_bresp <= (others => '0'); -- Ignored
	s_axi_rresp <= (others => '0'); -- Ignored

    -- Write address state machine
    w_addr_fsm: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                s_axi_awready <= '0';
                axi_awaddr_latched <= (others => '0');
                axi_awvalid_latched <= '0';
                state_waddr <= waddr_idle;
            else
                case (state_waddr) is
                    when waddr_idle =>
                        s_axi_awready       <= '1';
                        axi_awaddr_latched  <= (others => '0');
                        axi_awvalid_latched <= '0';
                        if (s_axi_awvalid = '1') then
                            s_axi_awready <= '0';
                            axi_awaddr_latched <= s_axi_awaddr;
                            axi_awvalid_latched <= '1';
                            state_waddr <= waddr_ack;
                        end if;
                    when waddr_ack =>
                        s_axi_awready <= '0';
                        if (write_done = '1') then
                            s_axi_awready <= '1';
                            axi_awaddr_latched <= (others => '0');
                            axi_awvalid_latched <= '0';
                            state_waddr <= waddr_idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Write data state machine
    w_data_fsm: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                s_axi_wready       <= '0';
                axi_wdata_latched  <= (others => '0');
                axi_wstrb_latched  <= (others => '0');
                axi_wvalid_latched <= '0';
                state_wdata <= wdata_idle;
            else
                case (state_wdata) is
                    when wdata_idle =>
                        s_axi_wready       <= '1';
                        axi_wdata_latched  <= (others => '0');
                        axi_wstrb_latched  <= (others => '0');
                        axi_wvalid_latched <= '0';
                        if (s_axi_wvalid = '1') then
                            s_axi_wready       <= '0';
                            axi_wdata_latched  <= s_axi_wdata;
                            axi_wstrb_latched  <= s_axi_wstrb;
                            axi_wvalid_latched <= '1';
                            state_wdata            <= wdata_ack;
                        end if;
                    when wdata_ack =>
                        s_axi_wready <= '0';
                        if (write_done = '1') then
                            s_axi_wready <= '1';
                            axi_wdata_latched  <= (others => '0');
                            axi_wstrb_latched  <= (others => '0');
                            axi_wvalid_latched <= '0';
                            state_wdata <= wdata_idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Write trigger (and response) state machine
    w_trig_fsm: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                s_axi_bvalid <= '0';
                write_enable <= '0';
                write_done   <= '0';
                state_wtrig  <= wtrig_idle;
            else
                case (state_wtrig) is
                    when wtrig_idle =>
                            s_axi_bvalid <= '0';
                            write_enable <= '0';
                            write_done   <= '0';
                        if (axi_awvalid_latched = '1' and axi_wvalid_latched = '1') then
                            s_axi_bvalid <= '1';
                            write_enable <= '1';
                            write_done   <= '1';
                            state_wtrig  <= wtrig_ack;
                        end if;
                    when wtrig_ack =>
                            s_axi_bvalid <= '1';
                            write_enable <= '0';
                            write_done   <= '0';
                        if (s_axi_bready = '1') then
                            s_axi_bvalid <= '0';
                            write_enable <= '0';
                            write_done   <= '0';
                            state_wtrig <= wtrig_idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    w_addr_index <= unsigned(axi_awaddr_latched(ADDR_MSB downto ADDR_LSB));

    -- Memory mapped write
    write_proc: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                slv_reg0  <= (others => '0');
                slv_reg1  <= (others => '0');
                slv_reg2  <= (others => '0');
                slv_reg3  <= (others => '0');
                slv_reg4  <= (others => '0');
                slv_reg5  <= (others => '0');
                slv_reg6  <= (others => '0');
                slv_reg7  <= (others => '0');
                slv_reg8  <= (others => '0');
                slv_reg9  <= (others => '0');
                slv_reg10 <= (others => '0');
                slv_reg11 <= (others => '0');
                slv_reg12 <= (others => '0');
                slv_reg13 <= (others => '0');
                slv_reg14 <= (others => '0');
                slv_reg15 <= (others => '0');
                slv_reg16 <= (others => '0');
                slv_reg17 <= (others => '0');
                slv_reg18 <= (others => '0');
                slv_reg19 <= (others => '0');
                slv_reg20 <= (others => '0');
                slv_reg21 <= (others => '0');
                slv_reg22 <= (others => '0');
                slv_reg23 <= (others => '0');
                slv_reg24 <= (others => '0');
                slv_reg25 <= (others => '0');
                slv_reg26 <= (others => '0');
                slv_reg27 <= (others => '0');
                slv_reg28 <= (others => '0');
                slv_reg29 <= (others => '0');
                slv_reg30 <= (others => '0');
                slv_reg31 <= (others => '0');
            else
                if (write_enable = '1') then
                    case (to_integer(w_addr_index)) is
                        when 0  => slv_reg0  <= apply_wstrb(slv_reg0,  axi_wdata_latched, axi_wstrb_latched);
                        when 1  => slv_reg1  <= apply_wstrb(slv_reg1,  axi_wdata_latched, axi_wstrb_latched);
                        when 2  => slv_reg2  <= apply_wstrb(slv_reg2,  axi_wdata_latched, axi_wstrb_latched);
                        when 3  => slv_reg3  <= apply_wstrb(slv_reg3,  axi_wdata_latched, axi_wstrb_latched);
                        when 4  => slv_reg4  <= apply_wstrb(slv_reg4,  axi_wdata_latched, axi_wstrb_latched);
                        when 5  => slv_reg5  <= apply_wstrb(slv_reg5,  axi_wdata_latched, axi_wstrb_latched);
                        when 6  => slv_reg6  <= apply_wstrb(slv_reg6,  axi_wdata_latched, axi_wstrb_latched);
                        when 7  => slv_reg7  <= apply_wstrb(slv_reg7,  axi_wdata_latched, axi_wstrb_latched);
                        when 8  => slv_reg8  <= apply_wstrb(slv_reg8,  axi_wdata_latched, axi_wstrb_latched);
                        when 9  => slv_reg9  <= apply_wstrb(slv_reg9,  axi_wdata_latched, axi_wstrb_latched);
                        when 10 => slv_reg10 <= apply_wstrb(slv_reg10, axi_wdata_latched, axi_wstrb_latched);
                        when 11 => slv_reg11 <= apply_wstrb(slv_reg11, axi_wdata_latched, axi_wstrb_latched);
                        when 12 => slv_reg12 <= apply_wstrb(slv_reg12, axi_wdata_latched, axi_wstrb_latched);
                        when 13 => slv_reg13 <= apply_wstrb(slv_reg13, axi_wdata_latched, axi_wstrb_latched);
                        when 14 => slv_reg14 <= apply_wstrb(slv_reg14, axi_wdata_latched, axi_wstrb_latched);
                        when 15 => slv_reg15 <= apply_wstrb(slv_reg15, axi_wdata_latched, axi_wstrb_latched);
                        when 16 => slv_reg16 <= apply_wstrb(slv_reg16, axi_wdata_latched, axi_wstrb_latched);
                        when 17 => slv_reg17 <= apply_wstrb(slv_reg17, axi_wdata_latched, axi_wstrb_latched);
                        when 18 => slv_reg18 <= apply_wstrb(slv_reg18, axi_wdata_latched, axi_wstrb_latched);
                        when 19 => slv_reg19 <= apply_wstrb(slv_reg19, axi_wdata_latched, axi_wstrb_latched);
                        when 20 => slv_reg20 <= apply_wstrb(slv_reg20, axi_wdata_latched, axi_wstrb_latched);
                        when 21 => slv_reg21 <= apply_wstrb(slv_reg21, axi_wdata_latched, axi_wstrb_latched);
                        when 22 => slv_reg22 <= apply_wstrb(slv_reg22, axi_wdata_latched, axi_wstrb_latched);
                        when 23 => slv_reg23 <= apply_wstrb(slv_reg23, axi_wdata_latched, axi_wstrb_latched);
                        when 24 => slv_reg24 <= apply_wstrb(slv_reg24, axi_wdata_latched, axi_wstrb_latched);
                        when 25 => slv_reg25 <= apply_wstrb(slv_reg25, axi_wdata_latched, axi_wstrb_latched);
                        when 26 => slv_reg26 <= apply_wstrb(slv_reg26, axi_wdata_latched, axi_wstrb_latched);
                        when 27 => slv_reg27 <= apply_wstrb(slv_reg27, axi_wdata_latched, axi_wstrb_latched);
                        when 28 => slv_reg28 <= apply_wstrb(slv_reg28, axi_wdata_latched, axi_wstrb_latched);
                        when 29 => slv_reg29 <= apply_wstrb(slv_reg29, axi_wdata_latched, axi_wstrb_latched);
                        when 30 => slv_reg30 <= apply_wstrb(slv_reg30, axi_wdata_latched, axi_wstrb_latched);
                        when 31 => slv_reg31 <= apply_wstrb(slv_reg31, axi_wdata_latched, axi_wstrb_latched);
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;

	-- Read state machine
	read_fsm: process (clk)
    begin
	    if rising_edge(clk) then
	        if (resetn = '0') then
                s_axi_arready      <= '0';
                s_axi_rvalid       <= '0';
                axi_araddr_latched <= (others => '0');
                state_read         <= r_idle;
	        else
                case (state_read) is
                    when r_idle =>
                        s_axi_arready <= '1';
                        s_axi_rvalid  <= '0';
                        if (s_axi_arvalid = '1') then
                            axi_araddr_latched <= s_axi_araddr;
                            s_axi_arready      <= '0';
                            s_axi_rvalid       <= '1';
                            state_read         <= r_ack;
                        end if;
                    when r_ack =>
                        s_axi_arready <= '0';
                        s_axi_rvalid  <= '1';
                        if (s_axi_rready = '1') then
                            s_axi_arready <= '1';
                            s_axi_rvalid  <= '0';
                            state_read    <= r_idle;
                        end if;
                end case;
	        end if;
        end if;
    end process;

    r_addr_index <= unsigned(axi_araddr_latched(ADDR_MSB downto ADDR_LSB));

    -- Memory mapped read
    with r_addr_index select
        s_axi_rdata <= slv_reg0  when "000000",
                       slv_reg1  when "000001",
                       slv_reg2  when "000010",
                       slv_reg3  when "000011",
                       slv_reg4  when "000100",
                       slv_reg5  when "000101",
                       slv_reg6  when "000110",
                       slv_reg7  when "000111",
                       slv_reg8  when "001000",
                       slv_reg9  when "001001",
                       slv_reg10 when "001010",
                       slv_reg11 when "001011",
                       slv_reg12 when "001100",
                       slv_reg13 when "001101",
                       slv_reg14 when "001110",
                       slv_reg15 when "001111",
                       slv_reg16 when "010000",
                       slv_reg17 when "010001",
                       slv_reg18 when "010010",
                       slv_reg19 when "010011",
                       slv_reg20 when "010100",
                       slv_reg21 when "010101",
                       slv_reg22 when "010110",
                       slv_reg23 when "010111",
                       slv_reg24 when "011000",
                       slv_reg25 when "011001",
                       slv_reg26 when "011010",
                       slv_reg27 when "011011",
                       slv_reg28 when "011100",
                       slv_reg29 when "011101",
                       slv_reg30 when "011110",
                       slv_reg31 when "011111",
                       slv_reg32 when "100000",
                       slv_reg33 when "100001",
                       slv_reg34 when "100010",
                       slv_reg35 when "100011",
                       slv_reg36 when "100100",
                       slv_reg37 when "100101",
                       slv_reg38 when "100110",
                       slv_reg39 when "100111",
                       slv_reg40 when "101000",
                       slv_reg41 when "101001",
                       slv_reg42 when "101010",
                       slv_reg43 when "101011",
                       slv_reg44 when "101100",
                       slv_reg45 when "101101",
                       slv_reg46 when "101110",
                       slv_reg47 when "101111",
                       slv_reg48 when "110000",
                       slv_reg49 when "110001",
                       slv_reg50 when "110010",
                       slv_reg51 when "110011",
                       slv_reg52 when "110100",
                       slv_reg53 when "110101",
                       slv_reg54 when "110110",
                       slv_reg55 when "110111",
                       slv_reg56 when "111000",
                       slv_reg57 when "111001",
                       slv_reg58 when "111010",
                       slv_reg59 when "111011",
                       slv_reg60 when "111100",
                       slv_reg61 when "111101",
                       slv_reg62 when "111110",
                       slv_reg63 when "111111",
                       (others => '0') when others;

    -- Update outputs from write registers(0-31) (PS -> PL)
    write_out_proc: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                led     <= (others => '0');
                led_bgr <= (others => '0');
            else
                led     <= slv_reg0(3 downto 0);
                led_bgr <= slv_reg0(9 downto 4);
            end if;
        end if;
    end process;

    -- Update read registers (32-63) from inputs (PL -> PS)
    read_in_proc: process(clk)
    begin
        if (rising_edge(clk)) then
            if (resetn = '0') then
                slv_reg32 <= (others => '0');
                slv_reg33 <= (others => '0');
            else
                slv_reg32             <= version;
                slv_reg33(3 downto 0) <= btn;
                slv_reg33(5 downto 4) <= sw;
            end if;
        end if;
    end process;

end architecture;