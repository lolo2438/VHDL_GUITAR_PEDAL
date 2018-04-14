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
Type glcdControler is (init,sendDisplayOn,refreshAddressLeft,writeDataLeft,refreshAddressRight,writeDataRight,changePage);
Signal glcdControlerState : glcdControler := init;

-- Dynamic array
type pagedArray is array (0 to 127) of STD_LOGIC_VECTOR(0 to 7);				-- One page for Ez Glcd Data Transfer Array

type lcdArray is array (0 to 7) of pagedArray;										-- EGDTA 
signal lcdScreen : lcdArray := (others => (others => (others => '0')));	-- lcdScreen(Page)(address)(Data)				

--type userInterfaceforLCD is array (0 to 63) of STD_LOGIC_VECTOR(0 to 127); -- Ez User interface for data placement
--signal userInterface : userInterfaceforLCD :=(others => (others => '0'));

-- Commands for GLCD_RW
constant glcdWrite : STD_LOGIC := '0';
constant glcdRead : STD_LOGIC := '1';

-- Command for Set Address
constant glcdSetLine : STD_LOGIC_VECTOR(1 downto 0) := b"01";					-- Most significative data byte
constant glcdSetAddress0 : STD_LOGIC_VECTOR(7 downto 0) := b"01000000";
constant glcdSetPage : STD_LOGIC_VECTOR(4 downto 0) := b"10111";				-- Most significative data byte

-- Command for display ON
constant setDisplayOn : STD_LOGIC_VECTOR(7 downto 0) := b"00111111";

-- Commands for GLCD_CS
constant leftSide : STD_LOGIC_VECTOR(2 downto 1) := b"01";
constant rightSide : STD_LOGIC_VECTOR(2 downto 1) := b"10";
constant noSide : STD_LOGIC_VECTOR(2 downto 1) := b"00";

-- Commands for GLCD_RS
constant glcdSendData : STD_LOGIC := '1';
constant glcdSendCmd : STD_LOGIC := '0';

-- OPERATION ENABLE SIGNAL
signal E : STD_LOGIC := '0';
signal lastE : STD_LOGIC := '0';
signal compteur : UNSIGNED(14 downto 0) := (others => '0');
signal enableE : STD_LOGIC := '0';	

--signal reset_compteur : integer range 0 to 127 := 0;
--signal address : integer range 0 to 127 := 0;
--signal page : integer range 0 to 7 := 0;

begin
-- Signal asignment 
GLCD_E <= E;

lcdScreen(0) <=  (x"00", x"00", x"00", x"00", x"00", x"00", x"0C", x"77", 
						x"80", x"80", x"80", x"8C", x"9F", x"88", x"8C", x"87", 
						x"C0", x"40", x"30", x"1C", x"07", x"7F", x"80", x"80", 
						x"80", x"BF", x"E0", x"1C", x"27", x"41", x"80", x"80", 
						x"98", x"9C", x"8C", x"8C", x"8C", x"4A", x"33", x"79", 
						x"C8", x"88", x"8F", x"86", x"80", x"80", x"80", x"8F", 
						x"98", x"90", x"EF", x"10", x"60", x"41", x"81", x"8F", 
						x"98", x"99", x"8D", x"87", x"C3", x"43", x"3B", x"03", 
						x"02", x"7E", x"86", x"86", x"86", x"8C", x"98", x"98", 
						x"9D", x"8D", x"8D", x"4C", x"2C", x"38", x"78", x"99", 
						x"99", x"99", x"9B", x"93", x"A2", x"A2", x"B3", x"F6", 
						x"67", x"A6", x"A6", x"A4", x"E4", x"E7", x"2F", x"6C", 
						x"4C", x"D8", x"98", x"BF", x"28", x"28", x"4F", x"4F", 
						x"60", x"30", x"10", x"71", x"FF", x"9F", x"A0", x"A0", 
						x"C0", x"43", x"20", x"10", x"0C", x"F6", x"9E", x"80", 
						x"80", x"F7", x"9F", x"00", x"00", x"00", x"00", x"00"); 

lcdScreen(1)(0) <= x"0F";
lcdScreen(1)(1) <= x"F0";

---- Asigning the Ez User Interface array to the Ez glcd Data Transfer array
--pageAsign:for P in 0 to 7 generate
--	columnAsign: for R in 0 to 127 generate
--		rowAsign: for D in 0 to 7 generate
--		
--		page0Data:
--			if P = 0 generate
--				lcdScreen(P)(R)(D) <= userInterface(D)(R);
--			end generate;
--			
--		page1Data:	
--			if P = 1 generate
--				lcdScreen(P)(R)(D) <= userInterface(8 + D)(R);
--			end generate;
--			
--		page2Data:
--			if P = 2 generate
--				lcdScreen(P)(R)(D) <= userInterface(16 + D)(R);
--			end generate;
--			
--		page3Data:
--			if P = 3 generate
--				lcdScreen(P)(R)(D) <= userInterface(24 + D)(R);
--			end generate;
--			
--		page4Data:	
--			if P = 4 generate
--				lcdScreen(P)(R)(D) <= userInterface(32 + D)(R);
--			end generate;
--			
--		page5Data:
--			if P = 5 generate
--				lcdScreen(P)(R)(D) <= userInterface(40 + D)(R);
--			end generate;
--			
--		page6Data:	
--			if P = 6 generate
--				lcdScreen(P)(R)(D) <= userInterface(48 + D)(R);
--			end generate;
--			
--		page7Data:	
--			if P = 7 generate
--				lcdScreen(P)(R)(D) <= userInterface(56 + D)(R);	
--			end generate;
--			
--		end generate rowAsign;
--	end generate columnAsign;
--end generate pageAsign;

-- Generate 30 images per second
-- 1024 clock tick = 1 img -> 30_720 = 30 img; 50_000_000 / 30_720 = 1627 ~= 32uS (x"65B)
WriteDataClk:
process(RESET,CLK) 
	begin
		if RESET = '0' then
			compteur <= (others => '0');
		elsif rising_edge(CLK) then
			if enableE <= '1' then
				if compteur < x"65B" then				-- For testing purpose:  1 img/sec = 50MHz / 1024 = x"7800"
					compteur <= compteur + 1;
				else
					compteur <= (others => '0');
					E <= not E;
				end if;
			end if;
		end if;
end process;

-- Main controler
Controler:
process(RESET,CLK)
	variable reset_compteur : integer range 0 to 127 := 0;
	variable address : integer range 0 to 127 := 0;
	variable page : integer range 0 to 7 := 0;
	begin
		if RESET = '0' then
			GLCD_RST <= '0';
			glcdControlerState <= init;
			enableE <= '0';
			-- Variable reset
			reset_compteur := 0;
			
		elsif rising_edge(CLK) then
			case glcdControlerState is
				when init =>
					if reset_compteur < 100 then					-- Hold reset for 2uS
						reset_compteur := reset_compteur + 1;
						GLCD_RST <= '0';								-- Reset
						GLCD_CS <= noSide;							-- Init to no side
						GLCD_DATA <= x"00";							-- Set data to nothing
						enableE <= '0';								-- Disable E
						GLCD_RS <= glcdSendCmd;						-- Set lcd to send cmd
						GLCD_RW <= glcdWrite;						-- Set to write
						address := 0;									-- Go to address 0
						page := 0;										-- Go to page 0
						
					elsif reset_compteur < 120 then				-- Wait 400 ns for reset rise time
						GLCD_RST <= '1';								-- Re-enable
						reset_compteur := reset_compteur + 1;
		
					else
						enableE <= '1';								-- Enable data writing	
						GLCD_RS <= glcdSendCmd;						-- Set lcd to send cmd
						GLCD_DATA <= setDisplayOn;					-- Start with send display on
						glcdControlerState <= sendDisplayOn;	-- Send display on cmd	
					end if;
				
				when sendDisplayOn =>
					if E = '1' and lastE = '0' then				-- Rising edge => Setup values
						lastE <= E;
						GLCD_DATA <= setDisplayOn; 				-- Display on command
						
					elsif E = '0' and lastE = '1' then			-- Falling edge => LCD is reading the data 
						lastE <= E;
						glcdControlerState <= refreshAddressLeft;
					end if;
				
				when refreshAddressLeft =>
					if E = '1' and lastE = '0' then		-- Rising edge => Setup values
						GLCD_CS <= leftSide;
						lastE <= E;
						GLCD_RS <= glcdSendCmd;
						GLCD_DATA <= glcdSetAddress0;
						
					elsif E = '0' and lastE = '1' then			-- Falling edge => LCD is reading the data 
						lastE <= E;
						glcdControlerState <= writeDataLeft;
					end if;
					
				when writeDataLeft =>
					if E = '1' and lastE = '0' then				-- Rising edge => Setup values
						GLCD_CS <= leftSide;
						GLCD_RS <= glcdSendData;
						lastE <= E;
						GLCD_DATA <= lcdScreen(page)(address);
						
					elsif E = '0' and lastE = '1' then			-- Falling edge => LCD is reading the data
						lastE <= E;
						
						if address = 63 then
							glcdControlerState <= refreshAddressRight;
						else
							address := address + 1;
						end if;
						
					end if;
				
				when refreshAddressRight =>
					if E = '1' and lastE = '0' then				-- Rising edge => Setup values
						GLCD_CS <= rightSide;
						lastE <= E;
						GLCD_RS <= glcdSendCmd;
						GLCD_DATA <= glcdSetAddress0;
						
					elsif E = '0' and lastE = '1' then						-- Falling edge => LCD is reading the data 
						lastE <= E;
						glcdControlerState <= writeDataRight;
					end if;
				
				when writeDataRight =>
					if E = '1' and lastE = '0' then							-- Rising edge => Setup values
						lastE <= E;
						GLCD_RS <= glcdSendData;
						GLCD_CS <= rightSide;
						GLCD_DATA <= lcdScreen(Page)(address);

					elsif E = '0' and lastE = '1' then						-- Falling edge => LCD is reading the data
						lastE <= E;
						
						if address = 127 then
							glcdControlerState <= changePage;
						else
							address := address + 1;
						end if;
						
					end if;
					
				when changePage =>
					if E = '1' and lastE = '0' then							-- Rising edge => Setup values
						GLCD_CS <= noSide;
						lastE <= E;
						GLCD_RS <= glcdSendCmd;
						
						if page = 7 then
							page := 0;
							GLCD_DATA <= glcdSetPage & std_logic_vector(to_unsigned(page,3));
						else
							page := page + 1;
							GLCD_DATA <= glcdSetPage & std_logic_vector(to_unsigned(page,3));
						end if;
					
					elsif E = '0' and lastE = '1' then						-- Falling edge => lcd is reading
						lastE <= E;
						glcdControlerState <= refreshAddressLeft;
						address:= 0;
						
					end if;
			end case;
		end if;
end process;

-- Test image

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

