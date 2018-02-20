----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:20:38 02/19/2018 
-- Design Name: 
-- Module Name:    ADC_Read - Behavioral 
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
			  
			  --test led
			  LED : out STD_LOGIC;
			  
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

Signal requestedChannel : STD_LOGIC_VECTOR(3 downto 0) := x"0";
Signal tempChannel : STD_LOGIC_VECTOR(3 downto 0) := x"0";
Signal lastNewSample : STD_LOGIC := '0';
begin

ADC0 <= sADC0;
ADC1 <= sADC1;
ADC4 <= sADC4;
REQUESTED_CHANNEL <= requestedChannel;

ADC_Read:process(CLK,RESET)
	begin
		if RESET = '0' then
			sADC0 <= (Others => '0');
			sADC1 <= (Others => '0');
			sADC4 <= (Others => '0');
			
			tempSample <= (others => '0');
			tempChannel <= x"0";
			requestedChannel <= x"0";
			
		elsif rising_edge(CLK) then
			if NEW_SAMPLE = '1' then
				tempSample <= SAMPLE;
				tempChannel <= SAMPLE_CHANNEL;
			else
				if tempChannel = x"0" then
					sADC0 <= tempSample; 
					requestedChannel <= x"1";
					LED <= tempSample(5);
					
				elsif tempChannel = x"1" then
					sADC1 <= tempSample;
					requestedChannel <= x"4";
					
				elsif tempChannel = x"4" then
					sADC4 <= tempSample;
					requestedChannel <= x"0";
				end if;
			end if;
		end if;
	end process;
end Behavioral;

