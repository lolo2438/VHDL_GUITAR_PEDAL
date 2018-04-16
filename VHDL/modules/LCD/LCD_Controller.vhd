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
type pagedArray is array (0 to 127) of STD_LOGIC_VECTOR(7 downto 0);				-- One page for Ez Glcd Data Transfer Array

type lcdArray is array (0 to 7) of pagedArray;											-- EGDTA 
signal lcdScreen : lcdArray := (others => (others => (others => '0')));			-- lcdScreen(Page)(address)(Data)				

-- Commands for GLCD_RW
constant glcdWrite : STD_LOGIC := '0';
constant glcdRead : STD_LOGIC := '1';

-- Command for Set Address
constant glcdSetLine : STD_LOGIC_VECTOR(1 downto 0) := b"01";						-- Most significative data byte
constant glcdSetAddress0 : STD_LOGIC_VECTOR(7 downto 0) := b"01000000";
constant glcdSetPage : STD_LOGIC_VECTOR(4 downto 0) := b"10111";					-- Most significative data byte

-- Command for display ON
constant setDisplayOn : STD_LOGIC_VECTOR(7 downto 0) := b"00111111";

-- Commands for GLCD_CS
constant leftSide : STD_LOGIC_VECTOR(2 downto 1) := b"10";
constant rightSide : STD_LOGIC_VECTOR(2 downto 1) := b"01";
constant noSide : STD_LOGIC_VECTOR(2 downto 1) := b"00";

-- Commands for GLCD_RS
constant glcdSendData : STD_LOGIC := '1';
constant glcdSendCmd : STD_LOGIC := '0';

-- OPERATION ENABLE SIGNAL
signal E : STD_LOGIC := '0';
signal lastE : STD_LOGIC := '0';
signal compteur : UNSIGNED(14 downto 0) := (others => '0');
signal enableE : STD_LOGIC := '0';	

begin
-- Signal asignment 
GLCD_E <= E;

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
							address := 64;
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
						
						address := 0;
					elsif E = '0' and lastE = '1' then						-- Falling edge => lcd is reading
						lastE <= E;
						glcdControlerState <= refreshAddressLeft;
						
					end if;
			end case;
		end if;
end process;


-- IMAGES


---
-- Selected Module Image
----
with SM select
	lcdScreen(0) <=	(x"00", x"00", x"00", x"00", x"00", x"00", x"30", x"EE", 
							 x"01", x"01", x"01", x"31", x"F9", x"11", x"31", x"E1", 
							 x"03", x"02", x"0C", x"38", x"E0", x"FE", x"01", x"01", 
							 x"01", x"FD", x"07", x"38", x"E4", x"82", x"01", x"01", 
							 x"19", x"39", x"31", x"31", x"31", x"52", x"CC", x"9E", 
							 x"13", x"11", x"F1", x"61", x"01", x"01", x"01", x"F1", 
							 x"19", x"09", x"F7", x"08", x"06", x"82", x"81", x"F1", 
							 x"19", x"99", x"B1", x"E1", x"C3", x"C2", x"DC", x"C0", 
							 x"40", x"7E", x"61", x"61", x"61", x"31", x"19", x"19", 
							 x"B9", x"B1", x"B1", x"32", x"34", x"1C", x"1E", x"99", 
							 x"99", x"99", x"D9", x"C9", x"45", x"45", x"CD", x"6F", 
							 x"E6", x"65", x"65", x"25", x"27", x"E7", x"F4", x"36", 
							 x"32", x"1B", x"19", x"FD", x"14", x"14", x"F2", x"F2", 
							 x"06", x"0C", x"08", x"8E", x"FF", x"F9", x"05", x"05", 
							 x"03", x"C2", x"04", x"08", x"30", x"6F", x"79", x"01", 
							 x"01", x"EF", x"F9", x"00", x"00", x"00", x"00", x"00") when b"00000001",				-- Distortion IMG TOP
							 (others => (others => '0')) when others;

with SM select
	lcdScreen(1) <=  (x"00", x"00", x"00", x"00", x"E0", x"F8", x"CF", x"C3", 
							x"C0", x"C0", x"C0", x"CC", x"CF", x"4C", x"44", x"63", 
							x"20", x"10", x"C8", x"F4", x"BB", x"87", x"40", x"30", 
							x"08", x"7F", x"48", x"C4", x"85", x"85", x"87", x"87", 
							x"8E", x"8E", x"CE", x"EC", x"34", x"38", x"14", x"17", 
							x"D8", x"CC", x"CF", x"CC", x"EE", x"66", x"22", x"3B", 
							x"32", x"32", x"33", x"7B", x"6B", x"CD", x"CD", x"8C", 
							x"8C", x"CC", x"4C", x"64", x"36", x"1A", x"0A", x"FE", 
							x"CE", x"C6", x"C3", x"63", x"3B", x"05", x"7F", x"C7", 
							x"C1", x"C1", x"DD", x"7F", x"01", x"01", x"F1", x"F8", 
							x"C7", x"C3", x"40", x"70", x"18", x"0F", x"00", x"FC", 
							x"C7", x"C0", x"C0", x"40", x"3F", x"03", x"1F", x"38", 
							x"60", x"C0", x"C3", x"87", x"88", x"CC", x"47", x"40", 
							x"30", x"10", x"0C", x"E7", x"FF", x"C0", x"C0", x"60", 
							x"3F", x"03", x"1E", x"78", x"E0", x"C0", x"C0", x"C0", 
							x"7F", x"07", x"00", x"00", x"00", x"00", x"00", x"00") when b"00000001",				 -- Distortion IMG BOT
						   (others => (others => '0')) when others;
												
----
-- ADC Bars
----
ADC0Bar:
process(CLK)
	begin
		if rising_edge(CLK) then
			--Todo
		end if;
end process;

----
-- Static images
----

end Behavioral;

