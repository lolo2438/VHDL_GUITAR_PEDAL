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
			  LM : out STD_LOGIC;
			  
			  LOCK : in STD_LOGIC;
			  
			  -- External control
           vol : in  STD_LOGIC_VECTOR (9 downto 0);
			  
			  volOut : out  STD_LOGIC_VECTOR (9 downto 0)
			);
end volumeControl;

architecture Behavioral of volumeControl is

signal sVolume : signed(10 downto 0) := (others => '0');

signal savedVolume : signed(10 downto 0) := (others => '0');

signal locked : STD_LOGIC := '0';
signal lastLocked : STD_LOGIC := '0';

Signal lastAudioIn23 : STD_LOGIC := '0';
signal tempVector : STD_LOGIC_VECTOR(37 downto 0) := (others => '0');

constant gain : signed(2 downto 0) := b"010";					      -- Volume Gain constant - 2

begin

volOut <= std_logic_vector(sVolume(9 downto 0));

LM <= locked;

detectLock:
process(CLK,SM,LOCK)
begin
	if rising_edge(CLK) and SM = '1' and LOCK = '1' then
		locked <= not locked;
		savedVolume <= signed('0' & Vol);
	end if;
end process;


detectNewWave:
process(CLK)	--A tester: est ce que le fait de garder le volume fixe le temps d'une wave repare le bruit etrange
begin
	if rising_edge(CLK) then
		if audioIn(23) = '0' and lastAudioIn23 = '1' then	--when the audio signal goes from negative -> positive
			if locked = '0' then
				sVolume <= ('0' & signed(Vol));
			else
				sVolume <= savedVolume;
			end if;
		end if;
		
		lastAudioIn23 <= audioIn(23);
	end if;
end process;


Main:
process(CLK)
	begin
		if rising_edge(CLK) then						
			if SM = '1' then 
				
				if Pedal = '1'  then
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
				else
					audioOut <= audioIn;
				end if;
			--Otherwise foward signal
			else
				audioOut <= audioIn;
			end if;
		end if;
	end process;
end Behavioral;

