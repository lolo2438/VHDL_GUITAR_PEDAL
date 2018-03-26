--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:17:19 02/19/2018
-- Design Name:   
-- Module Name:   C:/Users/e1538867/Desktop/VHDL_GUITAR_PEDAL/VHDL_GUITAR_PEDAL/VHDL/PedalCtrlTB.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PedalControl
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
 
ENTITY PedalCtrlTB IS
END PedalCtrlTB;
 
ARCHITECTURE behavior OF PedalCtrlTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PedalControl
    PORT(
         CLK : IN  std_logic;
         PEDAL_IN : IN  std_logic;
         PEDAL_OUT : OUT  std_logic;
         LOCK : OUT  std_logic;
         RESET : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal PEDAL_IN : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal PEDAL_OUT : std_logic;
   signal LOCK : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PedalControl PORT MAP (
          CLK => CLK,
          PEDAL_IN => PEDAL_IN,
          PEDAL_OUT => PEDAL_OUT,
          LOCK => LOCK,
          RESET => RESET
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
		RESET <='0';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		RESET <= '1';

      -- insert stimulus here 
		
		-- Normal
		PEDAL_IN <= '0';
		
		wait for 250 ms;
		
		PEDAL_IN <= '1';
		
		wait for 750 ms;
		
		PEDAL_IN <= '0';
		
		wait for 750 ms;
		
		PEDAL_IN <= '1';
		
		wait for 750 ms;
		
		-- Lock
		
		PEDAL_IN <= '0';
		
		wait for 250 ms;
		
		PEDAL_IN <= '1';
		
      wait;
   end process;

END;
