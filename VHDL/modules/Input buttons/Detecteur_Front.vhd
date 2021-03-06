--------------------------------------------
--	Name: Laurent Tremblay
--	Project: Guitar effect processor
--	Module name: Decteur_Front
--	Description: This module checks if there
--					 was a rising edge and sends
--					 a pulse.
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Detecteur_front is
    Port ( CLK : in  STD_LOGIC;
           Input : in  STD_LOGIC;
           Output : out  STD_LOGIC);
end Detecteur_front;

architecture Behavioral of Detecteur_front is

signal lastInput : STD_LOGIC;

begin

Detecteur_Front: process(CLK)
	begin
		if rising_edge(CLK) then
			if lastInput = '0' and Input = '1' then
				Output <= '1';
			else
				Output <= '0';
			end if;
			
			lastInput <= Input;
		end if;
	end process;

end Behavioral;

