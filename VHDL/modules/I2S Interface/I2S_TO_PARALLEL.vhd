-------------------------------------
--	Name: Laurent Tremblay			  --
--	Project: Numeric guitar pedal	  --
--	Module: I2SToParallel			  --
-- Version:	1.0						  --
-- Comments: Designed for the 	  --
--	Akashi AK4556 audio Codec       --
-------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2S_TO_PARALLEL is
	 Generic ( DATA_WIDTH : integer range 16 to 32 := 24);
	 
    Port ( -- FPGA CLOCK
			  CLK : in STD_LOGIC;
			  
			  -- I2S PORTS
			  SDTI : in STD_LOGIC;
			  BCLK : in  STD_LOGIC;
           LRCK : in  STD_LOGIC;
			  
			  -- PARALLEL DATA FROM ADC
           DATA_ADC_L : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           DATA_ADC_R : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
			  
			  -- OTHERS
			  RESET : in STD_LOGIC;
           DATA_READY : out  STD_LOGIC);
			  
end I2S_TO_PARALLEL;

architecture Behavioral of I2S_TO_PARALLEL is

Type i2s_Rx is (Rx, Rdy, Waiting);

Signal i2sRx : i2s_Rx := Waiting;

Signal shiftRegIn: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
Signal lastLRCK : STD_LOGIC := '0';
Signal dataReady : STD_LOGIC := '0';
Signal lastDataReady : STD_LOGIC := '0';

begin

-- RECEIVE
Receive:process(RESET,BCLK)
	variable dataShift : integer range 0 to DATA_WIDTH := DATA_WIDTH;
	begin
		if (RESET = '0') then
			dataShift := DATA_WIDTH;
			shiftRegIn <= (others => '0');
			dataReady <= '0';
			
		elsif rising_edge(BCLK) then
			case i2sRx is				
				when Rx =>
					dataShift := dataShift - 1;
					shiftRegIn(dataShift) <= SDTI;
										
					if dataShift = 0 then
						i2sRx <= Rdy;
					end if;
				
				when Rdy =>
					if LRCK = '0' then
						DATA_ADC_L <= shiftRegIn;
					elsif LRCK = '1' then
						DATA_ADC_R <= shiftRegIn;
					end if;
					
					dataReady <= '1';
					i2sRx <= Waiting;
				
				when Waiting =>
					if(lastLRCK /= LRCK) then
						lastLRCK <= LRCK;
						
						dataShift := DATA_WIDTH;
						shiftRegIn <= (others => '0');
						
						dataReady <= '0';
						
						i2sRx <= Rx;
					end if;
			end case;
		end if;
	end process;
	
DetectDataRdy: process(CLK,RESET)
	begin
		if RESET = '0' then
			lastDataReady <= '0';
		elsif rising_edge(CLK) then
			if dataReady = '1' and lastDataReady = '0' then
				DATA_READY <= '1';
			else
				DATA_READY <= '0';
			end if;
		end if;
	end process;
	
end Behavioral;

