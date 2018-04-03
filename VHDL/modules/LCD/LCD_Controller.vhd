----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:13:38 03/14/2018 
-- Design Name: 
-- Module Name:    LCD_Controller - Behavioral 
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
-- DATASHEET USED: http://www.newhavendisplay.com/specs/NHD-12864WG-BTGH-TN.pdf
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity LCD_Controler is
    Port ( -- FPGA CLOCK
			  CLK : in  STD_LOGIC;
			  
			  -- LOCKED MODULES
           LM : in  STD_LOGIC_VECTOR (7 downto 0);
			  
			  -- SELECTED MODULE
           SM : in  STD_LOGIC_VECTOR (7 downto 0);
			  
			  -- RESET
           RESET : in  STD_LOGIC;
			  
			  -- ADC DATA
           ADC0 : in  STD_LOGIC_VECTOR (9 downto 0);
           ADC1 : in  STD_LOGIC_VECTOR (9 downto 0);
           ADC4 : in  STD_LOGIC_VECTOR (9 downto 0);
			  
			  -- GLCD signals
           GLCD_DATA : out  STD_LOGIC_VECTOR (7 downto 0);
           GLCD_E : out  STD_LOGIC;
           GLCD_RW : out  STD_LOGIC;
           GLCD_RS : out  STD_LOGIC;
           GLCD_CS : out  STD_LOGIC_VECTOR (2 downto 1);
			  GLCD_RST : out STD_LOGIC);
			  
end LCD_Controler;

architecture Behavioral of LCD_Controler is

-- State machine
Type glcdControler is (init,writeDataLeft,writeDataRight,changePage);
Signal glcdControlerState : glcdControler := init;

-- Dynamic array
type pagedArray is array (0 to 127) of STD_LOGIC_VECTOR(0 to 7);			-- Une page

type lcdArray is array (0 to 7) of pagedArray;									-- 8 pages
signal lcdScreen : lcdArray := (others => (others => (others => '0')));															-- lcdScreen(Page)(address)(Data)				

type userInterfaceforLCD is array (0 to 127) of STD_LOGIC_VECTOR(0 to 63);
signal userInterface : userInterfaceforLCD;

-- Commands for GLCD_RW
constant glcdWrite : STD_LOGIC := '0';
constant glcdRead : STD_LOGIC := '1';

-- Command for Set Address
constant glcdSetLine : STD_LOGIC_VECTOR(1 downto 0) := b"01";			-- Most significative data byte
constant glcdSetPage : STD_LOGIC_VECTOR(4 downto 0) := b"10111";		-- Most significative data byte

-- Command for display ON


-- Commands for GLCD_CS
constant leftSide : STD_LOGIC_VECTOR(1 downto 0) := b"01";
constant rightSide : STD_LOGIC_VECTOR(1 downto 0) := b"10";
constant noSide : STD_LOGIC_VECTOR(1 downto 0) := b"00";

-- Commands for GLCD_RS
constant glcdSendData : STD_LOGIC := '1';
constant glcdSendCmd : STD_LOGIC := '0';

-- OPERATION ENABLE SIGNAL
signal OE : STD_LOGIC := '0';
signal lastOE : STD_LOGIC := '0';
signal compteur : UNSIGNED(10 downto 0) := (others => '0');
signal enableOE : STD_LOGIC := '0';	

begin
-- Signal asignment 
GLCD_E <= OE;

-- Generate 30 images per second
-- 1024 clock tick = 1 img -> 30_720 = 30 img; 50_000_000 / 30_720 = 1627 ~= 32uS (0x65B)
WriteDataClk:process(RESET,CLK) 
	begin
		if RESET = '0' then
			compteur <= (others => '0');
		elsif rising_edge(CLK) then
			if enableOE <= '1' then
				if compteur < x"65B" then
					compteur <= compteur + 1;
				else
					compteur <= (others => '0');
					OE <= not OE;
				end if;
			end if;
		end if;
	end process;


-- Main sequential machine
Controler:process(RESET,CLK)
	variable reset_compteur : integer range 0 to 127 := 0;
	variable address : integer range 0 to 127 := 0;
	variable page : integer range 0 to 7 := 0;
	begin
		if RESET = '0' then
			GLCD_RST <= '0';
			glcdControlerState <= init;
			enableOE <= '0';
			-- Variable reset
			reset_compteur := 0;
			address := 0;
			page := 0;
			
		elsif rising_edge(CLK) then
			case glcdControlerState is
				when init =>
					if reset_compteur < 100 then			-- Hold reset for 2uS
						GLCD_RST <= '0';						-- Reset
						GLCD_CS <= noSide;					-- Init to no side
						reset_compteur := reset_compteur + 1;
						
					elsif reset_compteur < 120 then		-- Wait 400 ns for reset rise time
						GLCD_RST <= '1';						-- Re-enable
						reset_compteur := reset_compteur + 1;
						
					else
						GLCD_CS <= leftSide;							-- Select left side
						GLCD_RW <= glcdWrite;							-- Set to write data
						GLCD_RS <= glcdSendData;					-- Set lcd to receive data
						GLCD_DATA <= x"00";							-- Start with empty data
						glcdControlerState <= writeDataLeft;	-- Go in writing mode
						enableOE <= '1';								-- Enable data writing		
					end if;
					
				when writeDataLeft =>
					GLCD_RS <= glcdSendData;
					if OE = '1' and lastOE = '0' then		-- Rising edge => Setup values
						lastOE <= OE;
						GLCD_DATA <= lcdScreen(page)(address);
						
					elsif OE = '0' and lastOE = '1' then	-- Falling edge => LCD is reading the data
						lastOE <= OE;
						if address = 63 then
							glcdControlerState <= writeDataRight;
							GLCD_CS <= rightSide;
						else
							address := address + 1;
						end if;
					end if;

				when writeDataRight =>
					if OE = '1' and lastOE = '0' then		-- Rising edge => Setup values
						lastOE <= OE;
						GLCD_DATA <= lcdScreen(Page)(address);

					elsif OE = '0' and lastOE = '1' then	-- Falling edge => LCD is reading the data
						lastOE <= OE;
						if address = 127 then
							address := 0;
							glcdControlerState <= changePage;
						else
							address := address + 1;
						end if;
					end if;
					
				when changePage =>
					GLCD_CS <= noSide;
					if OE = '1' and lastOE = '0' then		-- Rising edge => Setup values
						lastOE <= OE;
						GLCD_RS <= glcdSendCmd;
						
						if page = 7 then
							page := 0;
							GLCD_DATA <= glcdSetPage & std_logic_vector(to_unsigned(page,3));
						else
							page := page + 1;
							GLCD_DATA <= glcdSetPage & std_logic_vector(to_unsigned(page,3));
						end if;
					
					elsif OE = '0' and lastOE = '1' then	-- Falling edge => lcd is reading
						glcdControlerState <= writeDataLeft;
						GLCD_CS <= leftSide;
					end if;
			end case;
		end if;
	end process;

----
-- Selected Module Image
----

----
-- Lock icon
----

----
-- ADC Bars
----

----
-- Static images
----

-- Page
-- ADC bars contour
end Behavioral;

