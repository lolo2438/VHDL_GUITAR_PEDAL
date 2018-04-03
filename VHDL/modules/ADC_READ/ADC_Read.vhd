--------------------------------------------
--	Name: Laurent Tremblay
--	Project: Guitar effect processor
--	Module name: ADC_READ
--	Description: This module reads the adc values
-- 			 	 from the avr_interface.
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

Signal sADC0 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal sADC1 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal sADC4 : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');
Signal tempSample : STD_LOGIC_VECTOR(9 downto 0) := (Others => '0');

Signal tempChannel : STD_LOGIC_VECTOR(3 downto 0) := x"0";
Signal lastNewSample : STD_LOGIC := '0';

begin

ADC0 <= sADC0;
ADC1 <= sADC1;
ADC4 <= sADC4;

ADC_Read:process(CLK,RESET)
	begin
		if RESET = '0' then
			sADC0 <= (Others => '0');
			sADC1 <= (Others => '0');
			sADC4 <= (Others => '0');
			
			tempSample <= (others => '0');
			REQUESTED_CHANNEL <= x"0";
			
		elsif rising_edge(CLK) then
			if NEW_SAMPLE = '1' then
				tempSample <= SAMPLE;
				tempChannel <= SAMPLE_CHANNEL;
				
				if tempChannel = b"0000" then
					sADC0 <= tempSample; 
					REQUESTED_CHANNEL <= x"1";
					
				elsif tempChannel = b"0001" then
					sADC1 <= tempSample;
					REQUESTED_CHANNEL <= x"4";
					
				elsif tempChannel = b"0100" then
					sADC4 <= tempSample;
					REQUESTED_CHANNEL <= x"0";
				end if;
				
			end if;
		end if;
	end process;
end Behavioral;

