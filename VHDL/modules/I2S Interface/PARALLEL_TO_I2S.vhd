-------------------------------------
--	Name: Laurent Tremblay			  --
--	Project: Numeric guitar pedal	  --
--	Module: parallelToI2S			  --
-- Version:	1.0						  --
-- Comments: Designed for the 	  --
--	Akashi AK4556 audio Codec       --
-------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PARALLEL_TO_I2S is
	 Generic ( DATA_WIDTH : integer range 16 to 32 := 24);
	 
    Port ( -- I2S PORTS
			  BCLK : in  STD_LOGIC;
           LRCK : in  STD_LOGIC;
			  SDTO : out  STD_LOGIC;
			  
			  -- PARALLEL DATA TO DAC
			  DATA_DAC_L : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           DATA_DAC_R : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
			  
			  -- OTHERS
			  RESET : in STD_LOGIC;
           DONE : out  STD_LOGIC);
			  
end PARALLEL_TO_I2S;

architecture Behavioral of PARALLEL_TO_I2S is

Type i2s_Tx is (Tx, Waiting);
Signal i2sTx : i2s_Tx := Waiting;

Signal shiftRegOutL : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
Signal shiftRegOutR: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');

Signal lastLRCK : STD_LOGIC := '0';
Signal LRCK_Flag : STD_LOGIC := '0';
Signal LRCK_Changed : STD_LOGIC := '0';

begin

shiftRegOutL <= DATA_DAC_L;
shiftRegOutR <= DATA_DAC_R;

-- Detecting changes in LRCK
detectLRCK: process(BCLK)
	begin
		if rising_edge(BCLK) then
			if(lastLRCK /= LRCK) then
				lastLRCK <= LRCK;
				LRCK_Flag <= '1';
			else
				LRCK_Flag <= '0';
			end if;
		end if;
	end process;
	
-- Cross process signal
LRCK_Changed <= LRCK_Flag;

-- TRANSMIT
Transmit:process(RESET,BCLK)
	variable dataShift : integer range 0 to DATA_WIDTH := DATA_WIDTH;
	begin
		if (RESET = '0') then
			dataShift := DATA_WIDTH;
			SDTO <= '0';
		elsif falling_edge(BCLK) then
			case i2sTx is
				when Tx =>
					dataShift := dataShift - 1;
					
					if LRCK = '1' then
						SDTO <= shiftRegOutR(dataShift);
					elsif LRCK = '0' then
						SDTO <= shiftRegOutL(dataShift);
					end if;
					
					if dataShift = 0 then
						i2sTx <= Waiting;
					end if;
					
				when Waiting =>
					DONE <= '1';
					dataShift := DATA_WIDTH;
					SDTO <= '0';
					
					if LRCK_CHANGED = '1' then
						DONE <= '0';
						-- Send first bit
						dataShift := dataShift - 1;
						
						if LRCK = '1' then
							SDTO <= shiftRegOutR(dataShift);
						elsif LRCK = '0' then
							SDTO <= shiftRegOutL(dataShift);
						end if;
						
						i2sTx <= Tx;
						
					end if;
				end case;
		end if;
	end process;
end Behavioral;

