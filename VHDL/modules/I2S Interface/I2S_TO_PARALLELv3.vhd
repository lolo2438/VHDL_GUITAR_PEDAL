-------------------------------------
--	Name: Laurent Tremblay			  --
--	Project: Numeric guitar pedal	  --
--	Module: I2S_INTERFACE			  --
-- Version:	3.0						  --
-- Comments: Designed for the 	  --
--	Akashi AK4556 audio Codec       --
-------------------------------------

-- NOTE TO SELF: Test bench -> on dirait que le premier 24 bit perd le premier bit, mais le reste semble fonctionné comme prévu, à tester en lab

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
Signal Selected_Channel : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
Signal Data_Shift : integer range 0 to DATA_WIDTH := DATA_WIDTH;
Signal Current_LRCK : STD_LOGIC := '0';
Signal Start : STD_LOGIC := '0';


begin

Data_Shifter:process(RESET,BCLK)
	begin
		if(RESET = '0') then
			Data_Shift <= DATA_WIDTH;
			DATA_READY <= '0';
			Start <= '0';
		elsif falling_edge(BCLK) then
			-- Discard 1st bit and Sync on LRCK
			if(LRCK /= Current_LRCK) then
				Current_LRCK <= LRCK;
				Data_Shift <= DATA_WIDTH;
				Start <= '1';
			elsif Data_Shift > 0 then 
				Data_Shift <= Data_Shift - 1;
			elsif Data_Shift = 0 then
				DATA_READY <= '1';
				Start <= '0';
			end if;
		end if;
	end process;


audioRX:process(RESET,BCLK,SDTI)
	begin
		if(RESET = '0') then
			-- Reset everything when received a logical '0', asynchronous
			DATA_ADC_L <= (others => '0');
         DATA_ADC_R <= (others => '0');		
			Shift_Reg_In <= (others => '0');
		elsif rising_edge(BCLK) then
			if Start = '1' and Data_Shift < DATA_WIDTH then
				Shift_Reg_In(Data_Shift) <= SDTI;
				
			elsif Start = '0' then			
				if LRCK = '0' then
					DATA_ADC_L <= Shift_Reg_In;
				elsif LRCK = '1' then
					DATA_ADC_R <= Shift_Reg_In;
				end if;
			end if;
		end if;
	end process;
	
audioTX:process(RESET,BCLK)
	begin
		if(RESET = '0') then
			-- Reset everything when received a logical '0', asynchronous
			Shift_Reg_Out <= (others => '0');
		elsif falling_edge(BCLK) then
			if Start = '1' and Data_Shift > 0 then	
			-- Sending data from buffer to CODEC
				SDTO <= Shift_Reg_Out(Data_Shift-1);
			elsif Data_Shift = 0 then
				SDTO <= '0';
				Shift_Reg_Out <= Selected_Channel;
			end if;
		end if;
	end process;

process(LRCK)
	begin
		if Current_LRCK = '0' then
				Selected_Channel <= DATA_DAC_L;
		elsif Current_LRCK = '1' then
				Selected_Channel <= DATA_DAC_R;
		end if;
	end process;
end Behavioral;

