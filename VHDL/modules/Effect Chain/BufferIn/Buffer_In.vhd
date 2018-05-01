-------
-- Made by: Laurent Tremblay
-- Project: Guitar pedal
-- Module: BufferIn
-- Description: This module stores the value of the audio signal in a register
-------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Buffer_In is
    Port ( CLK : in  STD_LOGIC;
           audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
           dataReady : in  STD_LOGIC);
end Buffer_In;

architecture Behavioral of Buffer_In is

signal audioBuffer : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin

process(CLK)
	begin
		if rising_edge(CLK) then
			if dataReady = '1' then
				audioBuffer <= audioIn;
			end if;
		end if;
	end process;

audioOut <= audioBuffer;

end Behavioral;

