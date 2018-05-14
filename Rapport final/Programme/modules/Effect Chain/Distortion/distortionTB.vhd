--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:30:16 05/03/2018
-- Design Name:   
-- Module Name:   F:/Laurent/Documents/GitHub/VHDL_GUITAR_PEDAL/VHDL/distortionTB.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Distortion
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
 
ENTITY distortionTB IS
END distortionTB;
 
ARCHITECTURE behavior OF distortionTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Distortion
    PORT(
         CLK : IN  std_logic;
         audioIn : IN  std_logic_vector(23 downto 0);
         audioOut : OUT  std_logic_vector(23 downto 0);
         Pedal : IN  std_logic;
         SM : IN  std_logic;
         LM : OUT  std_logic;
         LOCK : IN  std_logic;
         Dist : IN  std_logic_vector(9 downto 0);
         Tone : IN  std_logic_vector(9 downto 0);
         Level : IN  std_logic_vector(9 downto 0);
         distOut : OUT  std_logic_vector(9 downto 0);
         toneOut : OUT  std_logic_vector(9 downto 0);
         levelOut : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal audioIn : std_logic_vector(23 downto 0) := (others => '0');
   signal Pedal : std_logic := '0';
   signal SM : std_logic := '0';
   signal LOCK : std_logic := '0';
   signal Dist : std_logic_vector(9 downto 0) := (others => '0');
   signal Tone : std_logic_vector(9 downto 0) := (others => '0');
   signal Level : std_logic_vector(9 downto 0) := (others => '0');

 	--Outputs
   signal audioOut : std_logic_vector(23 downto 0);
   signal LM : std_logic;
   signal distOut : std_logic_vector(9 downto 0);
   signal toneOut : std_logic_vector(9 downto 0);
   signal levelOut : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Distortion PORT MAP (
          CLK => CLK,
          audioIn => audioIn,
          audioOut => audioOut,
          Pedal => Pedal,
          SM => SM,
          LM => LM,
          LOCK => LOCK,
          Dist => Dist,
          Tone => Tone,
          Level => Level,
          distOut => distOut,
          toneOut => toneOut,
          levelOut => levelOut
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
      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
