-------------------------------------
--	Name: Laurent Tremblay		   --
--	Project: Numeric guitar pedal  --
--	Module: TOP					   --
--  Version:					   --
--  Comments: Main module		   --
--								   --
-------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
    Port (  -- FPGA CLOCK 50MHZ
			CLK : in  STD_LOGIC;
			
			  -- I2S PINS
			SDTI : in STD_LOGIC;
			SDTO : out  STD_LOGIC;
			BCLK : in  STD_LOGIC;
			LRCK : in  STD_LOGIC;
			  
			-- OTHERS
			  
			RESET : in STD_LOGIC);
end TOP;

architecture Behavioral of TOP is

signal Audio_In_L : STD_LOGIC_VECTOR(23 downto 0);
signal Audio_Out_L : STD_LOGIC_VECTOR(23 downto 0);
signal Audio_In_R : STD_LOGIC_VECTOR(23 downto 0);
signal Audio_Out_R : STD_LOGIC_VECTOR(23 downto 0);

signal Data_Ready : STD_LOGIC;

begin

-- PORT MAP
I2S_INTERFACE: entity work.I2S_TO_PARALLEL(Behavioral)
port map(  -- I2S PORTS
			  SDTI => SDTI,
			  BCLK => BCLK,
			  LRCK => LRCK,
			  SDTO => SDTO,
			  
			  -- PARALLEL DATA FROM ADC
			  DATA_ADC_L => Audio_In_L,
			  DATA_ADC_R => Audio_In_R,
			  
			  -- PARALLEL DATA TO DAC
			  DATA_DAC_L => Audio_Out_L,
			  DATA_DAC_R => Audio_Out_R,
			  
			  -- OTHERS
			  RESET => RESET,
			  DATA_READY => Data_Ready,
			  CLK => CLK
			  );


-- LOGIQUE DE SORTIE
Audio_Out_R <= Audio_In_R;
Audio_Out_L <= Audio_In_L;

end Behavioral;

