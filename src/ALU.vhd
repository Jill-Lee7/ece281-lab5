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
begin
    -- Cast inputs to unsigned
    A_unsigned <= unsigned(i_A);
    B_unsigned <= unsigned(i_B);

    -- Default values
    result_unsigned <= (others => '0');
    carry_out <= '0';
    overflow <= '0';

    case i_op is
        when "000" =>  -- ADD
            result_unsigned <= ('0' & A_unsigned) + ('0' & B_unsigned);
            carry_out <= result_unsigned(8);
            result_final <= result_unsigned(7 downto 0);
            overflow <= (A_unsigned(7) and B_unsigned(7) and not result_final(7)) or
                        (not A_unsigned(7) and not B_unsigned(7) and result_final(7));

        when "001" =>  -- SUB
            result_unsigned <= ('0' & A_unsigned) - ('0' & B_unsigned);
            carry_out <= not result_unsigned(8);  -- Borrow instead of carry
            result_final <= result_unsigned(7 downto 0);
            overflow <= (A_unsigned(7) and not B_unsigned(7) and not result_final(7)) or
                        (not A_unsigned(7) and B_unsigned(7) and result_final(7));

        when "010" =>  -- AND
            result_final <= A_unsigned and B_unsigned;
            carry_out <= '0';
            overflow <= '0';

        when "011" =>  -- OR
            result_final <= A_unsigned or B_unsigned;
            carry_out <= '0';
            overflow <= '0';

        when others =>
            result_final <= (others => '0');
            carry_out <= '0';
            overflow <= '0';
    end case;
end process;



-- Output assignments
o_result <= std_logic_vector(result_final);

-- Flags: N (3), Z (2), C (1), V (0)
o_flags(3) <= result_final(7);                             -- Negative (MSB)
o_flags(2) <= '1' when result_final = 0 else '0';          -- Zero
o_flags(1) <= carry_out;                                   -- Carry
o_flags(0) <= overflow;                                    -- Overflow



end Behavioral;
