--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:49:07 02/27/2018
-- Design Name:   
-- Module Name:   C:/Users/e1538867/Desktop/VHDL_GUITAR_PEDAL/VHDL/tremol_tb.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Tremolo
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
 
ENTITY tremol_tb IS
END tremol_tb;
 
ARCHITECTURE behavior OF tremol_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Tremolo
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         audioIn : IN  std_logic_vector(23 downto 0);
         audioOut : OUT  std_logic_vector(23 downto 0);
         Pedal : IN  std_logic;
         SM : IN  std_logic;
         lock : IN  std_logic;
         locked : OUT  std_logic;
         Rate : IN  std_logic_vector(9 downto 0);
         Wave : IN  std_logic_vector(9 downto 0);
         Depth : IN  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal audioIn : std_logic_vector(23 downto 0) := (others => '0');
   signal Pedal : std_logic := '0';
   signal SM : std_logic := '0';
   signal lock : std_logic := '0';
   signal Rate : std_logic_vector(9 downto 0) := (others => '0');
   signal Wave : std_logic_vector(9 downto 0) := (others => '0');
   signal Depth : std_logic_vector(9 downto 0) := (others => '0');

 	--Outputs
   signal audioOut : std_logic_vector(23 downto 0);
   signal locked : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Tremolo PORT MAP (
          CLK => CLK,
          RESET => RESET,
          audioIn => audioIn,
          audioOut => audioOut,
          Pedal => Pedal,
          SM => SM,
          lock => lock,
          locked => locked,
          Rate => Rate,
          Wave => Wave,
          Depth => Depth
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
      
		Depth <= b"1111111111";
		Rate <= b"0000000000";
		Wave <= b"0000000001";
		
      wait for 100 ns;	
		
		RESET <= '1';
		
		audioIn <= x"00FFFF";
		
		
		
		Pedal <= '1';
		SM <= '1';
	
      -- insert stimulus here 

      wait;
   end process;

END;
