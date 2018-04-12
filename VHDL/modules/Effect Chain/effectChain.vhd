--------------------------------------------
--	Name: Laurent Tremblay
--	Project: Guitar effect processor
--	Module name: effectChain
--	Description: This module povides an interface
--					 for the guitar effects.
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

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
			  LOCKED : out STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- Selected module
			  SM : out STD_LOGIC_VECTOR(7 downto 0);
			  
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

Signal selectModule : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
Signal effectSelector: unsigned(2 downto 0) := (others => '0');

-- AUDIO SIGNAL
signal audioOutBuffer : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
signal audioOutDistortion : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
signal audioOutTremolo: STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
signal audioOutVolume : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin

SM <= selectModule;

-- Select Module
ChooseEffect:process(RESET,CLK)
	begin
		if RESET = '0' then
			effectSelector <= (others => '0');
		
		elsif rising_edge(CLK) then
			if NEXT_EFFECT = '1' and LAST_EFFECT = '0' then
				effectSelector <= effectSelector + 1;
			elsif LAST_EFFECT = '1' and NEXT_EFFECT = '0' then
				effectSelector <= effectSelector - 1;
			end if;
		end if;
	end process;

with effectSelector select
	selectModule <= b"00000001" when b"000",
						 b"00000010" when b"001",
						 b"00000100" when b"010",
						 b"00001000" when b"011",
						 b"00010000" when b"100",
						 b"00100000" when b"101",
						 b"01000000" when b"110",
						 b"10000000" when b"111",
						 b"00000000" when others;


--PortMap
BufferIn: entity work.Buffer_In(Behavioral)
port map( CLK => CLK,
			 audioIn => AUDIO_IN,
			 audioOut => audioOutBuffer,
			 dataReady => READY
			);

Distortion: entity work.Distortion(Behavioral)
port map(  -- System Clock (50 MHz)
			  CLK => CLK,
			  
			  -- System global reset
			  RESET => RESET,											-- logical '0' indicates us that reset button was pressed
			  
			  -- Audio signals
			  audioIn => audioOutBuffer,
           audioOut => audioOutDistortion,
			  
			  -- Select Module
			  Pedal => PEDAL,											-- Constant '1' indicates that pedal is activated
           SM => selectModule(0),												-- Constant '1' indicates us that module is selected	
			  
			  -- Lock Module
           lock => LOCK,											-- goes high for 1 clock cycle, when detected switch between locked and normal mode
			  locked => LOCKED(0),										-- indicated that the module is locked
			  
			  -- External control
           Dist => ADC0,				-- Ammount of distortion 	  -> Gain of the pre-cut signal
           Tone => ADC1,				-- Tone of the signal		  -> Filtre passe bas
			  Level => ADC4				-- Ammount of gain of volume -> gain of the post-processed signal
			 );

Tremolo: entity work.Tremolo(Behavioral)
port map(-- System Clock (50 MHz)
			  CLK => CLK,
			  
			  -- System global reset
			  RESET => RESET,										-- logical '0' indicates us that reset button was pressed
			  
			  -- Audio signals
			  audioIn => audioOutDistortion,
           audioOut => audioOutTremolo,
			  
			  -- Select Module
			  Pedal => PEDAL,										-- Constant '1' indicates that pedal is activated
           SM => selectModule(1),											-- Constant '1' indicates us that module is selected	
			  
			  -- Lock Module
           lock => LOCK,											-- goes high for 1 clock cycle, when detected switch between locked and normal mode
			  locked => LOCKED(1),									-- indicated that the module is locked
			  
			  -- External control
           Rate  => ADC0,
           Wave  => ADC1,		
			  Depth => ADC4
			);

Volume: entity work.volumeControl(Behavioral)
port map( CLK => CLK,
			 RESET => RESET,
			 audioIn => audioOutTremolo,
          audioOut => audioOutVolume,
			 Pedal => PEDAL,
          SM => selectModule(2), 
          lock => LOCK,					
			 locked => LOCKED(2),
          TBD1 => ADC0,
          vol => ADC1,							
			 TBD2 => ADC4
			);

BufferOut: entity work.Buffer_Out(Behavioral)
port map( CLK => CLK,
			 audioIn => audioOutVolume,
			 audioOut => AUDIO_OUT,
			 done => DONE
			);
end Behavioral;

