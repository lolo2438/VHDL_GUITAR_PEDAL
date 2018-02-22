----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:07:00 02/16/2018 
-- Design Name: 
-- Module Name:    Button_Processing - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Button_Processing is
    Port ( CLK : in  STD_LOGIC;							-- FPGA CLOCK
	 
           PEDAL_IN : in  STD_LOGIC;					-- PEDAL IN
			  PEDAL_OUT : out  STD_LOGIC;					-- PEDAL OUT
			  
           NEXT_EFFECT_IN : in  STD_LOGIC;			-- NEXT EFFECT IN
           NEXT_EFFECT_OUT : out  STD_LOGIC;			-- NEXT EFFECT OUT
           
           
           LAST_EFFECT_IN : in  STD_LOGIC;			-- LAST EFFECT IN
           LAST_EFFECT_OUT : out  STD_LOGIC;			-- LAST EFFECT OUT
			  
			  LOCK : out  STD_LOGIC;						-- LOCK PULSE
			  RESET : in STD_LOGIC							-- RESET SIGNAL
			 );
			 
end Button_Processing;

architecture Behavioral of Button_Processing is

signal arLAST_EFFECT : STD_LOGIC := '0';
signal arNEXT_EFFECT : STD_LOGIC := '0';
signal arPedal : STD_LOGIC := '0';

begin

-- Pedal stays at constant '1' whilst others buttons send a pulse
AR_Pedal : entity work.Anti_Rebond(Behavioral)
Port map(	
			Bouton => PEDAL_IN,
			Sortie => arPedal,
			Horloge => CLK
		  );

PedalControl: entity work.PedalControl(Behavioral)
Port map(
			 CLK => CLK,		
          PEDAL_IN => arPedal,	
			 PEDAL_OUT => PEDAL_OUT,  
			 LOCK => LOCK,
			 RESET => RESET
			);

-- Step 1: Remove rebound	  
AR_Back : entity work.Anti_Rebond(Behavioral)
Port map(	
			Bouton => LAST_EFFECT_IN,
			Sortie => arLAST_EFFECT,
			Horloge => CLK
		  );

AR_Next : entity work.Anti_Rebond(Behavioral)
Port map(	
			Bouton => NEXT_EFFECT_IN,
			Sortie => arNEXT_EFFECT,
			Horloge => CLK
		  );
		  

-- Step 2: Send 1 clock pulse when detected a rising edge
PBack : entity work.Detecteur_Front(Behavioral)
Port map(
			CLK => CLK,
         Input => arLAST_EFFECT,
         Output => LAST_EFFECT_OUT
		  );

PNext : entity work.Detecteur_Front(Behavioral)
Port map(
			CLK => CLK,
         Input => arNEXT_EFFECT,
         Output => NEXT_EFFECT_OUT
		  );
		  

end Behavioral;
