----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:08:38 02/12/2018 
-- Design Name: 
-- Module Name:    volumeControl - Behavioral 
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

use IEEE.NUMERIC_STD.ALL;


entity volumeControl is
    Port ( -- System Clock (50 MHz)
			  CLK : in  STD_LOGIC;
			  
			  -- System global reset
			  RESET : in STD_LOGIC;											-- logical '0' indicates us that reset button was pressed
			  
			  -- Audio signals
			  audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  -- Select Module
			  Pedal : in STD_LOGIC;
           SM : in STD_LOGIC;												-- Constant '1' indicates us that module is selected	
			  
			  -- Lock Module
           lock : in  STD_LOGIC;											-- goes high for 1 clock cycle, when detected switch between locked and normal mode
			  locked : out STD_LOGIC;										-- indicated that the module is locked
			  
			  -- External control
           vol : in  STD_LOGIC_VECTOR (9 downto 0);
           TBD1 : in  STD_LOGIC_VECTOR (9 downto 0);				-- To be determined
			  TBD2 : in STD_LOGIC_VECTOR (9 downto 0)
			);
end volumeControl;

architecture Behavioral of volumeControl is

-- State machine
Type effectState is (stateNormal,stateLocked);
Signal volumeState : effectState := stateNormal;

-- Saved signals for locked mode
Signal savedVolumeGain : STD_LOGIC_VECTOR (9 downto 0);
Signal savedTBD1 : STD_LOGIC_VECTOR (9 downto 0);
Signal savedTBD2 : STD_LOGIC_VECTOR (9 downto 0);
Signal sVolume : signed(10 downto 0) := (others => '0');
Signal isLocked : STD_LOGIC := '0';

Signal lastAudioIn23 : STD_LOGIC := '0';
signal tempVector : STD_LOGIC_VECTOR(37 downto 0) := (others => '0');

constant gain : signed(2 downto 0) := b"010";					      -- Volume Gain constant - 2

begin

locked <= isLocked;

detectNewWave: process(CLK)	--A tester: est ce que le fait de garder le volume fixe le temps d'une wave repare le bruit etrange
begin
	if rising_edge(CLK) then
		if audioIn(23) = '0' and lastAudioIn23 = '1' then	--when the audio signal goes from negative -> positive
			sVolume <= ('0' & signed(Vol));
		end if;
		
		lastAudioIn23 <= audioIn(23);
	end if;
end process;

process(CLK,RESET)
	begin
		if RESET = '0' then
			volumeState <= stateNormal;
			islocked <= '0';
			
		elsif rising_edge(CLK) then
			case volumeState is
				when stateNormal =>						
					-- Selected module = 1 and pedal was activated => Normal operation				
					if SM = '1' and Pedal = '1'  then
						tempVector <= std_logic_vector(signed(audioIn) * gain* sVolume); -- quand on fait * vol il y a du bruit à des endroits etrange
						
						-- If value gets over positive peak
						if signed(tempVector(34 downto 10)) > x"7FFFFF" then
							audioOut <= x"7FFFFF";
							
						--If value gets over negative peak
							elsif signed(tempVector(34 downto 10)) < x"800000" then
							audioOut <= x"800000";
						
						-- If value is in range
						else
							audioOut <= tempVector(33 downto 10);
						end if;
						
					--Otherwise foward signal
					else
						audioOut <= audioIn;
					end if;
					
					-- Selected module = '1' and lock = '1' => Lock the module
					if SM = '1' and lock = '1' then
						-- Save External controls
--						savedVolumeGain <= volumeGain;
						volumeState <= stateLocked;
						islocked <= '1';
					end if;
					
				when stateLocked =>						
					-- If module is selected or chain effect is activated
					if Pedal = '1' then
--						tempCal <= signed(audioIn) * gain * (signed('0' & savedVolumeGain));
						
						-- If value gets over positive peak
			--			if tempCal(36 downto 10) >= 8_388_607 then
			-- AudioOut <= x"7FFFFF";
		--					
						--If value gets over negative peak
--						elsif tempCal(36 downto 10) <= -8_388_608 then
		--					audioOut <= x"800000";
					
						-- If value is in range
				--		else
			--				audioOut <= std_logic_vector(tempCal(33 downto 10));
				--		end if;
					
					-- If condition not met, foward signal
					else
						audioOut <= audioIn;
					end if;
					
					-- If module is selected and we unlock
					if SM = '1' and lock = '1' then
						islocked <= '0';
						volumeState <= stateNormal;
					end if;
					
			end case;
		end if;
	end process;
end Behavioral;

