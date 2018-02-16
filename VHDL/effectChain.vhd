----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:50:45 02/15/2018 
-- Design Name: 
-- Module Name:    effectChain - Behavioral 
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

entity effectChain is
    Port ( -- FPGA 50 MHZ
			  CLK : in  STD_LOGIC;
			  
			  -- Audio signals
			  AUDIO_IN : in  STD_LOGIC_VECTOR (23 downto 0);
           AUDIO_OUT : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  READY : in STD_LOGIC;
			  DONE : in STD_LOGIC;
			  
			  -- Pedal
			  PEDAL : in STD_LOGIC;
			  
			  -- Lock
			  LOCK : in STD_LOGIC;
			  LOCKED : out STD_LOGIC_VECTOR(2 downto 0);
			  
			  -- Effect control
			  LAST_EFFECT: in STD_LOGIC;
			  NEXT_EFFECT: in STD_LOGIC;
			  
			  -- Reset
			  RESET : in STD_LOGIC;
			  
			  -- Control ADC
			  ADC0 : in STD_LOGIC_VECTOR(9 downto 0);
			  ADC1 : in STD_LOGIC_VECTOR(9 downto 0);
			  ADC4 : in STD_LOGIC_VECTOR(9 downto 0)
			);
end effectChain;

architecture Behavioral of effectChain is

Signal selectModule : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
Signal effectSelector: integer range 0 to 2 := 0;

Signal activateChain : STD_LOGIC;
begin

-- Select Module
ChooseEffect:process(CLK)
	begin
		if NEXT_EFFECT = '1' and LAST_EFFECT = '0' then
			effectSelector <= effectSelector + 1;
		elsif LAST_EFFECT = '1' and NEXT_EFFECT = '0' then
			effectSelector <= effectSelector - 1;
		end if;
	end process;

with effectSelector select
	selectModule <= "001" when 0,
						 "010" when 1,
						 "100" when 2,
						 "000" when others;



--PortMap
Volume: entity work.volumeControl(Behavioral)
port map( CLK => CLK,
			 RESET => RESET,
			 audioIn => AUDIO_IN,
          audioOut => AUDIO_OUT,
			 Pedal => PEDAL,
			 AC => activateChain,
          SM => selectModule(2), -- TO ADD: back/next mux
          lock => LOCK,				-- TO MOD: lock pulse detect + anti rebond		
			 locked => LOCKED(2),
          volumeGain => ADC0,
          TBD1 => ADC1,							
			 TBD2 => ADC4
			);

end Behavioral;

