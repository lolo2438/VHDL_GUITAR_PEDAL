-------------------------------------
--	Name: Laurent Tremblay			  --
--	Project: Numeric guitar pedal	  --
--	Module: I2S_INTERFACE			  --
-- Version:	4.0						  --
-- Comments: Designed for the 	  --
--	Akashi AK4556 audio Codec       --
-------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
           DATA_READY : out  STD_LOGIC);
			  
end PARALLEL_TO_I2S;

architecture Behavioral of PARALLEL_TO_I2S is

Type i2s_Tx is (Tx, Waiting);

Signal i2sTx : i2s_Tx := Waiting;

Signal shiftRegOut: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
Signal lastLRCK : STD_LOGIC := '0';


begin

-- TRANSMIT
Transmit:process(RESET,BCLK)
	variable dataShift : integer range 0 to DATA_WIDTH := DATA_WIDTH;
	begin
		if (RESET = '0') then
			dataShift := DATA_WIDTH;
			shiftRegOut <= (others => '0');
			SDTO <= '0';
			
		elsif falling_edge(BCLK) then
			case i2sTx is
				when Tx =>
					dataShift := dataShift - 1;
					SDTO <= shiftRegOut(dataShift);
					
					if dataShift = 0 then
						i2sTx <= Waiting;
					end if;
						
				when Waiting =>
					SDTO <= '0';
					if(lastLRCK /= LRCK) then									-- Change in LRCK indicates new data
						lastLRCK <= LRCK;
						
						dataShift := DATA_WIDTH;
						if LRCK = '0' then
							shiftRegOut <= DATA_DAC_L;
						elsif LRCK = '1' then
							shiftRegOut <= DATA_DAC_R;
						end if;
						
						i2sTx <= Tx;
					end if;
			end case;
		end if;
	end process;
end Behavioral;

