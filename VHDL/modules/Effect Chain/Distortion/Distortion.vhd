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
Signal savedCut : STD_LOGIC_VECTOR (9 downto 0);

Signal isLocked : STD_LOGIC := '0';

Signal calAudioIn : SIGNED(23 downto 0) := (others => '0');

constant limitpos : SIGNED(26 downto 0);
constant limitneg : SIGNED(26 downto 0);

begin
-- https://en.wikipedia.org/wiki/Distortion

calAudioIn <= signed(audioIn);

process(CLK,RESET)
	begin
		if RESET = '0' then
			distState <= stateNormal;
			locked <= '0';
			
		elsif rising_edge(CLK) then
			case distState is
				when stateNormal =>						
					if SM = '1' and Pedal = '1'  then								-- Selected module = 1 and pedal was activated => Normal operation
						
					else																	   -- Otherwise foward signal
						audioOut <= std_logic_vector(calAudioIn);
					end if;
					
					if SM = '1' and lock = '1' then							      -- Selected module = '1' and lock = '1' => Lock the module
						-- Save External controls
						savedDist <= Dist;
						savedTone <= Tone;
						savedCut <= Cut;
						distState <= stateLocked;
						locked <= '1';
					end if;
					
				when stateLocked =>						
					-- If module is selected or chain effect is activated
					if Pedal = '1' then
					
					-- If condition not met, foward signal
					else
						audioOut <= std_logic_vector(calAudioIn);
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

