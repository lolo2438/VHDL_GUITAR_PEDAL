--------------------------------------------
--	Name: Laurent Tremblay
--	Project: Guitar effect processor
--	Module name: Button_Process
--	Description: This module connects all the
--					 button processing modules to
--				    the TOP module.
--------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Button_Processing is
    Port ( CLK : in  STD_LOGIC;							-- FPGA CLOCK
	 
           PEDAL_IN : in  STD_LOGIC;					-- PEDAL IN
			  
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

