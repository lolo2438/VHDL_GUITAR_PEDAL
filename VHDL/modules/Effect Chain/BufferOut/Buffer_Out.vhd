----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:08:28 02/19/2018 
-- Design Name: 
-- Module Name:    Buffer_Out - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Buffer_Out is
    Port ( CLK : in  STD_LOGIC;
           audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
           done : in  STD_LOGIC);
end Buffer_Out;

architecture Behavioral of Buffer_Out is

signal audioBuffer : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin

audioBuffer <= audioIn;

process(CLK)
	begin
		if rising_edge(CLK) then
			if done = '1' then
				audioOut <= audioBuffer;
			end if;
		end if;
	end process;

end Behavioral;

