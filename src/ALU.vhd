----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is


signal A_unsigned, B_unsigned : unsigned(7 downto 0);
signal result_unsigned : unsigned(8 downto 0); -- 9 bits to catch carry
signal result_final : unsigned(7 downto 0);
signal carry_out : std_logic;
signal overflow : std_logic;


begin


process(i_A, i_B, i_op)
    variable A_unsigned_var, B_unsigned_var : unsigned(7 downto 0);
    variable result_unsigned_var : unsigned(8 downto 0);
    variable result_final_var : unsigned(7 downto 0);
    variable carry_out_var : std_logic;
    variable overflow_var : std_logic;
begin
    -- Cast inputs immediately
    A_unsigned_var := unsigned(i_A);
    B_unsigned_var := unsigned(i_B);

    -- Default values
    result_unsigned_var := (others => '0');
    carry_out_var := '0';
    overflow_var := '0';

    case i_op is
        when "000" =>  -- ADD
            result_unsigned_var := ('0' & A_unsigned_var) + ('0' & B_unsigned_var);
            carry_out_var := result_unsigned_var(8);
            result_final_var := result_unsigned_var(7 downto 0);
            overflow_var := (A_unsigned_var(7) and B_unsigned_var(7) and not result_final_var(7)) or
                            (not A_unsigned_var(7) and not B_unsigned_var(7) and result_final_var(7));

        when "001" =>  -- SUB
            result_unsigned_var := ('0' & A_unsigned_var) - ('0' & B_unsigned_var);
            carry_out_var := not result_unsigned_var(8);  -- Borrow instead of carry
            result_final_var := result_unsigned_var(7 downto 0);
            overflow_var := (A_unsigned_var(7) and not B_unsigned_var(7) and not result_final_var(7)) or
                            (not A_unsigned_var(7) and B_unsigned_var(7) and result_final_var(7));

        when "010" =>  -- AND
            result_final_var := A_unsigned_var and B_unsigned_var;

        when "011" =>  -- OR
            result_final_var := A_unsigned_var or B_unsigned_var;

        when others =>
            result_final_var := (others => '0');
    end case;

    -- Output assignments
    result_final <= result_final_var;
    carry_out    <= carry_out_var;
    overflow     <= overflow_var;
end process;

-- Output assignments to ports (outside process)
o_result <= std_logic_vector(result_final);

o_flags(3) <= result_final(7);                            
o_flags(2) <= '1' when result_final = to_unsigned(0, 8) else '0';
o_flags(1) <= carry_out;                                  
o_flags(0) <= overflow;



end Behavioral;
