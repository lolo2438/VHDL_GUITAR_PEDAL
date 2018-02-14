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
			  
			  -- System global reset
			  RESET : in STD_LOGIC;											-- logical '0' indicates us that reset button was pressed
			  
			  -- Audio signals
			  audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  -- Select Module
           SM : in  STD_LOGIC;											-- Constant '1' indicates us that module is selected	
			  
			  -- Lock Module
           lock : in  STD_LOGIC;											-- goes high for 1 clock cycle, when detected switch between locked and normal mode
			  locked : out STD_LOGIC;										-- indicated that the module is locked
			  
			  -- External control
           volumeGain : in  STD_LOGIC_VECTOR (9 downto 0);
           TBD1 : in  STD_LOGIC_VECTOR (9 downto 0);				-- To be determined
			  TBD2 : in STD_LOGIC_VECTOR (9 downto 0)
			);
end volumeControl;

architecture Behavioral of volumeControl is

-- State machine
Type effectState is (stateNormal,stateLocked);
Signal volumeState : effectState := stateNormal;

-- Saved signals for locked mode
Signal savedVolumeGain : STD_LOGIC_VECTOR (9 downto 0);
Signal savedTBD1 : STD_LOGIC_VECTOR (9 downto 0);
Signal savedTBD2 : STD_LOGIC_VECTOR (9 downto 0);

Signal isLocked : STD_LOGIC := '0';

Signal calAudioIn : SIGNED(23 downto 0) := x"000000";
--Signal calAudioOut : SIGNED(23 downto 0) := (others => '0');

constant gain : integer := 16;					-- Volume Gain constant
constant adcRes : integer := 1023;				-- Adc resolution - 1

begin

calAudioIn <= signed(audioIn);

process(CLK,RESET)

	variable valAdc :integer range 0 to 1023 := 0;
	variable calAudioOut : integer;
	
	begin
		if RESET = '0' then
			volumeState <= stateNormal;
			locked <= '0';
			
		elsif rising_edge(CLK) then
			case volumeState is
				when stateNormal =>
					-- Select Module and Lock = 0 => Foward input to output
					if SM = '0' and lock = '0' then
						audioOut <= audioIn;
						
					-- Selected module = 1 and lock = 0 => Normal operation
					elsif SM = '1' and lock = '0' then
						valAdc := to_integer(unsigned(volumeGain));
						calAudioOut := (to_integer(calAudioIn) * gain / adcRes) * valAdc;				-- calAudioIn * a * adc/1024
						
						-- If value gets over positive peak
						if calAudioOut > 8_388_607 then
							audioOut <= x"7FFFFF";
							
						--If value gets over negative peak
						elsif calAudioOut < -8_388_608 then
							audioOut <= x"800000";
						
						-- If value is in range
						else
							audioOut <= std_logic_vector(to_signed(calAudioOut,24));
						end if;
					
					-- Selected module = '1' and lock = '1' => Lock the module
					elsif SM = '1' and lock = '1' then
						-- Save External controls
						savedVolumeGain <= volumeGain;
						volumeState <= stateLocked;
						islocked <= '1';
					end if;
					
				when stateLocked =>
					valAdc := to_integer(unsigned(savedVolumeGain));
					calAudioOut := (to_integer(calAudioIn) * gain / adcRes) * valAdc;
					
					-- If value gets over positive peak
					if calAudioOut > 8_388_607 then
						AudioOut <= x"7FFFFF";
						
					--If value gets over negative peak
					elsif calAudioOut < -8_388_608 then
						audioOut <= x"800000";
					
					-- If value is in range
					else
						audioOut <= std_logic_vector(to_signed(calAudioOut,24));
					end if;
						
					if lock = '1' then
						islocked <= '0';
						volumeState <= stateNormal;
					end if;
					
			end case;
		end if;
	end process;
end Behavioral;

