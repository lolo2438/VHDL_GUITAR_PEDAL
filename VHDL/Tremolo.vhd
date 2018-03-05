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

use IEEE.NUMERIC_STD.ALL;

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
Signal savedRate  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
signal savedSlope : signed(10 downto 0) := (others => '0');
Signal savedDepth : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');

Signal isLocked : STD_LOGIC := '0';

-- Signal for audio effect calculation
signal tempVector : STD_LOGIC_VECTOR(35 downto 0);

Signal sRate : unsigned(9 downto 0);
Signal sWave : unsigned(9 downto 0);
Signal sDepth: STD_LOGIC_VECTOR(9 downto 0);

-- Signals for tremolo wave generation
Signal genWave : signed(11 downto 0) := x"400";
Signal tempWave : signed(11 downto 0) := x"000";
Signal direction : STD_LOGIC := '0';
signal slope : signed(10 downto 0) := (others => '0');
signal shapeScale : signed(10 downto 0) := (others => '0');
signal waveMin : signed(11 downto 0) := (others => '0');
signal newWave : STD_LOGIC;

--Wave generation clock
Signal WCLK : STD_LOGIC := '0';
Signal lastWCLK : STD_LOGIC := '0';

Signal compteur : unsigned(26 downto 0) := (others => '0');
Signal TremClkMax: unsigned(29 downto 0) := (others => '0');

begin

-- Signal assignations
sRate <= unsigned(Rate);
sWave <= unsigned(Wave);
sDepth <= Depth;

Locked <= isLocked;

-- Main sequencial machine
MachSeq:process(CLK,RESET)
begin
	if RESET = '0' then
		tremState <= stateNormal;
		islocked <= '0';
		
	elsif rising_edge(CLK) then													
		case tremState is
			when stateNormal =>						
				if SM = '1' and Pedal = '1'  then								-- Selected module = 1 and pedal was activated => Normal operation
					tempVector <= std_logic_vector(signed(audioIn) * genWave);
					
					audioOut <= tempVector(33 downto 10);
					
				else
					audioOut <= audioIn;
				end if;
				
				if SM = '1' and lock = '1' then							      -- Selected module = '1' and lock = '1' => Lock the module
					-- Save External controls
					savedRate <= Rate;
					savedSlope <= slope;
					savedDepth <= Depth;
					tremState <= stateLocked;
					islocked <= '1';
				end if;
				
			when stateLocked =>						
				-- If module is selected or chain effect is activated
				if Pedal = '1' then
					tempVector <= std_logic_vector(signed(audioIn) * genWave);
					audioOut <= tempVector(33 downto 10);
				else
					audioOut <= audioIn;
				end if;
				
				-- If module is selected and we unlock
				if SM = '1' and lock = '1' then
					islocked <= '0';
					tremState <= stateNormal;
				end if;
				
		end case;
	end if;
end process;


-- Tremolo clock
ClkDiv:process(CLK,RESET)
begin
	if RESET = '0' then
		compteur <= (others => '0');
	elsif rising_edge(CLK) then
		if compteur < TremClkMax then 						-- 100_000_000 - (92773 * (0 � 1023)) -> 0 = 0.5hz : 1023 = 10Hz
			compteur <= compteur + 1;
		else
			compteur <= (others => '0');
			WCLK <= not WCLK;
		end if;
	end if;
end process;


-- Slope selector ( /\/ -> |�|_| )
WaveSlope:process(CLK)
begin
	if rising_edge(CLK) then
		if ((sWave >= 0) and (sWave < 93)) then	--1
			slope <= b"00000000001";
			
		elsif ((sWave >= 93) and (sWave < 186)) then	--2
			slope <= b"00000000010";
		
		elsif ((sWave >= 186) and (sWave < 279)) then --4
			slope <= b"00000000100";
		
		elsif ((sWave >= 279) and (sWave < 372)) then --8
			slope <= b"00000001000";
		
		elsif ((sWave >= 372) and (sWave < 465)) then --16
			slope <= b"00000010000";
		
		elsif ((sWave >= 465) and (sWave < 558)) then --32
			slope <= b"00000100000";
		
		elsif ((sWave >= 558) and (sWave < 651)) then --64
			slope <= b"00001000000";
		
		elsif ((sWave >= 651) and (sWave < 744)) then --128
			slope <= b"00010000000";
		
		elsif ((sWave >= 744) and (sWave < 837)) then --256
			slope <= b"00100000000";
			
		elsif ((sWave >= 837) and (sWave < 930)) then --512
			slope <= b"01000000000";
		
		elsif ((sWave >= 930) and (sWave <= 1023)) then --1024
			slope <= b"10000000000";
		
		else
			slope <= b"00000000001";
		end if;
	end if;
end process;


-- Detects when a new waveform is generated and loads the user selected settings
detectNewWave:process(CLK)
	begin
		if rising_edge(CLK) then
			if newWave = '1' then
				
				if isLocked <= '0' then
					TremClkMax <= (b"00" & x"5F5E100") - (x"16A75" * sRate);
					shapeScale <= slope;
					waveMin <= x"400" - signed(b"00" & sDepth);
				
				elsif isLocked <= '1' then
					TremClkMax <= (b"00" & x"5F5E100") - (x"16A75" * unsigned(savedRate));
					shapeScale <= savedSlope;
					waveMin <= x"400" - signed(b"00" & savedDepth);
				end if;
			end if;
		end if;
	end process;


-- Wave generator
WaveGen:process(CLK,RESET)
	begin
		if RESET = '0' then
			genWave <= x"400";
			direction <= '0';
			tempWave <= x"000";
			direction <= '0';
			
		elsif rising_edge(CLK) then
				if direction = '0' then  			-- Going up	
					if genWave >= x"400" then			-- if it went above 1024														
						direction <= '1';	
						genWave <= x"400";
						tempWave <= x"001";
						newWave <= '1';
					else
						if tempWave = ('0' & shapeScale) then
							genWave <= genWave + tempWave ;
							tempWave <= x"000";
						else
							tempWave <= tempWave + 1;
						end if;
					end if;
						
				elsif direction = '1' then				-- Going down
					newWave <= '0';
					
					if genWave <= waveMin then		-- if it went under minimum of the waveform (depth)									
						direction <= '0';
						genWave <= waveMin;
						tempWave <= x"001";
					else
						if tempWave = ('0' & shapeScale) then
							genWave <= genWave - tempWave;
							tempWave <= x"000";
						else
							tempWave <= tempWave + 1;
						end if;
					end if;
				end if;
		end if;
end process;

-- note: si �a marche pas => ISE trim waveMin(11)


end Behavioral;

