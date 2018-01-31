--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:08:04 01/30/2018
-- Design Name:   
-- Module Name:   F:/Laurent/Documents/GitHub/VHDL_GUITAR_PEDAL/VHDL/I2S_TO_PARALLE3.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: I2S_TO_PARALLEL
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY I2S_TO_PARALLE3 IS
END I2S_TO_PARALLE3;
 
ARCHITECTURE behavior OF I2S_TO_PARALLE3 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT I2S_TO_PARALLEL
    PORT(
         SDTI : IN  std_logic;
         BCLK : IN  std_logic;
         LRCK : IN  std_logic;
         SDTO : OUT  std_logic;
         DATA_ADC_L : OUT  std_logic_vector(23 downto 0);
         DATA_ADC_R : OUT  std_logic_vector(23 downto 0);
         DATA_DAC_L : IN  std_logic_vector(23 downto 0);
         DATA_DAC_R : IN  std_logic_vector(23 downto 0);
         RESET : IN  std_logic;
         DATA_READY : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal SDTI : std_logic := '0';
   signal BCLK : std_logic := '0';
   signal LRCK : std_logic := '0';
   signal DATA_DAC_L : std_logic_vector(23 downto 0) := (others => '0');
   signal DATA_DAC_R : std_logic_vector(23 downto 0) := (others => '0');
   signal RESET : std_logic := '0';

 	--Outputs
   signal SDTO : std_logic;
   signal DATA_ADC_L : std_logic_vector(23 downto 0);
   signal DATA_ADC_R : std_logic_vector(23 downto 0);
   signal DATA_READY : std_logic;

   -- Clock period definitions
   constant BCLK_period : time := 80 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: I2S_TO_PARALLEL PORT MAP (
          SDTI => SDTI,
          BCLK => BCLK,
          LRCK => LRCK,
          SDTO => SDTO,
          DATA_ADC_L => DATA_ADC_L,
          DATA_ADC_R => DATA_ADC_R,
          DATA_DAC_L => DATA_DAC_L,
          DATA_DAC_R => DATA_DAC_R,
          RESET => RESET,
          DATA_READY => DATA_READY
        );

   -- Clock process definitions
   BCLK_process :process
   begin
		BCLK <= '0';
		wait for BCLK_period/2;
		BCLK <= '1';
		wait for BCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
     RESET <= '0';
      wait for BCLK_period*1;	
		
		DATA_DAC_L <= b"101100110011001100110011";
		DATA_DAC_R <= b"101010101010101010101010";
		
		RESET <= '1';
		-- RIGHT CHANNEL
		LRCK <= '1';
		-- 24 Bits IN
		SDTI <= '1';
		wait for BCLK_period*1; --SKIPPED
		SDTI <= '1';
		wait for BCLK_period*1; --1
		SDTI <= '1';
		wait for BCLK_period*1; --2
		SDTI <= '1';
		wait for BCLK_period*1; --3
		SDTI <= '0';
		wait for BCLK_period*1; --4
		SDTI <= '0';
		wait for BCLK_period*1; --5
		SDTI <= '0';
		wait for BCLK_period*1; --6
		SDTI <= '0';
		wait for BCLK_period*1; --7 
		SDTI <= '1';
		wait for BCLK_period*1; --8 
		SDTI <= '1';
		wait for BCLK_period*1; --9 
		SDTI <= '1';
		wait for BCLK_period*1; --10
		SDTI <= '1';
		wait for BCLK_period*1; --11
		SDTI <= '0';
		wait for BCLK_period*1; --12
		SDTI <= '0';
		wait for BCLK_period*1; --13
		SDTI <= '0';
		wait for BCLK_period*1; --14
		SDTI <= '0';
		wait for BCLK_period*1; --15
		SDTI <= '1';
		wait for BCLK_period*1; --16
		SDTI <= '1';
		wait for BCLK_period*1; --17
		SDTI <= '1';
		wait for BCLK_period*1; --18
		SDTI <= '1';
		wait for BCLK_period*1; --19
		SDTI <= '0';
		wait for BCLK_period*1; --20
		SDTI <= '0';
		wait for BCLK_period*1; --21
		SDTI <= '0';
		wait for BCLK_period*1; --22
		SDTI <= '0';
		wait for BCLK_period*1; --23
		SDTI <= '1';
		wait for BCLK_period*1; --24
		SDTI <= '1';
		wait for BCLK_period*5;
		
		-- LEFT CHANNEL
		LRCK <= '0';
		-- 24 Bits IN AND OUT
		SDTI <= '0';
		wait for BCLK_period*1; --SKIPPED
		SDTI <= '0';
		wait for BCLK_period*1; --1
		SDTI <= '1';
		wait for BCLK_period*1; --2
		SDTI <= '1';
		wait for BCLK_period*1; --3
		SDTI <= '0';
		wait for BCLK_period*1; --4
		SDTI <= '0';
		wait for BCLK_period*1; --5
		SDTI <= '1';
		wait for BCLK_period*1; --6
		SDTI <= '1';
		wait for BCLK_period*1; --7 
		SDTI <= '0';
		wait for BCLK_period*1; --8 
		SDTI <= '0';
		wait for BCLK_period*1; --9 
		SDTI <= '1';
		wait for BCLK_period*1; --10
		SDTI <= '1';
		wait for BCLK_period*1; --11
		SDTI <= '0';
		wait for BCLK_period*1; --12
		SDTI <= '0';
		wait for BCLK_period*1; --13
		SDTI <= '1';
		wait for BCLK_period*1; --14
		SDTI <= '1';
		wait for BCLK_period*1; --15
		SDTI <= '0';
		wait for BCLK_period*1; --16
		SDTI <= '0';
		wait for BCLK_period*1; --17
		SDTI <= '0';
		wait for BCLK_period*1; --18
		SDTI <= '1';
		wait for BCLK_period*1; --19
		SDTI <= '1';
		wait for BCLK_period*1; --20
		SDTI <= '0';
		wait for BCLK_period*1; --21
		SDTI <= '1';
		wait for BCLK_period*1; --22
		SDTI <= '1';
		wait for BCLK_period*1; --23
		SDTI <= '0';
		wait for BCLK_period*1; --24
		SDTI <= '0';
		
		DATA_DAC_R <= b"101100110011001100110011";
		DATA_DAC_L <= b"101010101010101010101010";
		wait for BCLK_period*5; 
		
		-- RIGHT CHANNEL
		LRCK <= '1';
		-- 24 Bits IN
		SDTI <= '1';
		wait for BCLK_period*1; --SKIPPED
		SDTI <= '0';
		wait for BCLK_period*1; --1
		SDTI <= '1';
		wait for BCLK_period*1; --2
		SDTI <= '0';
		wait for BCLK_period*1; --3
		SDTI <= '1';
		wait for BCLK_period*1; --4
		SDTI <= '0';
		wait for BCLK_period*1; --5
		SDTI <= '1';
		wait for BCLK_period*1; --6
		SDTI <= '0';
		wait for BCLK_period*1; --7 
		SDTI <= '1';
		wait for BCLK_period*1; --8 
		SDTI <= '0';
		wait for BCLK_period*1; --9 
		SDTI <= '1';
		wait for BCLK_period*1; --10
		SDTI <= '0';
		wait for BCLK_period*1; --11
		SDTI <= '1';
		wait for BCLK_period*1; --12
		SDTI <= '0';
		wait for BCLK_period*1; --13
		SDTI <= '1';
		wait for BCLK_period*1; --14
		SDTI <= '0';
		wait for BCLK_period*1; --15
		SDTI <= '1';
		wait for BCLK_period*1; --16
		SDTI <= '0';
		wait for BCLK_period*1; --17
		SDTI <= '1';
		wait for BCLK_period*1; --18
		SDTI <= '1';
		wait for BCLK_period*1; --19
		SDTI <= '0';
		wait for BCLK_period*1; --20
		SDTI <= '1';
		wait for BCLK_period*1; --21
		SDTI <= '0';
		wait for BCLK_period*1; --22
		SDTI <= '1';
		wait for BCLK_period*1; --23
		SDTI <= '1';
		wait for BCLK_period*1; --24
		SDTI <= '0';
		wait for BCLK_period*5;
		
		-- LEFT CHANNEL
		LRCK <= '0';
		
		-- 24 Bits IN AND OUT
		SDTI <= '0';
		wait for BCLK_period*1; --SKIPPED
		SDTI <= '1';
		wait for BCLK_period*1; --1
		SDTI <= '0';
		wait for BCLK_period*1; --2
		SDTI <= '1';
		wait for BCLK_period*1; --3
		SDTI <= '1';
		wait for BCLK_period*1; --4
		SDTI <= '0';
		wait for BCLK_period*1; --5
		SDTI <= '0';
		wait for BCLK_period*1; --6
		SDTI <= '1';
		wait for BCLK_period*1; --7 
		SDTI <= '1';
		wait for BCLK_period*1; --8 
		SDTI <= '1';
		wait for BCLK_period*1; --9 
		SDTI <= '0';
		wait for BCLK_period*1; --10
		SDTI <= '0';
		wait for BCLK_period*1; --11
		SDTI <= '0';
		wait for BCLK_period*1; --12
		SDTI <= '1';
		wait for BCLK_period*1; --13
		SDTI <= '1';
		wait for BCLK_period*1; --14
		SDTI <= '1';
		wait for BCLK_period*1; --15
		SDTI <= '1';
		wait for BCLK_period*1; --16
		SDTI <= '0';
		wait for BCLK_period*1; --17
		SDTI <= '0';
		wait for BCLK_period*1; --18
		SDTI <= '0';
		wait for BCLK_period*1; --19
		SDTI <= '0';
		wait for BCLK_period*1; --20
		SDTI <= '1';
		wait for BCLK_period*1; --21
		SDTI <= '1';
		wait for BCLK_period*1; --22
		SDTI <= '1';
		wait for BCLK_period*1; --23
		SDTI <= '1';
		wait for BCLK_period*1; --24
		SDTI <= '1';
      -- insert stimulus here 
      wait;
   end process;

END;
