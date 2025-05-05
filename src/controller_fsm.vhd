----------------------------------------------------------------------------------
-- Company: USAFA
-- Engineer: Essig
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: A super cool CPU
-- Module Name: controller_fsm - FSM
-- Project Name: Lab 4 YEYE
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

type state_type is (RESET, LOAD_A, LOAD_B, EXECUTE);
signal state, next_state : state_type;


begin


process(i_reset, i_adv)
begin
    if i_reset = '1' then
        state <= RESET;
    elsif rising_edge(i_adv) then
        state <= next_state;
    end if;
end process;

process(state)
begin
    case state is
        when RESET =>
            next_state <= LOAD_A;
        when LOAD_A =>
            next_state <= LOAD_B;
        when LOAD_B =>
            next_state <= EXECUTE;
        when EXECUTE =>
            next_state <= RESET;
        when others =>
            next_state <= RESET;
    end case;
end process;



process(state)
begin
    case state is
        when RESET =>
            o_cycle <= "0001";
        when LOAD_A =>
            o_cycle <= "0010";
        when LOAD_B =>
            o_cycle <= "0100";
        when EXECUTE =>
            o_cycle <= "1000";
        when others =>
            o_cycle <= "0001";
    end case;
end process;




end FSM;
