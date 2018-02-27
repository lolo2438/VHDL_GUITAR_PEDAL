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
           Rate  : in  STD_LOGIC_VECTOR (9 downto 0);				-- Frequency of the tremolo
           Wave  : in  STD_LOGIC_VECTOR (9 downto 0);				-- Wave shape of the tremolo
			  Depth : in STD_LOGIC_VECTOR (9 downto 0)				-- Amplitude of the tremolo
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

-- Signal for audio effect calculation
Signal calAudioIn : SIGNED(23 downto 0) := (others => '0');
Signal calAudioOut : SIGNED(33 downto 0) := (others => '0');

-- Signals for tremolo wave generation
Signal genWave : unsigned(10 downto 0) := (others => '0');
Signal waveOut : signed(22 downto 0) := (others => '0');
Signal direction : STD_LOGIC := '0';

Signal sRate : unsigned(9 downto 0);
Signal sWave : unsigned(9 downto 0);
Signal sDepth: signed(10 downto 0);

signal prescaler : unsigned(10 downto 0);
signal lastPrescaler : unsigned(10 downto 0);

--Wave generation clock
Signal WCLK : STD_LOGIC := '0';
Signal compteur : unsigned(26 downto 0) := (others => '0');

begin

-- Signal assignations

sRate <= unsigned(Rate);
sWave <= unsigned(Wave);
sDepth <= signed('0' & Depth);

calAudioIn <= signed(audioIn);

prescaler <= b"00000000001" when sWave >= 0 and sWave < 93 else	--1
				 b"00000000010" when sWave >= 93 and sWave < 186 else	--2
				 b"00000000100" when sWave >= 186 and sWave < 279 else	--4
				 b"00000001000" when sWave >= 279 and sWave < 372 else	--8
				 b"00000010000" when sWave >= 372 and sWave < 465 else	--16
				 b"00000100000" when sWave >= 465 and sWave < 558 else	--32
				 b"00001000000" when sWave >= 558 and sWave < 651 else	--64
				 b"00010000000" when sWave >= 651 and sWave < 744 else	--128
				 b"00100000000" when sWave >= 744 and sWave < 837 else	--256
				 b"01000000000" when sWave >= 837 and sWave < 930 else	--512
				 b"10000000000" when sWave >= 930 and sWave <= 1023 else	--1024
				 b"00000000000";


-- Tremolo clock
ClkDiv:process(CLK,RESET)
	begin
		if RESET = '0' then
			compteur <= (others => '0');
		elsif rising_edge(CLK) then
			if compteur < (b"00" & x"5F5E100") - (x"16A75" * sRate)   then 						-- 100_000_000 - (92773 * (0 à 1023)) -> 0 = 0.5hz : 1023 = 10Hz
				compteur <= compteur + 1;
			else
				compteur <= (others => '0');
				WCLK <= not WCLK;
			end if;
		end if;
	end process;


-- Triangle and square wave generator
WaveGen:process(WCLK,RESET)
	begin
		if RESET = '0' then
			genWave <= (others => '0');
			direction <= '0';
			
		elsif rising_edge(WCLK) then
			
			-- Safety if we change prescaler whilst generating the wave
			if prescaler /= lastPrescaler then
				direction <= '0';
				genWave <= (others => '0');
				lastPrescaler <= prescaler;
			end if;
			
			
			if direction = '0' then  											-- Going up													
				genWave <= genWave + prescaler;
				
				if genWave = 1024 then														
					direction <= '1';
				end if;
					
			else																		-- Going down
				genWave <= genWave - prescaler;
	
				if genWave = 0 then												-- If we go under 0, min value, need to go up
					direction <= '0';		
				end if;
			end if;
						
		end if;
	end process;

-- Depth : gain amplitude  -----> waveOut <= genWave * Depth 
waveOut <= signed('0' & genWave) * sDepth;

-- Main sequencial machine
MachSeq:process(CLK,RESET)
	begin
		if RESET = '0' then
			tremState <= stateNormal;
			locked <= '0';
			
		elsif rising_edge(CLK) then													
			case tremState is
				when stateNormal =>						
					if SM = '1' and Pedal = '1'  then								-- Selected module = 1 and pedal was activated => Normal operation
						calAudioOut <= calAudioIn * waveOut(19 downto 10);
						audioOut <= std_logic_vector(calAudioOut(23 downto 0));
					else																	   -- Otherwise foward signal
						audioOut <= std_logic_vector(calAudioIn(23 downto 0));
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
					--	audioOut <= std_logic_vector(calAudio * savedWaveOut);

					else
						audioOut <= std_logic_vector(calAudioIn(23 downto 0));
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

