----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:33:55 02/23/2018 
-- Design Name: 
-- Module Name:    Tremolo - Behavioral 
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

entity Tremolo is
	Port(-- System Clock (50 MHz)
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
           Rate  : in  STD_LOGIC_VECTOR (9 downto 0);
           Wave  : in  STD_LOGIC_VECTOR (9 downto 0);				
			  Depth : in STD_LOGIC_VECTOR (9 downto 0)
			);
end Tremolo;

architecture Behavioral of Tremolo is

Type effectState is (stateNormal,stateLocked);
Signal tremState : effectState := stateNormal;

-- Saved signals for locked mode
Signal savedRate  : STD_LOGIC_VECTOR (9 downto 0);
Signal savedWave  : STD_LOGIC_VECTOR (9 downto 0);
Signal savedDepth : STD_LOGIC_VECTOR (9 downto 0);

Signal isLocked : STD_LOGIC := '0';

Signal calAudio : SIGNED(23 downto 0) := (others => '0');

Signal waveDelay : signed(11 downto 0) := (others => '0');
Signal genWave : signed(11 downto 0) := (others => '0');
Signal waveOut : signed(11 downto 0) := (others => '0');
Signal direction : STD_LOGIC := '0';

begin

ClkDiv:process(CLK,RESET)
	begin
	end process;


-- CLK DIV => 50MHz / 1024 steps -> bouger a 6
WaveGen:process(CLK,RESET)
	begin
		if RESET = '0' then
			waveOut <= (others => '0');
		elsif rising_edge(CLK) then												-- Wave  : Triangle -> square      := 0 -> 1 sample, -> 1023 -> 1024 sample
			if direction = '0' then  												-- Going up
				if waveDelay < signed('0' & Wave) and waveDelay < 1024 then				-- count delay
					waveDelay <= waveDelay + ((b"00" & signed(Rate)) + 1);
				else																		-- add delay to wave
					genWave <= waveDelay;
	
					if genWave >= 1024 then											-- If we go above 1024, max value, need to go down
						genWave <= x"400";
						direction <= '1';
						waveDelay <= x"400";
					end if;
					
				end if;
			else																			-- Going down
				if waveDelay > (x"400" - signed('0' & Wave)) and waveDelay > 0 then		-- count delay
					waveDelay <= waveDelay - ((b"00" & signed(Rate)) + 1);
				else																		-- add delay to wave
					genWave <= waveDelay;
					
					if genWave <= 0 then												-- If we go under 0, min value, need to go up
						genWave <= x"000";
						direction <= '0';
						waveDelay <= x"000";
					end if;

				end if;
			end if;
			
			-- Depth : gain amplitude  -----> waveOut <= genWave * Depth
			waveOut <= genWave * signed('0' & Depth);
			-- TODO : divide wave out by adc res
		end if;
	end process;


MachSeq:process(CLK,RESET)
	begin
		if RESET = '0' then
			tremState <= stateNormal;
			locked <= '0';
			
		elsif rising_edge(CLK) then													
			case tremState is
				when stateNormal =>						
					if SM = '1' and Pedal = '1'  then								-- Selected module = 1 and pedal was activated => Normal operation
						audioOut <= std_logic_vector(calAudio * waveOut);
					else																	   -- Otherwise foward signal
						audioOut <= std_logic_vector(calAudio);
					end if;
					
					if SM = '1' and lock = '1' then							      -- Selected module = '1' and lock = '1' => Lock the module
						-- Save External controls
						savedRate <= Rate;
						savedWave <= Wave;
						savedDepth <= Depth;
						tremState <= stateLocked;
						locked <= '1';
					end if;
					
				when stateLocked =>						
					-- If module is selected or chain effect is activated
					if Pedal = '1' then
			--			audioOut <= std_logic_vector(calAudio * savedWaveOut);
					-- If condition not met, foward signal
					else
						audioOut <= std_logic_vector(calAudio);
					end if;
					
					-- If module is selected and we unlock
					if SM = '1' and lock = '1' then
						locked <= '0';
						tremState <= stateNormal;
					end if;
					
			end case;
		end if;
	end process;


end Behavioral;

