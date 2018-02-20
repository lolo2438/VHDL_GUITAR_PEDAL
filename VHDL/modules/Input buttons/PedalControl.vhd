----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:06:58 02/18/2018 
-- Design Name: 
-- Module Name:    PedalControl - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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

signal compteur : unsigned(25 downto 0) := (others => '0');

signal lastPedal : STD_LOGIC := '0';
signal PedalStateOut : STD_LOGIC := '0';

begin
-- PEDAL CONTROLS
-- 1 press => Activate, press for 2 seconds => lock.

PEDAL_OUT <= PedalStateOut;

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
					
					-- Detected a rising edge => pushed pedal button and need to analyze what user wants
					if PEDAL_IN = '1' and lastPedal = '0' then
						machinePedal <= Analyzing;
						compteur <= (others => '0');
					end if;
					
				when Analyzing =>
				
					-- If we release the pedal before 2 seconds, then it means that we only want to activate
					if PEDAL_IN = '0' and lastPedal = '1' then
						PedalStateOut <= not PedalStateOut;
						machinePedal <= Waiting;
					
					-- While we keep holding the pedal In, check to see if we overflowed the counter
					elsif PEDAL_IN = '1' and lastPedal = '1' then
						
						if compteur >= 50_000_000 then
							LOCK <= '1';
							machinePedal <= Waiting;
						else
							compteur <= compteur + 1;
						end if;
						
					end if;
			end case;
			
			lastPedal <= PEDAL_IN;

		end if;
	end process;

end Behavioral;

