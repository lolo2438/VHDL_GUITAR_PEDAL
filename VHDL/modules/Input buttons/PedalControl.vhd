--------------------------------------------
--	Name: Laurent Tremblay
--	Project: Guitar effect processor
--	Module name: PedalControl 
--	Description: This module analyses
--					 the input of the pedal
--					 button and acts accordingly.
-- 1 press => Activate/deactivate, 2 press => lock.
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity PedalControl is
    Port ( CLK : in  STD_LOGIC;			-- System clock
           PEDAL_IN : in  STD_LOGIC;	-- Pedal input
			  PEDAL_OUT : out STD_LOGIC;  -- Pedal state
			  LOCK : out STD_LOGIC;			-- Lock Module
			  RESET : in STD_LOGIC
			  );
end PedalControl;

architecture Behavioral of PedalControl is

type PedalState is (Waiting, Analyzing);
Signal machinePedal : PedalState := Waiting;

signal compteur : unsigned(24 downto 0) := (others => '0');

signal lastPedal : STD_LOGIC := '0';

begin

PEDAL_OUT <= PEDAL_IN;

PedalAnalyze : process(CLK,RESET)
	begin
		if RESET <= '0' then
			LOCK <= '0';
			compteur <= (others => '0');
			machinePedal <= Waiting;
			
		elsif rising_edge(CLK) then
			case machinePedal is
				when Waiting =>
					
					LOCK <= '0';
					
					-- Detected a rising edge/falling edge => pushed pedal button and need to analyze what user wants
					if PEDAL_IN /= lastPedal then
						lastPedal <= PEDAL_IN;
						machinePedal <= Analyzing;
						compteur <= (others => '0');
					end if;
					
				when Analyzing =>
					
					-- If we push the pedal button again -> lock the module
					if PEDAL_IN /= lastPedal then
						lastPedal <= PEDAL_IN;
						LOCK <= '1';
						machinePedal <= Waiting;
					
					-- If nothing happens for 500 miliseconds (time to lock the module), go back to waiting
					elsif compteur >= 25_000_000 then
							machinePedal <= Waiting;
					else
						compteur <= compteur + 1;
					end if;
						
			end case;
		end if;
	end process;

end Behavioral;

