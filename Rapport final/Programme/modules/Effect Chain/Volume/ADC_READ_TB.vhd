--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:08:41 02/20/2018
-- Design Name:   
-- Module Name:   C:/Users/e1538867/Desktop/VHDL_GUITAR_PEDAL/VHDL/modules/Effect Chain/Volume/ADC_READ_TB.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ADC_Read
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
 
ENTITY ADC_READ_TB IS
END ADC_READ_TB;
 
ARCHITECTURE behavior OF ADC_READ_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ADC_Read
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         NEW_SAMPLE : IN  std_logic;
         SAMPLE : IN  std_logic_vector(9 downto 0);
         SAMPLE_CHANNEL : IN  std_logic_vector(3 downto 0);
         REQUESTED_CHANNEL : OUT  std_logic_vector(3 downto 0);
         ADC0 : OUT  std_logic_vector(9 downto 0);
         ADC1 : OUT  std_logic_vector(9 downto 0);
         ADC4 : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal NEW_SAMPLE : std_logic := '0';
   signal SAMPLE : std_logic_vector(9 downto 0) := (others => '0');
   signal SAMPLE_CHANNEL : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal REQUESTED_CHANNEL : std_logic_vector(3 downto 0);
   signal ADC0 : std_logic_vector(9 downto 0);
   signal ADC1 : std_logic_vector(9 downto 0);
   signal ADC4 : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ADC_Read PORT MAP (
          CLK => CLK,
          RESET => RESET,
          NEW_SAMPLE => NEW_SAMPLE,
          SAMPLE => SAMPLE,
          SAMPLE_CHANNEL => SAMPLE_CHANNEL,
          REQUESTED_CHANNEL => REQUESTED_CHANNEL,
          ADC0 => ADC0,
          ADC1 => ADC1,
          ADC4 => ADC4
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		RESET <= '1';
		
		
		SAMPLE_CHANNEL <= x"0";
      SAMPLE <= b"0011001100";
		
	--	wait for 10 ns;
		
		NEW_SAMPLE <= '1';
		
		wait for 100 ns;
		
		NEW_SAMPLE <= '0';
		
		wait for 100 ns;
		
		SAMPLE_CHANNEL <= x"1";
		SAMPLE <= b"1100110011";
		
	--	wait for 10 ns;
		NEW_SAMPLE <= '1';
		
		wait for 100 ns;
		
		NEW_SAMPLE <= '0';
		
		wait for 100 ns;
		
		SAMPLE_CHANNEL <= x"4";
		SAMPLE <= b"0101001010";
		
	--	wait for 10 ns;
		NEW_SAMPLE <= '1';

      wait;
   end process;

END;
