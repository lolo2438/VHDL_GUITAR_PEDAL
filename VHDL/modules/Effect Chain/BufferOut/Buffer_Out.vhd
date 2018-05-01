-------
-- Made by: Laurent Tremblay
-- Project: Guitar pedal
-- Module: BufferOut
-- Description: This module takes the audio signal and sends it to the I2S interface when its ready
-------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

