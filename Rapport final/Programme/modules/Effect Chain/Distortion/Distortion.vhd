-------
-- Made by: Laurent Tremblay
-- Project: Guitar pedal
-- Module: Distortion
-- Description: 
--		This modules apply a distortion effect to the signal using 2/3 adc parameters
-------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity Distortion is
    Port (-- System Clock (50 MHz)
			  CLK : in  STD_LOGIC;
			  
			  -- System global reset
		--	  RESET : in STD_LOGIC;											-- logical '0' indicates us that reset button was pressed
			  
			  -- Audio signals
			  audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  -- Select Module
			  Pedal : in STD_LOGIC;											-- Constant '1' indicates that pedal is activated
           SM : in STD_LOGIC;												-- Constant '1' indicates us that module is selected	
			  LM : out STD_LOGIC;
			  
			  LOCK : in STD_LOGIC;
			  
			  -- External control
           Dist : in  STD_LOGIC_VECTOR (9 downto 0);				-- Ammount of distortion 	  -> Gain of the pre-cut signal
           Tone : in  STD_LOGIC_VECTOR (9 downto 0);				-- Tone of the signal		  -> Filtre passe bas
			  Level : in STD_LOGIC_VECTOR (9 downto 0);				-- Ammount of gain of volume -> gain of the post-processed signal
			
			  distOut : out STD_LOGIC_VECTOR (9 downto 0);
			  toneOut : out STD_LOGIC_VECTOR (9 downto 0);
			  levelOut : out STD_LOGIC_VECTOR (9 downto 0)
			);
end Distortion;

architecture Behavioral of Distortion is

signal sDist : signed(10 downto 0);
signal sLevel : signed(10 downto 0);
signal sTone : signed(10 downto 0);

signal savedDist : signed(10 downto 0);
signal savedLevel : signed(10 downto 0);
signal savedTone : signed(10 downto 0);

signal locked : STD_LOGIC := '0';

Signal lastAudioIn23 : STD_LOGIC := '0';

signal tempVector1 : std_logic_vector(37 downto 0) := (others => '0');
signal tempVector2 : std_logic_vector(23 downto 0) := (others => '0');

signal tempCal1 : signed(37 downto 0) := (others => '0');

constant limit : signed(23 downto 0) := x"300000";--x"427E56";
constant levelGain : signed(2 downto 0) := b"101";					-- Temp gain:5
constant distGain : signed(2 downto 0) := b"011";
signal newWave : STD_LOGIC := '0';

begin

distOut <= std_logic_vector(sDist(9 downto 0));
toneOut <= std_logic_vector(sTone(9 downto 0));
levelOut <= std_logic_vector(sLevel(9 downto 0));

LM <= locked;

detectLock:
process(CLK,SM,LOCK)
begin
	if rising_edge(CLK) and SM = '1' and LOCK = '1' then
		locked <= not locked;
		
		savedDist <= signed('0' & Dist);
		savedLevel <= signed('0' & Level);
		savedTone <= signed('0' & Tone);
	end if;
end process;

detectNewWave:
process(CLK)
begin
	if rising_edge(CLK) then
		if audioIn(23) = '0' and lastAudioIn23 = '1' then	--when the audio signal goes from negative -> positive
			if locked = '0' then
				sDist <= signed('0' & Dist);
				sLevel <= signed('0' & Level);
				sTone <= signed('0' & Tone);
			else
				sDist <= savedDist;
				sLevel <= savedLevel;
				sTone <= savedTone;
			end if;
		end if;
		
		lastAudioIn23 <= audioIn(23);
	end if;
end process;

Distortion:
process(CLK)
	begin
		if rising_edge(CLK) then
			if SM = '1' and Pedal = '1'  then					-- Selected module = 1 and pedal was activated => Normal operation
				tempVector1 <= std_logic_vector( sdist * distGain * signed(audioIn));
				
				-- Add distortion by cutting the pre-amp'ed signal
				if signed(tempVector1(34 downto 10)) > limit then
					tempVector2 <= std_logic_vector(limit);
					
				elsif signed(tempVector1(34 downto 10)) < (0 - limit) then
					tempVector2 <= std_logic_vector(0 - limit);	
				else
					tempVector2 <= audioIn;
				end if;
				
				-- Post-distortion amplification
				tempCal1 <= signed(tempVector2) * signed(levelGain) * signed(sLevel);
				
				-- Just making sure here we dont go over the maximum
				if tempCal1(34 downto 10) > x"7FFFFF" then
					audioOut <= x"7FFFFF";
				elsif tempCal1(34 downto 10) < x"800000" then
					audioOut <= x"800000";
				else
					-- post amp signal = > preampresult * gain * level/1024
					audioOut <= std_logic_vector(tempCal1(33 downto 10));
				end if;
				
			else																	   -- If module is not selected
				audioOut <= audioIn;
			end if;
		end if;
end process;

end Behavioral;

