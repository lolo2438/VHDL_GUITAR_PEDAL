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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
			  
			  -- Lock Module
           lock : in  STD_LOGIC;											-- goes high for 1 clock cycle, when detected switch between locked and normal mode
			  locked : out STD_LOGIC;										-- indicated that the module is locked
			  
			  -- External control
           Dist : in  STD_LOGIC_VECTOR (9 downto 0);				-- Ammount of distortion 	  -> Gain of the pre-cut signal
           Tone : in  STD_LOGIC_VECTOR (9 downto 0);				-- Tone of the signal		  -> Filtre passe bas
			  Level : in STD_LOGIC_VECTOR (9 downto 0)				-- Ammount of gain of volume -> gain of the post-processed signal
			);
end Distortion;

architecture Behavioral of Distortion is

Type effectState is (stateNormal,stateLocked);
Signal distState : effectState := stateNormal;

-- Saved signals for locked mode
Signal savedDist : STD_LOGIC_VECTOR (9 downto 0);
Signal savedTone : STD_LOGIC_VECTOR (9 downto 0);
Signal savedLevel : STD_LOGIC_VECTOR (9 downto 0);

Signal isLocked : STD_LOGIC := '0';


signal tempVector1 : std_logic_vector(23 downto 0) := (others => '0');

signal tempCal1 : signed(37 downto 0) := (others => '0');

signal limit : signed(25 downto 0) := (others => '0');

constant levelGain : signed(2 downto 0) := b"010";					-- Temp gain: 2

begin

-- à améliorer
-- add low pass filter here for tone -> more tone = higher cut off

-- https://en.wikipedia.org/wiki/Distortion 

-- dépassement a *dist

process(CLK,RESET)
	begin
		if RESET = '0' then
			distState <= stateNormal;
			locked <= '0';
			
		elsif rising_edge(CLK) then
			case distState is
				when stateNormal =>						
					if SM = '1' and Pedal = '1'  then					-- Selected module = 1 and pedal was activated => Normal operation
						limit <= x"7FFFFF" - (signed('0' & Dist) * b"010000000001000");
						
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
						tempCal1 <= signed(tempVector1) * levelGain * signed('0' & Level);
						
						-- post amp signal = > preampresult * gain * level/1024
						audioOut <= std_logic_vector(tempCal1(33 downto 10));
						
	
					else																	   -- Otherwise foward signal
						audioOut <= audioIn;
					end if;
					
					if SM = '1' and lock = '1' then							      -- Selected module = '1' and lock = '1' => Lock the module
						-- Save External controls
						savedDist <= Dist;
						savedTone <= Tone;
						savedLevel <= Level;
						distState <= stateLocked;
						locked <= '1';
					end if;
					
				when stateLocked =>
					if Pedal = '1' then
					
					else
						audioOut <= audioIn;
					end if;
					
					-- If module is selected and we unlock
					if SM = '1' and lock = '1' then
						locked <= '0';
						distState <= stateNormal;
					end if;
					
			end case;
		end if;
	end process;

end Behavioral;

