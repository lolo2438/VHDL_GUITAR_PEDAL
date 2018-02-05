-------------------------------------
--	Name: Laurent Tremblay			  --
--	Project: Numeric guitar pedal	  --
--	Module: I2S_INTERFACE			  --
-- Version:	1.0						  --
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

entity I2S_TO_PARALLEL is
	 Generic ( DATA_WIDTH : integer range 16 to 32 := 24);
	 
    Port ( -- I2S PORTS
			  SDTI : in  STD_LOGIC;
			  BCLK : in  STD_LOGIC;
           LRCK : in  STD_LOGIC;
			  SDTO : out  STD_LOGIC;
			  
			  -- PARALLEL DATA FROM ADC
           DATA_ADC_L : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           DATA_ADC_R : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
			  
			  -- PARALLEL DATA TO DAC
			  DATA_DAC_L : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           DATA_DAC_R : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
			  
			  -- OTHERS
			  RESET : in STD_LOGIC;
           DATA_READY : out  STD_LOGIC);
			  
end I2S_TO_PARALLEL;

architecture Behavioral of I2S_TO_PARALLEL is

Signal Shift_Reg_In: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
Signal Shift_Reg_Out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := (others => '0');
Signal Current_LRCK_In : STD_LOGIC := '0';
Signal Current_LRCK_Out : STD_LOGIC := '0';
begin

Data_Handler:process(RESET,BCLK)
	variable Data_Shift_Counter_In : integer range 0 to DATA_WIDTH := DATA_WIDTH;
	variable Data_Shift_Counter_Out : integer range 0 to DATA_WIDTH := DATA_WIDTH;
	begin
		if(RESET = '0') then
			-- Reset everything when received a logical '0', asynchronous
			DATA_ADC_L <= (others => '0');
         DATA_ADC_R <= (others => '0');
			Data_Shift_Counter_In := DATA_WIDTH;
			Data_Shift_Counter_Out := DATA_WIDTH;
			Shift_Reg_Out <= (others => '0');
			Shift_Reg_In <= (others => '0');
			DATA_READY <= '0';
		
		elsif falling_edge(BCLK) then  -- Sending Data
			if(LRCK /= Current_LRCK_Out) then
				Current_LRCK_Out <= LRCK;
				if LRCK = '0' then
					Shift_Reg_Out <= DATA_DAC_L;
				elsif LRCK = '1' then
					Shift_Reg_Out <= DATA_DAC_R;
				end if;
			elsif Data_Shift_Counter_Out > 0 then
				-- Sending data from buffer to CODEC
				SDTO <= Shift_Reg_Out(Data_Shift_Counter_Out-1);
				-- Decrementing counter
				Data_Shift_Counter_Out := Data_Shift_Counter_Out - 1;
			elsif Data_Shift_Counter_Out = 0 then
				SDTO <= '0';
			end if;
			
		elsif rising_edge(BCLK) then 	 -- Receiving data
			-- Discard the first Bit, prepare for SDTI and set up SDTO
			if(LRCK /= Current_LRCK_In) then
				Current_LRCK_In <= LRCK;
				Data_Shift_Counter_In := DATA_WIDTH;
				Shift_Reg_In <= (others => '0');
				DATA_READY <= '0';
			elsif Data_Shift_Counter_In > 0 then -- 24 downto 1 => 24 bits (23 downto 0)
				-- Reading data from codec
				Shift_Reg_In(Data_Shift_Counter_In) <= SDTI;
				-- Decrementing counter
				Data_Shift_Counter_In := Data_Shift_Counter_In - 1;
				
			elsif Data_Shift_Counter_In = 0 then
				-- All input bits have been put in the Shift register and all output bits have been outputted
				DATA_READY <= '1';
				-- Selects which channel should receive the bits depending on LRCK
					if Current_LRCK_In = '0' then
						DATA_ADC_L <= Shift_Reg_In;
					elsif Current_LRCK_In = '1' then
						DATA_ADC_R <= Shift_Reg_In;
					end if;
			
			end if;
		end if;
	end process;
end Behavioral;

