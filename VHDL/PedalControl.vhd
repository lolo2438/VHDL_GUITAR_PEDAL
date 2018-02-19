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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PedalControl is
    Port ( CLK : in  STD_LOGIC;			-- System clock
           PEDAL_IN : in  STD_LOGIC;	-- Pedal input
			  PEDAL_OUT : out STD_LOGIC;  -- Pedal state
			  LOCK : out STD_LOGIC;			-- Lock Module
			  AA : out STD_LOGIC				-- Activate All
			  );
end PedalControl;

architecture Behavioral of PedalControl is

begin
-- PEDAL CONTROLS
-- 1 press => Activate, 2 presses => Activate all, press for 2 seconds => lock. -- to add

end Behavioral;

