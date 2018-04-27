----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:35:09 04/27/2018 
-- Design Name: 
-- Module Name:    startUpReset - Behavioral 
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

entity startUpReset is
    Port ( CLK : in  STD_LOGIC;
           RESET_FROM_IO : in  STD_LOGIC;
           RESET_FOR_BOOT : out  STD_LOGIC);
end startUpReset;

architecture Behavioral of startUpReset is

signal compteur : unsigned(24 downto 0) := (others => '0');

begin

process(CLK,RESET_FROM_IO)
begin
	if RESET_FROM_IO = '0' then
		compteur <= (others => '0');
	elsif rising_edge(CLK) then
		if compteur = x"17D7840" then					-- 25_000_000 => 0,5 sec
			RESET_FOR_BOOT <= '1';
		else
			RESET_FOR_BOOT <= '0';
			compteur <= compteur + 1;
		end if;
	end if;
end process;


end Behavioral;

