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
Signal calAudioOut : SIGNED(47 downto 0) := (others => '0');

-- Signals for tremolo wave generation
Signal genWave : integer := 1;
Signal waveOut : signed(11 downto 0) := (others => '0');
Signal direction : STD_LOGIC := '0';

Signal sRate : unsigned(9 downto 0);
Signal sWave : unsigned(9 downto 0);
Signal sDepth: unsigned(9 downto 0);

signal prescaler : integer range 1 to 1024 := 1;
signal postScaler : integer range 0 to 10 := 0;

--Wave generation clock
Signal WCLK : STD_LOGIC := '0';
Signal compteur : unsigned(26 downto 0) := (others => '0');
Signal TremClkMax: unsigned(29 downto 0) := (others => '0');

begin

-- Signal assignations

sRate <= unsigned(Rate);
sWave <= unsigned(Wave);
sDepth <= unsigned(Depth);

calAudioIn <= signed(audioIn);

TremClkMax <= (b"00" & x"5F5E100") - (x"16A75" * sRate);

Choose_prescale:process(CLK)
	begin
		if rising_edge(CLK) then
			if ((sWave >= 0) and (sWave < 93)) then	--1
				prescaler <= 1;
				
			elsif ((sWave >= 93) and (sWave < 186)) then	--2
				prescaler <= 2;
			
			elsif ((sWave >= 186) and (sWave < 279)) then --4
				prescaler <= 4;
			
			elsif ((sWave >= 279) and (sWave < 372)) then --8
				prescaler <= 8;
			
			elsif ((sWave >= 372) and (sWave < 465)) then --16
				prescaler <= 16;
			
			elsif ((sWave >= 465) and (sWave < 558)) then --32
				prescaler <= 31;
			
			elsif ((sWave >= 558) and (sWave < 651)) then --64
				prescaler <=  64;
			
			elsif ((sWave >= 651) and (sWave < 744)) then --128
				prescaler <=  128;
			
			elsif ((sWave >= 744) and (sWave < 837)) then --256
				prescaler <= 256;
				
			elsif ((sWave >= 837) and (sWave < 930)) then --512
				prescaler <=  512;
			
			elsif ((sWave >= 930) and (sWave <= 1023)) then --1024
				prescaler <=  1024;
			
			else
				prescaler <=  1;
			end if;
		end if;
	end process;

Choose_postScaler:process(CLK)
	begin
		if rising_edge(CLK) then
			if ((sDepth >= 0) and (sDepth < 93)) then	--1
				postscaler <= 1;
				
			elsif ((sDepth >= 93) and (sDepth < 186)) then	--2
				postscaler <= 1;
			
			elsif ((sDepth >= 186) and (sDepth < 279)) then --4
				postscaler <= 2;
			
			elsif ((sDepth >= 279) and (sDepth < 372)) then --8
				postscaler <= 3;
			
			elsif ((sDepth >= 372) and (sDepth < 465)) then --16
				postscaler <= 4;
			
			elsif ((sDepth >= 465) and (sDepth < 558)) then --32
				postscaler <= 5;
			
			elsif ((sDepth >= 558) and (sDepth < 651)) then --64
				postscaler <=  6;
			
			elsif ((sDepth >= 651) and (sDepth < 744)) then --128
				postscaler <=  7;
			
			elsif ((sDepth >= 744) and (sDepth < 837)) then --256
				postscaler <=  8;
				
			elsif ((sDepth >= 837) and (sDepth < 930)) then --512
				postscaler <=  9;
			
			elsif ((sDepth >= 930) and (sDepth <= 1023)) then --1024
				postscaler <=  10;
			
			else
				postscaler <= 0;
			end if;
		end if;
	end process;
	
-- Tremolo clock
ClkDiv:process(CLK,RESET)
	begin
		if RESET = '0' then
			compteur <= (others => '0');
		elsif rising_edge(CLK) then
			if compteur < TremClkMax then 						-- 100_000_000 - (92773 * (0 à 1023)) -> 0 = 0.5hz : 1023 = 10Hz
				compteur <= compteur + 1;
			else
				compteur <= (others => '0');
				WCLK <= not WCLK;
			end if;
		end if;
	end process;


-- Triangle and square wave generator
WaveGen:process(CLK,RESET)
	begin
		if RESET = '0' then
			genWave <= 1;
			direction <= '0';
			
		elsif rising_edge(CLK) then
			if direction = '0' then  											-- Going up													
				genWave <= genWave + prescaler;
				
				if genWave >= 1024 then														
					direction <= '1';
					genWave <= 1024;
				end if;
					
			elsif direction = '1' then																		-- Going down
				genWave <= genWave - prescaler;
	
				if genWave <= 1 then												
					direction <= '0';
					genWave <= 1;
				end if;
			end if;
						
		end if;
	end process;

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
						calAudioOut <= (calAudioIn * genWave);
						
						audioOut <= std_logic_vector(calAudioOut(33 downto 10));
						
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

