--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:43:05 02/13/2018
-- Design Name:   
-- Module Name:   F:/Laurent/Documents/GitHub/VHDL_GUITAR_PEDAL/VHDL/modules/Volume/volumeControlTB.vhd
-- Project Name:  Projet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: volumeControl
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
 
ENTITY volumeControlTB IS
END volumeControlTB;
 
ARCHITECTURE behavior OF volumeControlTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT volumeControl
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         audioIn : IN  std_logic_vector(23 downto 0);
         audioOut : OUT  std_logic_vector(23 downto 0);
         SM : IN  std_logic;
         lock : IN  std_logic;
         locked : OUT  std_logic;
         volumeGain : IN  std_logic_vector(9 downto 0);
         TBD1 : IN  std_logic_vector(9 downto 0);
         TBD2 : IN  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal audioIn : std_logic_vector(23 downto 0) := (others => '0');
   signal SM : std_logic := '0';
   signal lock : std_logic := '0';
   signal volumeGain : std_logic_vector(9 downto 0) := (others => '0');
   signal TBD1 : std_logic_vector(9 downto 0) := (others => '0');
   signal TBD2 : std_logic_vector(9 downto 0) := (others => '0');

 	--Outputs
   signal audioOut : std_logic_vector(23 downto 0);
   signal locked : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: volumeControl PORT MAP (
          CLK => CLK,
          RESET => RESET,
          audioIn => audioIn,
          audioOut => audioOut,
          SM => SM,
          lock => lock,
          locked => locked,
          volumeGain => volumeGain,
          TBD1 => TBD1,
          TBD2 => TBD2
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
		RESET <= '1';
		
		volumeGain <= b"1111111111";
		
		audioIn <= x"FF00FF";
		wait for 1 us;
		audioIn <= x"7F00FF";
		wait for 1 us;
		audioIn <= x"00FF00";
		wait for 1 us;
		
		SM <= '1';
		
		audioIn <= x"FF00FF";
		wait for 1 us;
		audioIn <= x"7F00FF";
		wait for 1 us;
		audioIn <= x"00FF00";
		wait for 1 us;
		
		volumeGain <= b"0000000000";
		
		audioIn <= x"FF00FF";
		wait for 1 us;
		audioIn <= x"7F00FF";
		wait for 1 us;
		audioIn <= x"00FF00";
		wait for 1 us;
		
		volumeGain <= b"0110110110";
		
		audioIn <= x"FF00FF";
		wait for 1 us;
		audioIn <= x"7F00FF";
		wait for 1 us;
		audioIn <= x"00FF00";
		wait for 1 us;

      wait;
   end process;

END;
