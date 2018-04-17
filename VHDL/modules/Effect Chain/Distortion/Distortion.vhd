----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:25:26 02/12/2018 
-- Design Name: 
-- Module Name:    Distortion - Behavioral 
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

entity Distortion is
    Port (-- System Clock (50 MHz)
			  CLK : in  STD_LOGIC;
			  
			  -- System global reset
			  RESET : in STD_LOGIC;											-- logical '0' indicates us that reset button was pressed
			  
			  -- Audio signals
			  audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  -- Select Module
			  Pedal : in STD_LOGIC;											-- Constant '1' indicates that pedal is activated
           SM : in STD_LOGIC;												-- Constant '1' indicates us that module is selected	
			  
			  -- External control
           Dist : in  STD_LOGIC_VECTOR (9 downto 0);				-- Ammount of distortion 	  -> Gain of the pre-cut signal
           Tone : in  STD_LOGIC_VECTOR (9 downto 0);				-- Tone of the signal		  -> Filtre passe bas
			  Level : in STD_LOGIC_VECTOR (9 downto 0)				-- Ammount of gain of volume -> gain of the post-processed signal
			);
end Distortion;

architecture Behavioral of Distortion is

COMPONENT DiviseurDist
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_divisor_tvalid : IN STD_LOGIC;
    s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    s_axis_dividend_tvalid : IN STD_LOGIC;
    s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
END COMPONENT;

Signal sDist : signed(10 downto 0);
signal sLevel : signed(10 downto 0);
Signal lastAudioIn23 : STD_LOGIC := '0';

signal tempVector1 : std_logic_vector(23 downto 0) := (others => '0');

signal tempCal1 : signed(58 downto 0) := (others => '0');

signal limit : signed(25 downto 0) := (others => '0');

signal levelGain : signed(23 downto 0) := (others => '0');					-- Temp gain: 2

signal newWave : STD_LOGIC := '0';

signal lastAudioIn : signed(23 downto 0) := (others => '0');
signal tempPeak : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
signal maximumPeak : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

-- Signal for divisor
Signal loadToDivisor : STD_LOGIC := '0';
Signal divisionDone : STD_LOGIC := '0';
Signal dataOutDiviser : STD_LOGIC_VECTOR(47 downto 0) := (others => '0');
Signal divisor : STD_LOGIC_VECTOR(23 downto 0);

begin

-- à améliorer
-- add low pass filter here for tone -> more tone = higher cut off

-- https://en.wikipedia.org/wiki/Distortion 

-- dépassement a *dist
-- Améliorer : levelGain change dépendament du niveau de distortion pour toujour pouvoir atteindre le max

detectNewWave: process(CLK)	--A tester: est ce que le fait de garder le volume fixe le temps d'une wave repare le bruit etrange
begin
	if rising_edge(CLK) then
		if audioIn(23) = '0' and lastAudioIn23 = '1' then	--when the audio signal goes from negative -> positive
			sDist <= signed('0' & Dist);
			sLevel <= signed('0' & Level);
			newWave <= '1';
		else
			newWave <= '0';
		end if;
		
		lastAudioIn23 <= audioIn(23);
	end if;
end process;

detectPeak:
process(CLK)
begin
	if rising_edge(CLK) then
		if newWave = '0' then				-- If our input wave is not renewed
			if signed(audioIn) > lastAudioIn then
				tempPeak <= audioIn;
				loadToDivisor <= '0';
			else
				maximumPeak <= tempPeak;
				loadToDivisor <= '1';
			end if;
			
			lastAudioIn <= signed(audioIn);
			
		else
			lastAudioIn <= (others => '0');
		end if;
		
	end if;
end process;

Distortion:
process(CLK)
	begin
		if rising_edge(CLK) then
			if SM = '1' and Pedal = '1'  then					-- Selected module = 1 and pedal was activated => Normal operation
				limit <= x"7FFFFF" - (signed(sDist) * b"0100_0000_0001_000"); --8200 (2^31 / 1024)
				
				-- Protection for divisor
				if limit > signed(maximumPeak) then
					divisor <= maximumPeak;
				else
					divisor <= STD_LOGIC_VECTOR(limit(23 downto 0));
				end if;
				
				-- Add distortion by cutting the pre-amp'ed signal
				if signed(audioIn) > limit then
					tempVector1 <= std_logic_vector(limit(23 downto 0));
					
				elsif signed(audioIn) < (0 - limit(23 downto 0)) then
					tempVector1 <= std_logic_vector(0 - limit(23 downto 0));
					
				else
					tempVector1 <= audioIn;
				end if;
				
				-- tone should go here
		
				-- Post-distortion amplification
				tempCal1 <= signed(tempVector1) * signed(levelGain) * signed(sLevel);
				
				-- post amp signal = > preampresult * gain * level/1024
				audioOut <= std_logic_vector(tempCal1(33 downto 10));
				
			else																	   -- Otherwise foward signal
				audioOut <= audioIn;
			end if;
		end if;
end process;


detectDivisionDone:
process(CLK)
begin
	if rising_edge(CLK) then
		if divisionDone = '1' then
			levelGain <= signed(dataOutDiviser(47 downto 24));
		end if;
	end if;
end process;

Gain : DiviseurDist
  PORT MAP (
    aclk => CLK,
    s_axis_divisor_tvalid => loadToDivisor,
    s_axis_divisor_tdata => divisor,
    s_axis_dividend_tvalid => loadToDivisor,
    s_axis_dividend_tdata => maximumPeak,
    m_axis_dout_tvalid => divisionDone,
    m_axis_dout_tdata => dataOutDiviser
  );

end Behavioral;

