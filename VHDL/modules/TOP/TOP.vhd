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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
    Port (  -- Mojo 50 MHz clock
				CLK : in  STD_LOGIC;
			
				-- I2S pins
				SDTI : in STD_LOGIC;							-- Data from codec
 				SDTO : out  STD_LOGIC;						-- Data to codec
				BCLK : in  STD_LOGIC;						-- Bit clock from codec
				LRCK : in  STD_LOGIC;						-- Left right clock from codec
				
				-- AVR Interface pins
				CCLK : in STD_LOGIC;										-- Configuration clock from AVR to detect when ready
				SPI_SCK : in STD_LOGIC;									-- SPI clock from AVR
				SPI_SS : in STD_LOGIC;									-- SPI slave select from AVR
				SPI_MOSI : in STD_LOGIC;								-- AVR -> FPGA
				SPI_MISO : out STD_LOGIC;								-- AVR <- FPGA
				SPI_CHANNEL : out STD_LOGIC_VECTOR(3 downto 0);	-- Analog read channel (input to AVR service task)
				AVR_TX : in STD_LOGIC;
				AVR_RX : out STD_LOGIC;
				AVR_RX_BUSY : in STD_LOGIC;
				
				--Guitar effect chain pins
				PEDAL : in STD_LOGIC;
				LAST_EFFECT : in STD_LOGIC;
				NEXT_EFFECT : in STD_LOGIC;
				
				-- OTHERS  
				RESET : in STD_LOGIC);
end TOP;

architecture Behavioral of TOP is

-- I2S Signals
signal audioL : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
signal audioIn : STD_LOGIC_VECTOR(23 downto 0):= (others => '0');
signal audioOut : STD_LOGIC_VECTOR(23 downto 0):= (others => '0');

signal dataReady : STD_LOGIC;
signal doneSending : STD_LOGIC;

-- AVR Interface signals
signal channel : STD_LOGIC_VECTOR(3 downto 0);
signal sample : STD_LOGIC_VECTOR(9 downto 0);
signal sampleChannel : STD_LOGIC_VECTOR(3 downto 0);
signal newSample : STD_LOGIC;
signal lastSample : STD_LOGIC_VECTOR(9 downto 0);
signal txData : STD_LOGIC_VECTOR(7 downto 0);
signal rxData : STD_LOGIC_VECTOR(7 downto 0);
signal newTxData : STD_LOGIC;
signal newRxData : STD_LOGIC;
signal txBusy : STD_LOGIC;

-- ADC READ signals
signal adc0 : STD_LOGIC_VECTOR(9 downto 0);
signal adc1 : STD_LOGIC_VECTOR(9 downto 0);
signal adc4 : STD_LOGIC_VECTOR(9 downto 0);

-- Guitar effect chain signals
signal lockedData : STD_LOGIC_VECTOR(2 downto 0);

-- Button processing
signal sPedal : STD_LOGIC;
signal sLock : STD_LOGIC;
signal sNextE : STD_LOGIC;
signal sLastE : STD_LOGIC;
signal sAA : STD_LOGIC;

begin

-- PORT MAP

-- I2S INTERFACE
I2SToParallel: entity work.I2S_TO_PARALLEL(Behavioral)
port map(  -- I2S PORTS
			  SDTI => SDTI,
			  BCLK => BCLK,
			  LRCK => LRCK,
			  
			  -- PARALLEL DATA FROM ADC
			  DATA_ADC_L => audioL,
			  DATA_ADC_R => audioIn,
			  
			  -- OTHERS
			  RESET => RESET,
			  DATA_READY => dataReady
			  );
			  
parallelToI2S : entity work.PARALLEL_TO_I2S(Behavioral)
port map (-- I2S PORTS
			  BCLK => BCLK,
			  LRCK => LRCK,
			  SDTO => SDTO,
			  
			   -- PARALLEL DATA TO DAC
			  DATA_DAC_L => audioL,
			  DATA_DAC_R => audioOut,
			  
			  -- OTHERS
			  RESET => RESET,
			  DONE => doneSending
			  );

-- AVR INTERFACE
avr_interface : entity work.avr_interface(RTL)
port map (	-- Clocks and Reset
				clk => CLK,
				rst => RESET,
				cclk => CCLK,
				
				-- Hardward SPI pins
				spi_miso => SPI_MISO,
				spi_mosi	=> SPI_MOSI,
				spi_sck => SPI_SCK,
				spi_ss => SPI_SS,
				spi_channel	=> SPI_CHANNEL,
				tx	=> AVR_RX,
				rx	=> AVR_TX,
				tx_block => AVR_RX_BUSY,
				
				-- Internal signals
				channel	=> channel,
				new_sample => newSample,
				sample => sample,
				sample_channel	=> sampleChannel,
				
				tx_data => txData,
				new_tx_data => newTxData,
				tx_busy => txBusy,

				rx_data => rxData,
				new_rx_data	=> newRxData
			);

-- GUITAR EFFECT CHAIN
effectChain : entity work.effectChain(Behavioral)
Port map ( -- FPGA 50 MHZ
			  CLK => CLK,
			  
			  -- Audio signals
			  AUDIO_IN => audioIn,
           AUDIO_OUT => audioOut,
			  
			  READY => dataReady,
			  DONE => doneSending,
			  
			  -- Pedal
			  PEDAL => sPedal,
			  
			  -- Lock
			  LOCK => sLock,
			  LOCKED => lockedData,
			  ACTIVATE_ALL => sAA,
			  
			  -- Effect control
			  LAST_EFFECT => sLastE,
			  NEXT_EFFECT => sNextE,
			  
			  -- Reset
			  RESET => RESET,
			  
			  -- Control ADC
			  ADC0 => adc0,
			  ADC1 => adc1,
			  ADC4 => adc4
			);

-- ADC READ MODULE

-- Input buttons Signal processing
Buttton_Process : entity work.Button_Processing(Behavioral)
Port map(
			CLK => CLK,
         PEDAL_IN => PEDAL,
         NEXT_EFFECT_IN => NEXT_EFFECT,
         LAST_EFFECT_IN => LAST_EFFECT,
         PEDAL_OUT => sPedal,
         LOCK=> sLock,
			ACTIVATE_ALL => sAA,
         NEXT_EFFECT_OUT => sNextE,
         LAST_EFFECT_OUT => sLastE
		  );
-- add pulse module internally to i2s interfaces

-- PEDAL CONTROLS
-- 1 press => activate, 2 presses => lock module, press for 2 seconds => activate chain.

-- LOGIQUE DE SORTIE

end Behavioral;

