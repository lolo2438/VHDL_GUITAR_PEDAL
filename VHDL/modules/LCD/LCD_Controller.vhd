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
			 
			  -- SELECTED MODULE
           SM : in  STD_LOGIC_VECTOR (7 downto 0);
			  
			  -- RESET
           RESET : in  STD_LOGIC;
			  
			  -- PEDAL
			  PEDAL : in STD_LOGIC;
			  
			  -- LOCKED DATA
			  LM : in STD_LOGIC_VECTOR (7 downto 0);
			  
			  
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
signal compteur : UNSIGNED(10 downto 0) := (others => '0');
signal enableE : STD_LOGIC := '0';	

--
signal sADC0 : unsigned(9 downto 0);
signal sADC1 : unsigned(9 downto 0);
signal sADC4 : unsigned(9 downto 0);

begin
-- Signal asignment 
GLCD_E <= E;
sADC0 <= unsigned(ADC0);
sADC1 <= unsigned(ADC1);
sADC4 <= unsigned(ADC4);

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
						GLCD_DATA <= setDisplayOn;				   -- Set data to nothing
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

---
------------
-- IMAGES ----
------------
---

---
-- Selected Module Image
----
with SM select			-- PAGE 0
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
						   
							(x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							 x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							 x"00", x"30", x"30", x"30", x"FF", x"FF", x"30", x"30", 
							 x"30", x"00", x"00", x"00", x"00", x"FF", x"FF", x"E3", 
							 x"E3", x"63", x"63", x"63", x"1C", x"1C", x"00", x"00", 
							 x"00", x"C0", x"E0", x"30", x"30", x"30", x"30", x"30", 
							 x"E0", x"C0", x"00", x"00", x"FF", x"FF", x"0E", x"1C", 
							 x"38", x"70", x"60", x"70", x"38", x"1C", x"0E", x"FF", 
							 x"FF", x"00", x"00", x"00", x"C0", x"C0", x"30", x"30", 
							 x"30", x"30", x"30", x"30", x"30", x"C0", x"C0", x"00", 
							 x"00", x"00", x"FF", x"FF", x"00", x"00", x"00", x"00", 
							 x"00", x"00", x"00", x"00", x"00", x"C0", x"C0", x"30", 
							 x"30", x"30", x"30", x"30", x"30", x"30", x"C0", x"C0", 
							 x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							 x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							 x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00") when b"00000010",
							 (others => (others => '0')) when others;

with SM select			-- PAGE 1
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
						  
						  (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
							x"00", x"00", x"00", x"00", x"0F", x"0F", x"30", x"30", 
							x"30", x"30", x"00", x"00", x"00", x"3F", x"3F", x"01", 
							x"03", x"07", x"0E", x"1C", x"38", x"30", x"00", x"00", 
							x"00", x"1F", x"3F", x"66", x"66", x"66", x"66", x"66", 
							x"23", x"01", x"00", x"00", x"7F", x"7F", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"7F", 
							x"7F", x"00", x"00", x"00", x"1F", x"1F", x"60", x"60", 
							x"60", x"60", x"60", x"60", x"60", x"1F", x"1F", x"00", 
							x"00", x"00", x"7F", x"7F", x"60", x"60", x"60", x"60", 
							x"60", x"60", x"00", x"00", x"00", x"1F", x"1F", x"60", 
							x"60", x"60", x"60", x"60", x"60", x"60", x"1F", x"1F", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00") when b"00000010", 
							
							(others => (others => '0')) when others;

with SM select
	lcdScreen(3) <=  (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"80", 
							x"9F", x"91", x"8E", x"80", x"9F", x"80", x"97", x"95", 
							x"9D", x"80", x"81", x"9F", x"81", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"01", x"9F", x"81", x"8E", x"91", x"91", x"8E", x"80", 
							x"9F", x"86", x"8C", x"9F", x"80", x"9F", x"95", x"15", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"81", x"86", x"98", x"98", x"86", 
							x"81", x"8E", x"91", x"91", x"8E", x"80", x"9F", x"90", 
							x"90", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00") when b"00000001",							-- Distortion parameters
						  
						  (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"1F", x"85", 
							x"85", x"9A", x"80", x"9F", x"85", x"9F", x"80", x"81", 
							x"9F", x"81", x"80", x"9F", x"95", x"15", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"0F", 
							x"10", x"8C", x"90", x"8F", x"80", x"9F", x"85", x"9F", 
							x"81", x"86", x"98", x"98", x"86", x"81", x"9F", x"15", 
							x"15", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", 
							x"1F", x"11", x"11", x"8E", x"80", x"9F", x"95", x"95", 
							x"80", x"9F", x"85", x"85", x"82", x"81", x"9F", x"81", 
							x"80", x"1F", x"04", x"1F", x"00", x"00", x"00", x"00", 
							x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00") when b"00000010", 							-- Tremolo parameters
							(others => (others => '0')) when others;
	

----
--	Small icons
----

lockIcon:
process(CLK)
begin
	if rising_edge(CLK) then
		case SM is
			when b"00000001" => -- distortion
				if LM(0) = '1' then
					lcdScreen(2)(117) <= x"F0";
					lcdScreen(2)(118) <= x"FC";
					lcdScreen(2)(119) <= x"F2";
					lcdScreen(2)(120) <= x"F2";
					lcdScreen(2)(121) <= x"F2";
					lcdScreen(2)(122) <= x"FC";
					lcdScreen(2)(123) <= x"F0";
				elsif LM(0) = '0' then
					lcdScreen(2)(117) <= x"00";
					lcdScreen(2)(118) <= x"00";
					lcdScreen(2)(119) <= x"00";
					lcdScreen(2)(120) <= x"00";
					lcdScreen(2)(121) <= x"00";
					lcdScreen(2)(122) <= x"00";
					lcdScreen(2)(123) <= x"00";
				end if;
			when b"00000010" => -- Tremolo
				if LM(1) = '1' then
					lcdScreen(2)(117) <= x"F0";
					lcdScreen(2)(118) <= x"FC";
					lcdScreen(2)(119) <= x"F2";
					lcdScreen(2)(120) <= x"F2";
					lcdScreen(2)(121) <= x"F2";
					lcdScreen(2)(122) <= x"FC";
					lcdScreen(2)(123) <= x"F0";
				elsif LM(1) = '0' then
					lcdScreen(2)(117) <= x"00";
					lcdScreen(2)(118) <= x"00";
					lcdScreen(2)(119) <= x"00";
					lcdScreen(2)(120) <= x"00";
					lcdScreen(2)(121) <= x"00";
					lcdScreen(2)(122) <= x"00";
					lcdScreen(2)(123) <= x"00";
				end if;
			when b"00000100" => -- Volume
				if LM(2) = '1' then
					lcdScreen(2)(117) <= x"F0";
					lcdScreen(2)(118) <= x"FC";
					lcdScreen(2)(119) <= x"F2";
					lcdScreen(2)(120) <= x"F2";
					lcdScreen(2)(121) <= x"F2";
					lcdScreen(2)(122) <= x"FC";
					lcdScreen(2)(123) <= x"F0";
				elsif LM(2) = '0' then
					lcdScreen(2)(117) <= x"00";
					lcdScreen(2)(118) <= x"00";
					lcdScreen(2)(119) <= x"00";
					lcdScreen(2)(120) <= x"00";
					lcdScreen(2)(121) <= x"00";
					lcdScreen(2)(122) <= x"00";
					lcdScreen(2)(123) <= x"00";
				end if;
			when others =>
					lcdScreen(2)(117) <= x"00";
					lcdScreen(2)(118) <= x"00";
					lcdScreen(2)(119) <= x"00";
					lcdScreen(2)(120) <= x"00";
					lcdScreen(2)(121) <= x"00";
					lcdScreen(2)(122) <= x"00";
					lcdScreen(2)(123) <= x"00";
			end case;
	end if;
end process;

pedalIcon:
process(CLK)
begin
	if rising_edge(CLK) then
		if PEDAL = '1' then
			lcdScreen(2)(3) <= x"38";
			lcdScreen(2)(4) <= x"44";
			lcdScreen(2)(5) <= x"80";
			lcdScreen(2)(6) <= x"9E";
			lcdScreen(2)(7) <= x"80";
			lcdScreen(2)(8) <= x"44";
			lcdScreen(2)(9) <= x"38";
		else
			lcdScreen(2)(3) <= x"00";
			lcdScreen(2)(4) <= x"00";
			lcdScreen(2)(5) <= x"00";
			lcdScreen(2)(6) <= x"00";
			lcdScreen(2)(7) <= x"00";
			lcdScreen(2)(8) <= x"00";
			lcdScreen(2)(9) <= x"00";
		end if;
	end if;
end process;


----
-- ADC lines
----
lineADC0:
process(CLK)
	begin
		if rising_edge(CLK) then
			if sADC0 > x"3E0" then	-- 992
				lcdScreen(4)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"3C0" then --960
				lcdScreen(4)(15 to 28) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"3A0" then --928
				lcdScreen(4)(15 to 28) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"380" then --896
				lcdScreen(4)(15 to 28) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"360" then --864
				lcdScreen(4)(15 to 28) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"340" then --832
				lcdScreen(4)(15 to 28) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"320" then --800
				lcdScreen(4)(15 to 28) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"300" then --768
				lcdScreen(4)(15 to 28) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"2E0" then --736
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"2C0" then --704
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"2A0" then --672
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"280" then --640
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"260" then --608
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"240" then --576
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"220" then --544
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"200" then --512
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"1E0" then --480
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"1C0" then --448
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"1A0" then --416
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"180" then --384
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"160" then --352
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"140" then --320
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"120" then --288
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"100" then --256
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"E0" then --224
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC0 > x"C0" then --192
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
			elsif sADC0 > x"A0" then --160
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
			elsif sADC0 > x"80" then --128
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
			elsif sADC0 > x"60" then --96
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
			elsif sADC0 > x"40" then --64
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
			elsif sADC0 > x"20" then --32
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
			else							-- 0
				lcdScreen(4)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(15 to 28) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(15 to 28) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");		
			end if;
		end if;
end process;

lineADC1:
process(CLK)
	begin
		if rising_edge(CLK) then
			if sADC1 > x"3E0" then	-- 992
				lcdScreen(4)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"3C0" then --960
				lcdScreen(4)(57 to 70) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"3A0" then --970
				lcdScreen(4)(57 to 70) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"380" then --896
				lcdScreen(4)(57 to 70) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"360" then --864
				lcdScreen(4)(57 to 70) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"340" then --832
				lcdScreen(4)(57 to 70) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"320" then --800
				lcdScreen(4)(57 to 70) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"300" then --768
				lcdScreen(4)(57 to 70) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"2E0" then --736
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"2C0" then --704
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"2A0" then --672
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"700" then --640
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"260" then --608
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"240" then --576
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"220" then --544
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"200" then --512
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"1E0" then --480
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"1C0" then --448
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"1A0" then --416
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"180" then --384
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"160" then --352
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"140" then --320
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"120" then --708
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"100" then --256
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"E0" then --224
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC1 > x"C0" then --192
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
			elsif sADC1 > x"A0" then --160
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
			elsif sADC1 > x"80" then --170
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
			elsif sADC1 > x"60" then --96
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
			elsif sADC1 > x"40" then --64
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
			elsif sADC1 > x"20" then --32
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
			else							-- 0
				lcdScreen(4)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(57 to 70) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(57 to 70) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");		
			end if;
		end if;
end process;

lineADC4:
process(CLK)
	begin
		if rising_edge(CLK) then
			if sADC4 > x"3E0" then	-- 992
				lcdScreen(4)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"3C0" then --960
				lcdScreen(4)(99 to 112) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"3A0" then --9112
				lcdScreen(4)(99 to 112) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"380" then --896
				lcdScreen(4)(99 to 112) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"360" then --864
				lcdScreen(4)(99 to 112) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"340" then --832
				lcdScreen(4)(99 to 112) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"320" then --800
				lcdScreen(4)(99 to 112) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"300" then --768
				lcdScreen(4)(99 to 112) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"2E0" then --736
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"2C0" then --1124
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"2A0" then --6112
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"1120" then --640
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"260" then --608
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"240" then --996
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"220" then --544
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"200" then --512
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"1E0" then --480
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"1C0" then --448
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"1A0" then --416
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"180" then --384
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"160" then --352
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"140" then --320
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"120" then --1128
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"100" then --256
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"E0" then --224
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF",x"FF");
			elsif sADC4 > x"C0" then --192
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE",x"FE");
			elsif sADC4 > x"A0" then --160
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC",x"FC");
			elsif sADC4 > x"80" then --1112
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8",x"F8");
			elsif sADC4 > x"60" then --96
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0",x"F0");
			elsif sADC4 > x"40" then --64
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0",x"E0");
			elsif sADC4 > x"20" then --32
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0",x"C0");
			else							-- 0
				lcdScreen(4)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(5)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(6)(99 to 112) <= (x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00");
				lcdScreen(7)(99 to 112) <= (x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80",x"80");		
			end if;
		end if;
end process;

end Behavioral;

