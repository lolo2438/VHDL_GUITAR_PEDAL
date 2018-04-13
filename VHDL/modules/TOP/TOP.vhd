-----------------------------------
--	Name: Laurent Tremblay			--
--	Project: Numeric guitar pedal	--
--	Module: TOP							--
--	Version:								--
--	Comments: Main module			--
-----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
    Port (  CLK : in  STD_LOGIC;							-- Mojo 50 MHz clock
			
				-- I2S pins
				SDTI : in STD_LOGIC;										-- Data from codec
 				SDTO : out  STD_LOGIC;									-- Data to codec
				BCLK : in  STD_LOGIC;									-- Bit clock from codec
				LRCK : in  STD_LOGIC;									-- Left right clock from codec
				
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
				
				-- LCD Signals
				GLCD_DATA : out  STD_LOGIC_VECTOR (7 downto 0);
				GLCD_E : out  STD_LOGIC;
				GLCD_RW : out  STD_LOGIC;
				GLCD_RS : out  STD_LOGIC;
				GLCD_CS : out  STD_LOGIC_VECTOR (2 downto 1);
				GLCD_RST : out STD_LOGIC;
				
				-- OTHERS
				RESET : in STD_LOGIC;
				LED1 : out STD_LOGIC;
				LED2 : out STD_LOGIC;
				LED3 : out STD_LOGIC
				);
end TOP;

architecture Behavioral of TOP is

-- I2S Signals
signal audioL : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
signal audioIn : STD_LOGIC_VECTOR(23 downto 0):= (others => '0');
signal audioOut : STD_LOGIC_VECTOR(23 downto 0):= (others => '0');

signal dataReady : STD_LOGIC;
signal doneSending : STD_LOGIC;

-- AVR Interface signals

	-- ADC signals
signal channel : STD_LOGIC_VECTOR(3 downto 0);
signal sample : STD_LOGIC_VECTOR(9 downto 0);
signal sampleChannel : STD_LOGIC_VECTOR(3 downto 0);
signal newSample : STD_LOGIC;

	-- Serial port signals
signal txData : STD_LOGIC_VECTOR(7 downto 0);
signal rxData : STD_LOGIC_VECTOR(7 downto 0);
signal newTxData : STD_LOGIC;
signal newRxData : STD_LOGIC;
signal txBusy : STD_LOGIC;

	-- Others
signal NOT_RESET : STD_LOGIC;

-- ADC READ signals
signal adc0 : STD_LOGIC_VECTOR(9 downto 0);
signal adc1 : STD_LOGIC_VECTOR(9 downto 0);
signal adc4 : STD_LOGIC_VECTOR(9 downto 0);

-- Guitar effect chain signals
signal lockedModules : STD_LOGIC_VECTOR(7 downto 0);
signal selectedModule : STD_LOGIC_VECTOR(7 downto 0);

-- Button processing
signal sLock : STD_LOGIC;
signal sNextE : STD_LOGIC;
signal sLastE : STD_LOGIC;

begin

LED1 <= adc0(8);
LED2 <= PEDAL;
LED3 <= NEXT_EFFECT;

-- Avr interface need reset logic inversion
NOT_RESET <= not RESET;

-- PORT MAP

-- I2S INTERFACE
I2SToParallel: entity work.I2S_TO_PARALLEL(Behavioral)
port map(  -- FPGA CLOCK
			  CLK => CLK,
			  
			  -- I2S PORTS
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
port map ( -- FPGA CLOCK
			  CLK => CLK,
			  
			  -- I2S PORTS
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
				rst => NOT_RESET,
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
			
-- ADC READ MODULE
ADC_READ : entity work.ADC_Read(Behavioral)
Port map ( -- FPGA CLOCK
			  CLK => CLK,
			  
			  -- RESET
			  RESET => RESET,
			  
			  -- From AVR Interface
			  NEW_SAMPLE => newSample,
			  SAMPLE => sample,
			  SAMPLE_CHANNEL => sampleChannel,
			  
			  -- To AVR Interface
           REQUESTED_CHANNEL => channel,
			  
			  -- To guitar effect
			  ADC0 => adc0,
			  ADC1 => adc1,
			  ADC4 => adc4
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
			  PEDAL => PEDAL,
			  
			  -- Lock
			  LOCK => sLock,
			  LOCKED => lockedModules,
			  
			  -- Selected module
			  SM => selectedModule,
			  
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

-- Input buttons Signal processing
Buttton_Process : entity work.Button_Processing(Behavioral)
Port map(
			CLK => CLK,
			
         PEDAL_IN => PEDAL,
			
         NEXT_EFFECT_IN => NEXT_EFFECT,
         LAST_EFFECT_IN => LAST_EFFECT,
     
         LOCK=> sLock,
			
         NEXT_EFFECT_OUT => sNextE,
         LAST_EFFECT_OUT => sLastE,
			
			RESET => RESET
		  );

-- Graphic interface signals
GLCD: entity work.LCD_Controler(Behavioral)
Port map( -- FPGA CLOCK
			  CLK => CLK,
			  
			  -- LOCKED MODULES
           LM => lockedModules,
			  
			  -- SELECTED MODULE
           SM => selectedModule,
			  
			  -- RESET
           RESET => RESET,
			  
			  -- ADC DATA
           ADC0 => adc0,
           ADC1 => adc1,
           ADC4 => adc4,
			  
			  -- GLCD Hardware signal
           GLCD_DATA => GLCD_DATA,				-- LCD DATA OUT
           GLCD_E => GLCD_E,						-- LCD OPERATION ENABLE , FALLING EDGE TRIGGERED
           GLCD_RW => GLCD_RW,					-- LCD READ=1 , WRITE =0
           GLCD_RS => GLCD_RS,					-- LCD REGISTER SELECT: RS=1 select DATA, RS=0 select INSTRUCTIONS
           GLCD_CS => GLCD_CS,					-- CHIP SELECT FOR LCD SIDE: 10 = SELECT LEFT, 01 = SELECT RIGHT
			  GLCD_RST => GLCD_RST);				-- RESET FOR LCD, 0 = reset


-- LOGIQUE DE SORTIE

end Behavioral;

