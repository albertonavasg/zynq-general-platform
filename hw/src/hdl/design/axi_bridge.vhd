library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_bridge is
	generic (
		C_S_AXI_DATA_WIDTH : integer := 32;
		C_S_AXI_ADDR_WIDTH : integer := 8
	);
	port (
		S_AXI_ACLK    : in std_logic;
		S_AXI_ARESETN : in std_logic;

        -- Write Address
		S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
		S_AXI_AWVALID : in std_logic;
		S_AXI_AWREADY : out std_logic;

        -- Write Data
		S_AXI_WDATA	 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	 : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID : in std_logic;
		S_AXI_WREADY : out std_logic;

        -- Write Response
		S_AXI_BRESP	 : out std_logic_vector(1 downto 0);
		S_AXI_BVALID : out std_logic;
		S_AXI_BREADY : in std_logic;

		-- Read Address
		S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
		S_AXI_ARVALID : in std_logic;
		S_AXI_ARREADY : out std_logic;

		-- Read Data
		S_AXI_RDATA	 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	 : out std_logic_vector(1 downto 0);
		S_AXI_RVALID : out std_logic;
		S_AXI_RREADY : in std_logic;

        version : in  std_logic_vector(31 downto 0);

        sw      : in  std_logic_vector(1 downto 0);
        btn     : in  std_logic_vector(3 downto 0);
        led     : out std_logic_vector(3 downto 0);
        led_bgr : out std_logic_vector(5 downto 0)
	);
end axi_bridge;

architecture rtl of axi_bridge is

	-- AXI4LITE signals
	signal axi_arready : std_logic;
    signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp   : std_logic_vector(1 downto 0) := (others => '0'); -- Untouched
	signal axi_rvalid  : std_logic;

	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 5;

	-- Internal registers
    constant N_REG : integer := 64;
	type reg_array_t is array (0 to N_REG-1) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

    signal slv_reg : reg_array_t := (others => (others => '0'));

    -- Read Address index
    signal r_addr_index : unsigned(OPT_MEM_ADDR_BITS downto 0);

    -- State machine states
    type read_state_t  is (r_addr, r_data);

	-- State machine variables
    signal state_read  : read_state_t;

begin

	-- I/O Connections assignments
	S_AXI_ARREADY <= axi_arready;
    S_AXI_RDATA   <= axi_rdata;
	S_AXI_RRESP   <= axi_rresp;
	S_AXI_RVALID  <= axi_rvalid;

	-- Read transaction state machine
	read_state_machine: process (S_AXI_ACLK)
    begin
	    if rising_edge(S_AXI_ACLK) then
	        if (S_AXI_ARESETN = '0') then
                axi_arready  <= '1';
                axi_rvalid   <= '0';
                r_addr_index <= (others => '0');
                state_read   <= r_addr;
	        else
                case (state_read) is
                    when r_addr =>
                        axi_arready <= '1';
                        axi_rvalid  <= '0';
                        if (S_AXI_ARVALID = '1') then
                            r_addr_index <= unsigned(S_AXI_ARADDR(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB));
                            axi_arready  <= '0';
                            axi_rvalid   <= '1';
                            state_read   <= r_data;
                        end if;
                    when r_data =>
                        axi_arready <= '0';
                        axi_rvalid  <= '1';
                        if (S_AXI_RREADY = '1') then
                            axi_arready <= '1';
                            axi_rvalid  <= '0';
                            state_read  <= r_addr;
                        end if;
                end case;
	        end if;
        end if;
    end process;

    axi_rdata <= slv_reg(to_integer(r_addr_index));

    -- Update outputs from write registers(0-31) (PS -> PL)
    write_out_proc: process(S_AXI_ACLK)
    begin
        if (rising_edge(S_AXI_ACLK)) then
            if (S_AXI_ARESETN = '0') then
                led     <= (others => '0');
                led_bgr <= (others => '0');
            else
                led     <= slv_reg(0)(3 downto 0);
                led_bgr <= slv_reg(0)(9 downto 4);
            end if;
        end if;
    end process;

    -- Update read registers (32-63) from inputs (PL -> PS)
    read_in_proc: process(S_AXI_ACLK)
    begin
        if (rising_edge(S_AXI_ACLK)) then
            if (S_AXI_ARESETN = '0') then
                slv_reg(32) <= (others => '0');
                slv_reg(33) <= (others => '0');
            else
                slv_reg(32)             <= version;
                slv_reg(33)(3 downto 0) <= btn;
                slv_reg(33)(5 downto 4) <= sw;
            end if;
        end if;
    end process;

end architecture;