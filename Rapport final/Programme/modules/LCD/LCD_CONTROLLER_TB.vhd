--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:52:22 03/25/2018
-- Design Name:   
-- Module Name:   F:/Laurent/Documents/GitHub/VHDL_GUITAR_PEDAL/VHDL/LCD_CONTROLLER_TB.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LCD_Controler
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
 
ENTITY LCD_CONTROLLER_TB IS
END LCD_CONTROLLER_TB;
 
ARCHITECTURE behavior OF LCD_CONTROLLER_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LCD_Controler
    PORT(
         CLK : IN  std_logic;
			PEDAL : IN std_logic;
         LM : IN  std_logic_vector(7 downto 0);
         SM : IN  std_logic_vector(7 downto 0);
         RESET : IN  std_logic;
         ADC0 : IN  std_logic_vector(9 downto 0);
         ADC1 : IN  std_logic_vector(9 downto 0);
         ADC4 : IN  std_logic_vector(9 downto 0);
         GLCD_DATA : OUT  std_logic_vector(7 downto 0);
         GLCD_E : OUT  std_logic;
         GLCD_RW : OUT  std_logic;
         GLCD_RS : OUT  std_logic;
         GLCD_CS : OUT  std_logic_vector(2 downto 1);
         GLCD_RST : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal LM : std_logic_vector(7 downto 0) := (others => '0');
   signal SM : std_logic_vector(7 downto 0) := (others => '0');
   signal RESET : std_logic := '0';
   signal ADC0 : std_logic_vector(9 downto 0) := (others => '0');
   signal ADC1 : std_logic_vector(9 downto 0) := (others => '0');
   signal ADC4 : std_logic_vector(9 downto 0) := (others => '0');
	signal PEDAL : std_logic := '0';
	
 	--Outputs
   signal GLCD_DATA : std_logic_vector(7 downto 0);
   signal GLCD_E : std_logic;
   signal GLCD_RW : std_logic;
   signal GLCD_RS : std_logic;
   signal GLCD_CS : std_logic_vector(2 downto 1);
   signal GLCD_RST : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LCD_Controler PORT MAP (
          CLK => CLK,
          LM => LM,
          SM => SM,
			 PEDAL => PEDAL,
          RESET => RESET,
          ADC0 => ADC0,
          ADC1 => ADC1,
          ADC4 => ADC4,
          GLCD_DATA => GLCD_DATA,
          GLCD_E => GLCD_E,
          GLCD_RW => GLCD_RW,
          GLCD_RS => GLCD_RS,
          GLCD_CS => GLCD_CS,
          GLCD_RST => GLCD_RST
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
		RESET <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      --wait for CLK_period*10;
		RESET <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
