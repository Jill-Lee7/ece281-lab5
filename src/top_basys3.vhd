--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	
-- FSM
component controller_fsm is
    port (
        i_reset : in std_logic;
        i_adv   : in std_logic;
        o_cycle : out std_logic_vector(3 downto 0)
    );
end component;

-- ALU
component ALU is
    port (
        i_A      : in std_logic_vector(7 downto 0);
        i_B      : in std_logic_vector(7 downto 0);
        i_op     : in std_logic_vector(2 downto 0);
        o_result : out std_logic_vector(7 downto 0);
        o_flags  : out std_logic_vector(3 downto 0)
    );
end component;


-- Seven-segment decoder
component sevenseg_decoder is
    Port (
        i_Hex   : in  std_logic_vector(3 downto 0);
        o_seg_n : out std_logic_vector(6 downto 0)
    );
end component;




-- Internal wiring signals
signal w_cycle     : std_logic_vector(3 downto 0);  -- FSM state output
signal w_op        : std_logic_vector(2 downto 0);  -- opcode from switches
signal w_operand_A : std_logic_vector(7 downto 0);  -- stored A
signal w_operand_B : std_logic_vector(7 downto 0);  -- stored B
signal w_result    : std_logic_vector(7 downto 0);  -- ALU output
signal w_flags     : std_logic_vector(3 downto 0);  -- ALU flags

  
begin
	-- PORT MAPS ----------------------------------------

fsm_inst : controller_fsm
    port map (
        i_reset => btnU,
        i_adv   => btnC,
        o_cycle => w_cycle
    );
    
alu_inst : ALU
    port map (
        i_A      => w_operand_A,
        i_B      => w_operand_B,
        i_op     => w_op,
        o_result => w_result,
        o_flags  => w_flags
    );
    
sevenseg_inst : sevenseg_decoder
    port map (
        i_Hex   => w_result(3 downto 0),
        o_seg_n => seg
    );



	
	-- CONCURRENT STATEMENTS ----------------------------
	
	
-- Load opcode from sw(2:0)
w_op <= sw(2 downto 0);

-- FSM-based operand control
with w_cycle select
    w_operand_A <= sw when "0010",  -- LOAD_A
                   w_operand_A when others;

with w_cycle select
    w_operand_B <= sw when "0100",  -- LOAD_B
                   w_operand_B when others;

-- Output flags and FSM state to LEDs
led(3 downto 0)  <= w_flags;     -- ALU flags: [N Z C V]
led(7 downto 4)  <= w_cycle;     -- FSM state (one-hot)
led(15 downto 8) <= w_result;    -- ALU result

-- Display result on rightmost 7-seg digit
-- (just showing lower 4 bits for simplicity here)
an <= "1110";  -- enable rightmost digit only

	
	
end top_basys3_arch;
