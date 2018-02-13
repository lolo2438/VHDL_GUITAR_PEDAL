----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:25:26 02/12/2018 
-- Design Name: 
-- Module Name:    Distortion - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Distortion is
    Port ( -- 50MHz Clock
			  CLK : in  STD_LOGIC;
			  
			  -- Audio input and audio output
			  audioIn : in  STD_LOGIC_VECTOR (23 downto 0);
           audioOut : out  STD_LOGIC_VECTOR (23 downto 0);
			  
			  -- Select Module
			  SM : in STD_LOGIC;
			  
			  -- Lock Module
           LM : in  STD_LOGIC;
			  Locked : out STD_LOGIC;
			  
			  -- External Controls
           Tone : in  STD_LOGIC_VECTOR (9 downto 0);
           Drive : in  STD_LOGIC_VECTOR (9 downto 0);
			  TBD : in STD_LOGIC_VECTOR (9 downto 0)
			);
end Distortion;

architecture Behavioral of Distortion is

begin

--formula
--function [x]=gdist(a,x)
--%[Y] = GDIST(A, X) Guitar Distortion
--%
--%   GDIST creates a distortion effect like that of
--%   an overdriven guitar amplifier. This is a Matlab 
--%   implementation of an algorithm that was found on 
--%   www.musicdsp.org.
--%
--%   A = The amount of distortion.  A
--%       should be chosen so that -1<A<1.
--%   X = Input.  Should be a column vector 
--%       between -1 and 1.
--%
--%coded by: Steve McGovern, date: 09.29.04
--%URL: http://www.steve-m.us
--
--k = 2*a/(1-a);
--x = (1+k)*(x)./(1+k*abs(x));

end Behavioral;

