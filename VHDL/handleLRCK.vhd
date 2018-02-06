----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:06:08 02/06/2018 
-- Design Name: 
-- Module Name:    handleLRCK - Behavioral 
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

entity handleLRCK is
	port(
			-- Bit clock
			BCLK : in  STD_LOGIC;
			-- Left Right Clock
			LRCK : in  STD_LOGIC;
			
			-- Pulse that tells when to start
			start : out STD_LOGIC;
			
			-- OTHERS 
			RESET : in STD_LOGIC
			);
end handleLRCK;

architecture Behavioral of handleLRCK is

Signal lastLRCK : STD_LOGIC;

begin

detectLRCK: process(BCLK)
	begin
		if(lastLRCK /= LRCK) then									-- Change in LRCK indicates new data
			lastLRCK <= LRCK;
			start <= '1';
		else
			start <= '0';
		end if;
	end process;
end Behavioral;

