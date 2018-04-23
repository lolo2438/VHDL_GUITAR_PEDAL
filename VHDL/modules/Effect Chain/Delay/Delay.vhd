----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:47:57 04/17/2018 
-- Design Name: 
-- Module Name:    Delay - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Delay is
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
			  
			  -- External control
           eLevel : in  STD_LOGIC_VECTOR (9 downto 0);			-- Effect Level: volume of the delay
           fBack : in  STD_LOGIC_VECTOR (9 downto 0);				-- Feedback: ammount of time the sound is played
			  dTime : in STD_LOGIC_VECTOR (9 downto 0)				-- Delay Time: time between effects
			);
end Delay;

architecture Behavioral of Delay is

begin


end Behavioral;

