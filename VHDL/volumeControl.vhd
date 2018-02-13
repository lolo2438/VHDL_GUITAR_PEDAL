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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity volumeControl is
    Port ( -- System Clock (50 MHz)
			  CLK : in  STD_LOGIC;
			  
			  -- Audio signals
			  audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  -- Select Module
           SM : in  STD_LOGIC;
			  
			  -- Lock Module
           LM : in  STD_LOGIC;
			  Locked : out STD_LOGIC;
			  
			  -- External control
           volumeGain : in  STD_LOGIC_VECTOR (9 downto 0);
           TBD : in  STD_LOGIC_VECTOR (9 downto 0);
			  TBD : in STD_LOGIC_VECTOR (9 downto 0)
			);
end volumeControl;

architecture Behavioral of volumeControl is

Constant testGain : STD_LOGIC_VECTOR(9 downto 0) := b"0000000000";

begin

--audioOut <= audioIn * volumeGain;

end Behavioral;

