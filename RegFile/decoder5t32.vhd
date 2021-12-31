-------------------------------------------------------------------------
-- Ian Johnson
-- Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- decoder5t32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 5:32 decoder
--
--
-- NOTES:
-- 9/16/21
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity decoder5t32 is 
  port(i_EN	    : in std_logic; --enable
       i_S          : in std_logic_vector(5-1 downto 0);-- decoder select
       o_Q          : out std_logic_vector(32-1 downto 0));-- decoder output

end decoder5t32;

architecture dataflow of decoder5t32 is
	signal s_Q : std_logic_vector(32-1 downto 0);
begin
	with i_S select
		s_Q <= x"00000001" when "00000",
		       x"00000002" when "00001",
		       x"00000004" when "00010",
		       x"00000008" when "00011",
		       x"00000010" when "00100",
		       x"00000020" when "00101",
		       x"00000040" when "00110",
		       x"00000080" when "00111",
		       x"00000100" when "01000",
		       x"00000200" when "01001",
		       x"00000400" when "01010",
		       x"00000800" when "01011",
		       x"00001000" when "01100",
		       x"00002000" when "01101",
		       x"00004000" when "01110",
		       x"00008000" when "01111",
		       x"00010000" when "10000",
		       x"00020000" when "10001",
		       x"00040000" when "10010",
		       x"00080000" when "10011",
		       x"00100000" when "10100",
		       x"00200000" when "10101",
		       x"00400000" when "10110",
		       x"00800000" when "10111",
		       x"01000000" when "11000",
		       x"02000000" when "11001",
		       x"04000000" when "11010",
		       x"08000000" when "11011",
		       x"10000000" when "11100",
		       x"20000000" when "11101",
		       x"40000000" when "11110",
		       x"80000000" when "11111",
		       x"00000000" when others;
		o_Q <= s_Q when i_EN = '1' else x"00000000";
end dataflow;


