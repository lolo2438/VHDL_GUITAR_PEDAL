-------
-- Made by: Laurent Tremblay
-- Project: Guitar pedal
-- Module: Distortion
-- Description: 
--		This modules apply a tremolo effect to the signal using 3/3 adc parameters
-------
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
			  LM : out STD_LOGIC;
			  LOCK : in STD_LOGIC;
			  
			  -- External control
           Rate  : in  STD_LOGIC_VECTOR (9 downto 0);				-- Frequency of the tremolo
           Wave  : in  STD_LOGIC_VECTOR (9 downto 0);				-- Wave shape of the tremolo
			  Depth : in STD_LOGIC_VECTOR (9 downto 0);				-- Amplitude of the tremolo
			  
			  rateOut : out  STD_LOGIC_VECTOR (9 downto 0);
			  waveOut : out  STD_LOGIC_VECTOR (9 downto 0);
			  depthOut : out  STD_LOGIC_VECTOR (9 downto 0)
			);
end Tremolo;

architecture Behavioral of Tremolo is

COMPONENT Diviseur
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_divisor_tvalid : IN STD_LOGIC;
    s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    s_axis_dividend_tvalid : IN STD_LOGIC;
    s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(55 DOWNTO 0)
  );
END COMPONENT;

-- Signal for audio effect calculation
signal tempVector : STD_LOGIC_VECTOR(35 downto 0);

-- Signals for tremolo wave generation
Signal genWave : signed(11 downto 0) := x"400";
Signal tempWave : signed(11 downto 0) := x"000";
Signal direction : STD_LOGIC := '0';
signal slope : signed(10 downto 0) := (others => '0');
signal shapeScale : signed(10 downto 0) := (others => '0');
signal waveMin : signed(11 downto 0) := (others => '0');
signal newWave : STD_LOGIC := '0';
signal lastNewWave : STD_LOGIC := '0';

--Wave generation clock
Signal WCLK : STD_LOGIC := '0';

Signal compteur : unsigned(14 downto 0) := (others => '0');
Signal TremClkMax: unsigned(31 downto 0) := (others => '0');

-- Signal for divisor
Signal loadToDivisor : STD_LOGIC := '0';
Signal DepthXBpm : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
Signal divisionDone : STD_LOGIC := '0';
Signal dataOutDiviser : STD_LOGIC_VECTOR(55 downto 0) := (others => '0');

signal sRate : unsigned(9 downto 0);
signal sWave : unsigned(9 downto 0);
signal sDepth : signed(9 downto 0);

-- LOCKED
signal savedRate : unsigned(9 downto 0);
signal savedWave : unsigned(9 downto 0);
signal savedDepth: signed(9 downto 0);

signal locked : STD_LOGIC := '0';

begin

rateOut <= std_logic_vector(sRate);
waveOut <= std_logic_vector(sWave);
depthOut <= std_logic_vector(sDepth);

LM <= locked;

-- Main module
Tremolo:
process(CLK)
begin
	if rising_edge(CLK) then																		
		if SM = '1' then
			
			if Pedal = '1'  then								-- Selected module = 1 and pedal was activated => Normal operation
				tempVector <= std_logic_vector(signed(audioIn) * genWave);
			
				audioOut <= tempVector(33 downto 10);
			
			else
				audioOut <= audioIn;
			end if;
			
		else
			audioOut <= audioIn;
		end if;
	end if;
end process;


detectLock:
process(CLK,SM,LOCK)
begin
	if rising_edge(CLK) and SM = '1' and LOCK = '1' then
		locked <= not locked;
		
		savedDepth <= signed(Depth);
		savedRate <= unsigned(Rate);
		savedWave <= unsigned(Wave);
	end if;
end process;

----
-- Detects when a new waveform is generated and loads the user selected settings
----
detectNewWave:
process(CLK)
	begin
		if rising_edge(CLK) then
			if newWave = '1' and lastNewWave = '0' then
				lastNewWave <= newWave;
				loadToDivisor <= '1';
				shapeScale <= slope;
				waveMin <= x"400" - ('0' & sDepth);
				DepthXBpm <= std_logic_vector((('0' & unsigned(sDepth))+ b"1") * b"10" * (('0' & sRate) + x"78"));			-- 120 BPM = x"78"				
			else
				lastNewWave <= '0';
				loadToDivisor <= '0';
				
				if locked = '0' then
					sDepth <= signed(Depth);
					sRate <= unsigned(Rate);
					sWave <= unsigned(Wave);
				elsif locked = '1' then
					sDepth <= savedDepth;
					sRate <= savedRate;
					sWave <= savedWave;
				end if;
				
			end if;
		end if;
end process;

----
-- Tremolo wave clock
----
ClkDiv:
process(CLK,RESET)
begin
	if RESET = '0' then
		compteur <= (others => '0');
	elsif rising_edge(CLK) then
		if compteur < TremClkMax then 						-- 30_000 - ((20*x) + 5k), ,5k = 10hz , 25k = 0,5hz = 0.5hz : 1023 = 10Hz
			compteur <= compteur + 1;
		else
			compteur <= (others => '0');
			WCLK <= not WCLK;
		end if;
	end if;
end process;

----
-- Slope selector ( /\/ -> |¯|_| )
----
WaveSlope:
process(CLK)
begin
	if rising_edge(CLK) then
		if ((to_integer(sWave) >= 0) and (to_integer(sWave) < 93)) then	--1
			slope <= b"00000000001";
			
		elsif ((to_integer(sWave) >= 93) and (to_integer(sWave) < 186)) then	--2
			slope <= b"00000000010";
		
		elsif ((to_integer(sWave) >= 186) and (to_integer(sWave) < 279)) then --4
			slope <= b"00000000100";
		
		elsif ((to_integer(sWave) >= 279) and (to_integer(sWave) < 372)) then --8
			slope <= b"00000001000";
		
		elsif ((to_integer(sWave) >= 372) and (to_integer(sWave) < 465)) then --16
			slope <= b"00000010000";
		
		elsif ((to_integer(sWave) >= 465) and (to_integer(sWave) < 558)) then --32
			slope <= b"00000100000";
		
		elsif ((to_integer(sWave) >= 558) and (to_integer(sWave) < 651)) then --64
			slope <= b"00001000000";
		
		elsif ((to_integer(sWave) >= 651) and (to_integer(sWave) < 744)) then --128
			slope <= b"00010000000";
		
		elsif ((to_integer(sWave) >= 744) and (to_integer(sWave) < 837)) then --256
			slope <= b"00100000000";
			
		elsif ((to_integer(sWave) >= 837) and (to_integer(sWave) < 930)) then --512
			slope <= b"01000000000";
		
		elsif ((to_integer(sWave) >= 930) and (to_integer(sWave) <= 1023)) then --1024
			slope <= b"10000000000";
		
		else
			slope <= b"00000000001";
		end if;
	end if;
end process;


----
-- Tremolo wave generator
----
WaveGen:
process(WCLK,RESET)
	begin
		if RESET = '0' then
			genWave <= x"400";
			direction <= '0';
			tempWave <= x"000";
			
		elsif rising_edge(WCLK) then
				if direction = '0' then  			-- Going up	
					if genWave >= x"400" then			-- if it went above 1024													
						direction <= '1';	
						genWave <= x"400";
						tempWave <= x"001";
						newWave <= '1';
					else
						if tempWave = ('0' & shapeScale) then
							genWave <= genWave + tempWave;
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

----
-- Divisor section
----
detectDivisorDone:
process(CLK)
begin
	if rising_edge(CLK) then
		if divisionDone = '1' then
			TremClkMax <= unsigned(dataOutDiviser(55 downto 24));
		end if;
	end if;
end process;

TREMCLKVALUE: Diviseur
  PORT MAP (
    aclk => CLK,
    aresetn => RESET,
    s_axis_divisor_tvalid => loadToDivisor,
    s_axis_divisor_tdata => DepthXBpm,
    s_axis_dividend_tvalid => loadToDivisor,
    s_axis_dividend_tdata => x"B2D05E00",	--3_000_000_000
    m_axis_dout_tvalid => divisionDone,
    m_axis_dout_tdata => dataOutDiviser
  );

end Behavioral;

