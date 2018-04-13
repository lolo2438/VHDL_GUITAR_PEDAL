--------------------------------------------
--	Name: Laurent Tremblay
--	Project: Guitar effect processor
--	Module name: ADC_READ
--	Description: This module reads the adc values
-- 			 	 from the avr_interface.
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.all;

entity ADC_Read is
    Port ( -- FPGA CLOCK
			  CLK : in  STD_LOGIC;
			  
			  -- RESET
			  RESET : in STD_LOGIC;
			  
			  -- From AVR Interface
			  NEW_SAMPLE : in STD_LOGIC;
			  SAMPLE : in STD_LOGIC_VECTOR(9 downto 0);
			  SAMPLE_CHANNEL : in STD_LOGIC_VECTOR (3 downto 0);
			  
			  -- To AVR Interface
           REQUESTED_CHANNEL : out  STD_LOGIC_VECTOR(3 downto 0);
			  
			  -- To guitar effect
			  ADC0 : out STD_LOGIC_VECTOR(9 downto 0);
			  ADC1 : out STD_LOGIC_VECTOR(9 downto 0);
			  ADC4 : out STD_LOGIC_VECTOR(9 downto 0)
			 );
end ADC_Read;

architecture Behavioral of ADC_Read is

Type readAdc is (waitData, asignData);
Signal stateADCRead : readAdc := waitData;

Signal sADC0 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal sADC1 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal sADC4 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal tempSample : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');

signal testAdc0 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
signal testAdc1 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
signal testAdc4 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');

Signal lastSampleAdc0 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal lastSampleAdc1 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal lastSampleAdc4 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');

Signal tempChannel : STD_LOGIC_VECTOR(3 downto 0) := x"0";
Signal lastNewSample : STD_LOGIC := '0';

Signal compteur : unsigned(15 downto 0);

begin

ADC0 <= sADC0;
ADC1 <= sADC1;
ADC4 <= sADC4;

-- Problem found: ADC seem to share values
--
--	possible fix: sample the ADC at a channel X and wait for when samples have stabilised
--
--
-- 
ADC_Read:process(CLK,RESET)
	begin
		if RESET = '0' then
					
			tempSample <= (others => '0');
			REQUESTED_CHANNEL <= x"0";
			
		elsif rising_edge(CLK) then
			case stateAdcRead is
				when waitData =>
					if NEW_SAMPLE = '1' and lastNewSample = '0' then
						lastNewSample <= NEW_SAMPLE;
						stateAdcRead <= asignData;
					elsif NEW_SAMPLE = '0' and lastNewSample = '1' then
						lastNewSample <= NEW_SAMPLE;
					end if;
				
				when asignData =>
					if SAMPLE_CHANNEL = b"0000" then
					--	lastSampleAdc0 <= testAdc0;
						sADC0 <= SAMPLE;
						REQUESTED_CHANNEL <= x"1";
						
					elsif SAMPLE_CHANNEL = b"0001" then
						--lastSampleAdc1 <= testAdc1;
						sAdc1 <= SAMPLE;
						REQUESTED_CHANNEL <= x"4";
						
					elsif SAMPLE_CHANNEL = b"0100" then
						--lastSampleAdc4 <= testAdc4;
						sAdc4 <= SAMPLE;
						REQUESTED_CHANNEL <= x"0";
					end if;
					
					stateAdcRead <= waitData;
			end case;
		end if;
	end process;

end Behavioral;

