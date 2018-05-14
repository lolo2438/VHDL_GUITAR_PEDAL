----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:42:35 05/03/2018 
-- Design Name: 
-- Module Name:    toneFirFilter - Behavioral 
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

entity toneFirFilter is
    Port ( CLK : in  STD_LOGIC;
           input : in  STD_LOGIC_VECTOR (23 downto 0);
			  tone : in  STD_LOGIC_VECTOR (9 downto 0);
           output : out  STD_LOGIC_VECTOR (23 downto 0)
			  );
end toneFirFilter;

architecture Behavioral of toneFirFilter is

type fifoArray is array(38 downto 1) of SIGNED(23 downto 0);
signal toneFir : fifoArray;

type FifoFirResultArray is array (38 downto 0) of SIGNED(55 downto 0);
signal FifoFirResult : FifoFirResultArray;

type FirCoefArray is array (38 downto 0) of SIGNED(31 downto 0);
signal FirCoef : FirCoefArray;

signal result : signed(92 downto 0) := (others => '0');

begin

--Special thanks to python for making this easy to generate

main:
process(CLK)
begin
	if rising_edge(CLK) then
		-- FIFO
		toneFir(38) <= toneFir(37);
		toneFir(37) <= toneFir(36);
		toneFir(36) <= toneFir(35);
		toneFir(35) <= toneFir(34);
		toneFir(34) <= toneFir(33);
		toneFir(33) <= toneFir(32);
		toneFir(32) <= toneFir(31);
		toneFir(31) <= toneFir(30);
		toneFir(30) <= toneFir(29);
		toneFir(29) <= toneFir(28);
		toneFir(28) <= toneFir(27);
		toneFir(27) <= toneFir(26);
		toneFir(26) <= toneFir(25);
		toneFir(25) <= toneFir(24);
		toneFir(24) <= toneFir(23);
		toneFir(23) <= toneFir(22);
		toneFir(22) <= toneFir(21);
		toneFir(21) <= toneFir(20);
		toneFir(20) <= toneFir(19);
		toneFir(19) <= toneFir(18);
		toneFir(18) <= toneFir(17);
		toneFir(17) <= toneFir(16);
		toneFir(16) <= toneFir(15);
		toneFir(15) <= toneFir(14);
		toneFir(14) <= toneFir(13);
		toneFir(13) <= toneFir(12);
		toneFir(12) <= toneFir(11);
		toneFir(11) <= toneFir(10);
		toneFir(10) <= toneFir(9);
		toneFir(9) <= toneFir(8);
		toneFir(8) <= toneFir(7);
		toneFir(7) <= toneFir(6);
		toneFir(6) <= toneFir(5);
		toneFir(5) <= toneFir(4);
		toneFir(4) <= toneFir(3);
		toneFir(3) <= toneFir(2);
		toneFir(2) <= toneFir(1);
		toneFir(1) <= signed(input);
		
		-- MULTIPLYING FIFO ITEMS BY FIR COEFICIENT
		FifoFirResult(38) <= toneFir(38) * FirCoef(38);
		FifoFirResult(37) <= toneFir(37) * FirCoef(37);
		FifoFirResult(36) <= toneFir(36) * FirCoef(36);
		FifoFirResult(35) <= toneFir(35) * FirCoef(35);
		FifoFirResult(34) <= toneFir(34) * FirCoef(34);
		FifoFirResult(33) <= toneFir(33) * FirCoef(33);
		FifoFirResult(32) <= toneFir(32) * FirCoef(32);
		FifoFirResult(31) <= toneFir(31) * FirCoef(31);
		FifoFirResult(30) <= toneFir(30) * FirCoef(30);
		FifoFirResult(29) <= toneFir(29) * FirCoef(29);
		FifoFirResult(28) <= toneFir(28) * FirCoef(28);
		FifoFirResult(27) <= toneFir(27) * FirCoef(27);
		FifoFirResult(26) <= toneFir(26) * FirCoef(26);
		FifoFirResult(25) <= toneFir(25) * FirCoef(25);
		FifoFirResult(24) <= toneFir(24) * FirCoef(24);
		FifoFirResult(23) <= toneFir(23) * FirCoef(23);
		FifoFirResult(22) <= toneFir(22) * FirCoef(22);
		FifoFirResult(21) <= toneFir(21) * FirCoef(21);
		FifoFirResult(20) <= toneFir(20) * FirCoef(20);
		FifoFirResult(19) <= toneFir(19) * FirCoef(19);
		FifoFirResult(18) <= toneFir(18) * FirCoef(18);
		FifoFirResult(17) <= toneFir(17) * FirCoef(17);
		FifoFirResult(16) <= toneFir(16) * FirCoef(16);
		FifoFirResult(15) <= toneFir(15) * FirCoef(15);
		FifoFirResult(14) <= toneFir(14) * FirCoef(14);
		FifoFirResult(13) <= toneFir(13) * FirCoef(13);
		FifoFirResult(12) <= toneFir(12) * FirCoef(12);
		FifoFirResult(11) <= toneFir(11) * FirCoef(11);
		FifoFirResult(10) <= toneFir(10) * FirCoef(10);
		FifoFirResult(9) <= toneFir(9) * FirCoef(9);
		FifoFirResult(8) <= toneFir(8) * FirCoef(8);
		FifoFirResult(7) <= toneFir(7) * FirCoef(7);
		FifoFirResult(6) <= toneFir(6) * FirCoef(6);
		FifoFirResult(5) <= toneFir(5) * FirCoef(5);
		FifoFirResult(4) <= toneFir(4) * FirCoef(4);
		FifoFirResult(3) <= toneFir(3) * FirCoef(3);
		FifoFirResult(2) <= toneFir(2) * FirCoef(2);
		FifoFirResult(1) <= toneFir(1) * FirCoef(1);
		FifoFirResult(0) <= signed(input) * FirCoef(0);
		
		result <=   ('0' & x"000000000" & FifoFirResult(38)) + 
						('0' & x"000000000" & FifoFirResult(37)) + 
						('0' & x"000000000" & FifoFirResult(36)) + 
						('0' & x"000000000" & FifoFirResult(35)) + 
						('0' & x"000000000" & FifoFirResult(34)) + 
						('0' & x"000000000" & FifoFirResult(33)) + 
						('0' & x"000000000" & FifoFirResult(32)) + 
						('0' & x"000000000" & FifoFirResult(31)) + 
						('0' & x"000000000" & FifoFirResult(30)) + 
						('0' & x"000000000" & FifoFirResult(29)) + 
						('0' & x"000000000" & FifoFirResult(28)) + 
						('0' & x"000000000" & FifoFirResult(27)) + 
						('0' & x"000000000" & FifoFirResult(26)) + 
						('0' & x"000000000" & FifoFirResult(25)) + 
						('0' & x"000000000" & FifoFirResult(24)) + 
						('0' & x"000000000" & FifoFirResult(23)) + 
						('0' & x"000000000" & FifoFirResult(22)) + 
						('0' & x"000000000" & FifoFirResult(21)) + 
						('0' & x"000000000" & FifoFirResult(20)) + 
						('0' & x"000000000" & FifoFirResult(19)) + 
						('0' & x"000000000" & FifoFirResult(18)) + 
						('0' & x"000000000" & FifoFirResult(17)) + 
						('0' & x"000000000" & FifoFirResult(16)) + 
						('0' & x"000000000" & FifoFirResult(15)) + 
						('0' & x"000000000" & FifoFirResult(14)) + 
						('0' & x"000000000" & FifoFirResult(13)) + 
						('0' & x"000000000" & FifoFirResult(12)) + 
						('0' & x"000000000" & FifoFirResult(11)) + 
						('0' & x"000000000" & FifoFirResult(10)) + 
						('0' & x"000000000" & FifoFirResult(9)) + 
						('0' & x"000000000" & FifoFirResult(8)) + 
						('0' & x"000000000" & FifoFirResult(7)) + 
						('0' & x"000000000" & FifoFirResult(6)) + 
						('0' & x"000000000" & FifoFirResult(5)) + 
						('0' & x"000000000" & FifoFirResult(4)) + 
						('0' & x"000000000" & FifoFirResult(3)) + 
						('0' & x"000000000" & FifoFirResult(2)) + 
						('0' & x"000000000" & FifoFirResult(1)) + 
						('0' & x"000000000" & FifoFirResult(0));
		
			if unsigned(tone) < 959	 then	
				output <= std_logic_vector(result(92 downto 69));
			else
				output <= input;
			end if;
		end if;
end process;

FirCoefficientSelector:
process(CLK)
begin
	if rising_edge(CLK) then
		if unsigned(tone) < 63 then	-- 1kHz cutoff
			FirCoef(0) <= x"00870110";
			FirCoef(1) <= x"00B912DB";
			FirCoef(2) <= x"00F312B1";
			FirCoef(3) <= x"01349BE8";
			FirCoef(4) <= x"017D1FE6";
			FirCoef(5) <= x"01CBAB64";
			FirCoef(6) <= x"021F3A57";
			FirCoef(7) <= x"0276640A";
			FirCoef(8) <= x"02CFBFC6";
			FirCoef(9) <= x"032990F3";
			FirCoef(10) <= x"03822BBE";
			FirCoef(11) <= x"03D7BA66";
			FirCoef(12) <= x"04286F8A";
			FirCoef(13) <= x"0472862F";
			FirCoef(14) <= x"04B46349";
			FirCoef(15) <= x"04EC7432";
			FirCoef(16) <= x"05198288";
			FirCoef(17) <= x"053A7978";
			FirCoef(18) <= x"054E9813";
			FirCoef(19) <= x"05555821";
			FirCoef(20) <= x"054E9813";
			FirCoef(21) <= x"053A7978";
			FirCoef(22) <= x"05198288";
			FirCoef(23) <= x"04EC7432";
			FirCoef(24) <= x"04B46349";
			FirCoef(25) <= x"0472862F";
			FirCoef(26) <= x"04286F8A";
			FirCoef(27) <= x"03D7BA66";
			FirCoef(28) <= x"03822BBE";
			FirCoef(29) <= x"032990F3";
			FirCoef(30) <= x"02CFBFC6";
			FirCoef(31) <= x"0276640A";
			FirCoef(32) <= x"021F3A57";
			FirCoef(33) <= x"01CBAB64";
			FirCoef(34) <= x"017D1FE6";
			FirCoef(35) <= x"01349BE8";
			FirCoef(36) <= x"00F312B1";
			FirCoef(37) <= x"00B912DB";
			FirCoef(38) <= x"00870110";

		elsif unsigned(tone) < 127 then -- 1.5kHz cutoff
			FirCoef(0) <= x"FF84CAD5";
			FirCoef(1) <= x"FF9BD406";
			FirCoef(2) <= x"FFC43B2D";
			FirCoef(3) <= x"00000000";
			FirCoef(4) <= x"00507A6B";
			FirCoef(5) <= x"00B61FE2";
			FirCoef(6) <= x"01306A2B";
			FirCoef(7) <= x"01BDC69F";
			FirCoef(8) <= x"025B9E8C";
			FirCoef(9) <= x"03065732";
			FirCoef(10) <= x"03B9841A";
			FirCoef(11) <= x"046FE718";
			FirCoef(12) <= x"0523E5B8";
			FirCoef(13) <= x"05CF91A3";
			FirCoef(14) <= x"066CFC82";
			FirCoef(15) <= x"06F69446";
			FirCoef(16) <= x"07675579";
			FirCoef(17) <= x"07BB0E5E";
			FirCoef(18) <= x"07EE99A6";
			FirCoef(19) <= x"08000000";
			FirCoef(20) <= x"07EE99A6";
			FirCoef(21) <= x"07BB0E5E";
			FirCoef(22) <= x"07675579";
			FirCoef(23) <= x"06F69446";
			FirCoef(24) <= x"066CFC82";
			FirCoef(25) <= x"05CF91A3";
			FirCoef(26) <= x"0523E5B8";
			FirCoef(27) <= x"046FE718";
			FirCoef(28) <= x"03B9841A";
			FirCoef(29) <= x"03065732";
			FirCoef(30) <= x"025B9E8C";
			FirCoef(31) <= x"01BDC69F";
			FirCoef(32) <= x"01306A2B";
			FirCoef(33) <= x"00B61FE2";
			FirCoef(34) <= x"00507A6B";
			FirCoef(35) <= x"00000000";
			FirCoef(36) <= x"FFC43B2D";
			FirCoef(37) <= x"FF9BD406";
			FirCoef(38) <= x"FF84CAD5";

		elsif unsigned(tone) < 191 then -- 2kHz cutoff
			FirCoef(0) <= x"FF29CBAB";
			FirCoef(1) <= x"FEFA4830";
			FirCoef(2) <= x"FED8127B";
			FirCoef(3) <= x"FECB6417";
			FirCoef(4) <= x"FEDC4C9C";
			FirCoef(5) <= x"FF1209ED";
			FirCoef(6) <= x"FF722E1A";
			FirCoef(7) <= x"00000000";
			FirCoef(8) <= x"00BBE447";
			FirCoef(9) <= x"01A311E8";
			FirCoef(10) <= x"02AF709B";
			FirCoef(11) <= x"03D7BA66";
			FirCoef(12) <= x"050FF972";
			FirCoef(13) <= x"064A1F08";
			FirCoef(14) <= x"0776FF3A";
			FirCoef(15) <= x"08873365";
			FirCoef(16) <= x"096C4827";
			FirCoef(17) <= x"0A19C172";
			FirCoef(18) <= x"0A85EC3D";
			FirCoef(19) <= x"0AAAA7DE";
			FirCoef(20) <= x"0A85EC3D";
			FirCoef(21) <= x"0A19C172";
			FirCoef(22) <= x"096C4827";
			FirCoef(23) <= x"08873365";
			FirCoef(24) <= x"0776FF3A";
			FirCoef(25) <= x"064A1F08";
			FirCoef(26) <= x"050FF972";
			FirCoef(27) <= x"03D7BA66";
			FirCoef(28) <= x"02AF709B";
			FirCoef(29) <= x"01A311E8";
			FirCoef(30) <= x"00BBE447";
			FirCoef(31) <= x"00000000";
			FirCoef(32) <= x"FF722E1A";
			FirCoef(33) <= x"FF1209ED";
			FirCoef(34) <= x"FEDC4C9C";
			FirCoef(35) <= x"FECB6417";
			FirCoef(36) <= x"FED8127B";
			FirCoef(37) <= x"FEFA4830";
			FirCoef(38) <= x"FF29CBAB";
			
		elsif unsigned(tone) < 255 then -- 2.5kHz cutoff
			FirCoef(0) <= x"FFF17BD8";
			FirCoef(1) <= x"FF9BD406";
			FirCoef(2) <= x"FF35FC3B";
			FirCoef(3) <= x"FECB6417";
			FirCoef(4) <= x"FE6B69DB";
			FirCoef(5) <= x"FE282C6E";
			FirCoef(6) <= x"FE149C6F";
			FirCoef(7) <= x"FE423960";
			FirCoef(8) <= x"FEBEE807";
			FirCoef(9) <= x"FF929670";
			FirCoef(10) <= x"00BDA943";
			FirCoef(11) <= x"0237F7BE";
			FirCoef(12) <= x"03F0BAE8";
			FirCoef(13) <= x"05CF91A3";
			FirCoef(14) <= x"07B62C77";
			FirCoef(15) <= x"09830E3C";
			FirCoef(16) <= x"0B148FD9";
			FirCoef(17) <= x"0C4C37E6";
			FirCoef(18) <= x"0D11B60A";
			FirCoef(19) <= x"0D555821";
			FirCoef(20) <= x"0D11B60A";
			FirCoef(21) <= x"0C4C37E6";
			FirCoef(22) <= x"0B148FD9";
			FirCoef(23) <= x"09830E3C";
			FirCoef(24) <= x"07B62C77";
			FirCoef(25) <= x"05CF91A3";
			FirCoef(26) <= x"03F0BAE8";
			FirCoef(27) <= x"0237F7BE";
			FirCoef(28) <= x"00BDA943";
			FirCoef(29) <= x"FF929670";
			FirCoef(30) <= x"FEBEE807";
			FirCoef(31) <= x"FE423960";
			FirCoef(32) <= x"FE149C6F";
			FirCoef(33) <= x"FE282C6E";
			FirCoef(34) <= x"FE6B69DB";
			FirCoef(35) <= x"FECB6417";
			FirCoef(36) <= x"FF35FC3B";
			FirCoef(37) <= x"FF9BD406";
			FirCoef(38) <= x"FFF17BD8";
			
		elsif unsigned(tone) < 319 then -- 3kHz cutoff
			FirCoef(0) <= x"00CCDD93";
			FirCoef(1) <= x"00B912DB";
			FirCoef(2) <= x"00753E70";
			FirCoef(3) <= x"00000000";
			FirCoef(4) <= x"FF621FAF";
			FirCoef(5) <= x"FEAF78FE";
			FirCoef(6) <= x"FE05CCC8";
			FirCoef(7) <= x"FD899BF5";
			FirCoef(8) <= x"FD614DF8";
			FirCoef(9) <= x"FDAF5BA2";
			FirCoef(10) <= x"FE8BF3BE";
			FirCoef(11) <= x"00000000";
			FirCoef(12) <= x"02017119";
			FirCoef(13) <= x"0472862F";
			FirCoef(14) <= x"0723CC8D";
			FirCoef(15) <= x"09D8F0C7";
			FirCoef(16) <= x"0C4FD2A6";
			FirCoef(17) <= x"0E48CF7C";
			FirCoef(18) <= x"0F8F25A2";
			FirCoef(19) <= x"10000000";
			FirCoef(20) <= x"0F8F25A2";
			FirCoef(21) <= x"0E48CF7C";
			FirCoef(22) <= x"0C4FD2A6";
			FirCoef(23) <= x"09D8F0C7";
			FirCoef(24) <= x"0723CC8D";
			FirCoef(25) <= x"0472862F";
			FirCoef(26) <= x"02017119";
			FirCoef(27) <= x"00000000";
			FirCoef(28) <= x"FE8BF3BE";
			FirCoef(29) <= x"FDAF5BA2";
			FirCoef(30) <= x"FD614DF8";
			FirCoef(31) <= x"FD899BF5";
			FirCoef(32) <= x"FE05CCC8";
			FirCoef(33) <= x"FEAF78FE";
			FirCoef(34) <= x"FF621FAF";
			FirCoef(35) <= x"00000000";
			FirCoef(36) <= x"00753E70";
			FirCoef(37) <= x"00B912DB";
			FirCoef(38) <= x"00CCDD93";
			
		elsif unsigned(tone) < 383 then -- 3.5kHz cutoff
			FirCoef(0) <= x"009235F8";
			FirCoef(1) <= x"00F1CB89";
			FirCoef(2) <= x"0131B9B6";
			FirCoef(3) <= x"01349BE8";
			FirCoef(4) <= x"00E52DEC";
			FirCoef(5) <= x"003E20CC";
			FirCoef(6) <= x"FF4FDF3B";
			FirCoef(7) <= x"FE423960";
			FirCoef(8) <= x"FD5097C8";
			FirCoef(9) <= x"FCC1094A";
			FirCoef(10) <= x"FCD7A56D";
			FirCoef(11) <= x"FDC80841";
			FirCoef(12) <= x"FFA83F4E";
			FirCoef(13) <= x"02682B62";
			FirCoef(14) <= x"05CF7015";
			FirCoef(15) <= x"09830E3C";
			FirCoef(16) <= x"0D11F0C3";
			FirCoef(17) <= x"1006D938";
			FirCoef(18) <= x"11FB9389";
			FirCoef(19) <= x"12AAA7DE";
			FirCoef(20) <= x"11FB9389";
			FirCoef(21) <= x"1006D938";
			FirCoef(22) <= x"0D11F0C3";
			FirCoef(23) <= x"09830E3C";
			FirCoef(24) <= x"05CF7015";
			FirCoef(25) <= x"02682B62";
			FirCoef(26) <= x"FFA83F4E";
			FirCoef(27) <= x"FDC80841";
			FirCoef(28) <= x"FCD7A56D";
			FirCoef(29) <= x"FCC1094A";
			FirCoef(30) <= x"FD5097C8";
			FirCoef(31) <= x"FE423960";
			FirCoef(32) <= x"FF4FDF3B";
			FirCoef(33) <= x"003E20CC";
			FirCoef(34) <= x"00E52DEC";
			FirCoef(35) <= x"01349BE8";
			FirCoef(36) <= x"0131B9B6";
			FirCoef(37) <= x"00F1CB89";
			FirCoef(38) <= x"009235F8";
			
		elsif unsigned(tone) < 447 then -- 4kHz cutoff
			FirCoef(0) <= x"00CCDD93";
			FirCoef(1) <= x"00B912DB";
			FirCoef(2) <= x"00753E70";
			FirCoef(3) <= x"00000000";
			FirCoef(4) <= x"FF621FAF";
			FirCoef(5) <= x"FEAF78FE";
			FirCoef(6) <= x"FE05CCC8";
			FirCoef(7) <= x"FD899BF5";
			FirCoef(8) <= x"FD614DF8";
			FirCoef(9) <= x"FDAF5BA2";
			FirCoef(10) <= x"FE8BF3BE";
			FirCoef(11) <= x"00000000";
			FirCoef(12) <= x"02017119";
			FirCoef(13) <= x"0472862F";
			FirCoef(14) <= x"0723CC8D";
			FirCoef(15) <= x"09D8F0C7";
			FirCoef(16) <= x"0C4FD2A6";
			FirCoef(17) <= x"0E48CF7C";
			FirCoef(18) <= x"0F8F25A2";
			FirCoef(19) <= x"10000000";
			FirCoef(20) <= x"0F8F25A2";
			FirCoef(21) <= x"0E48CF7C";
			FirCoef(22) <= x"0C4FD2A6";
			FirCoef(23) <= x"09D8F0C7";
			FirCoef(24) <= x"0723CC8D";
			FirCoef(25) <= x"0472862F";
			FirCoef(26) <= x"02017119";
			FirCoef(27) <= x"00000000";
			FirCoef(28) <= x"FE8BF3BE";
			FirCoef(29) <= x"FDAF5BA2";
			FirCoef(30) <= x"FD614DF8";
			FirCoef(31) <= x"FD899BF5";
			FirCoef(32) <= x"FE05CCC8";
			FirCoef(33) <= x"FEAF78FE";
			FirCoef(34) <= x"FF621FAF";
			FirCoef(35) <= x"00000000";
			FirCoef(36) <= x"00753E70";
			FirCoef(37) <= x"00B912DB";
			FirCoef(38) <= x"00CCDD93";
			
		elsif unsigned(tone) < 511 then -- 4.5kHz cutoff
			FirCoef(0) <= x"FF2684CF";
			FirCoef(1) <= x"FF0E3476";
			FirCoef(2) <= x"FF55C52E";
			FirCoef(3) <= x"00000000";
			FirCoef(4) <= x"00E52DEC";
			FirCoef(5) <= x"01B7AE57";
			FirCoef(6) <= x"02195CC8";
			FirCoef(7) <= x"01BDC69F";
			FirCoef(8) <= x"008D9F90";
			FirCoef(9) <= x"FEBF444E";
			FirCoef(10) <= x"FCD7A56D";
			FirCoef(11) <= x"FB9018E7";
			FirCoef(12) <= x"FBA469D7";
			FirCoef(13) <= x"FD97D49D";
			FirCoef(14) <= x"0181F969";
			FirCoef(15) <= x"06F69446";
			FirCoef(16) <= x"0D11F0C3";
			FirCoef(17) <= x"12A9DE8B";
			FirCoef(18) <= x"1696AAD1";
			FirCoef(19) <= x"18000000";
			FirCoef(20) <= x"1696AAD1";
			FirCoef(21) <= x"12A9DE8B";
			FirCoef(22) <= x"0D11F0C3";
			FirCoef(23) <= x"06F69446";
			FirCoef(24) <= x"0181F969";
			FirCoef(25) <= x"FD97D49D";
			FirCoef(26) <= x"FBA469D7";
			FirCoef(27) <= x"FB9018E7";
			FirCoef(28) <= x"FCD7A56D";
			FirCoef(29) <= x"FEBF444E";
			FirCoef(30) <= x"008D9F90";
			FirCoef(31) <= x"01BDC69F";
			FirCoef(32) <= x"02195CC8";
			FirCoef(33) <= x"01B7AE57";
			FirCoef(34) <= x"00E52DEC";
			FirCoef(35) <= x"00000000";
			FirCoef(36) <= x"FF55C52E";
			FirCoef(37) <= x"FF0E3476";
			FirCoef(38) <= x"FF2684CF";

		elsif unsigned(tone) < 575 then -- 5kHz cutoff
			FirCoef(0) <= x"FFE310DB";
			FirCoef(1) <= x"FF46ED24";
			FirCoef(2) <= x"FED03D9A";
			FirCoef(3) <= x"FECB6417";
			FirCoef(4) <= x"FF621FAF";
			FirCoef(5) <= x"007B2CC7";
			FirCoef(6) <= x"01B2AAE2";
			FirCoef(7) <= x"0276640A";
			FirCoef(8) <= x"023FEE2C";
			FirCoef(9) <= x"00D8EC95";
			FirCoef(10) <= x"FE8BF3BE";
			FirCoef(11) <= x"FC284599";
			FirCoef(12) <= x"FACDC875";
			FirCoef(13) <= x"FB8D79D0";
			FirCoef(14) <= x"FEFDC161";
			FirCoef(15) <= x"04EC7432";
			FirCoef(16) <= x"0C4FD2A6";
			FirCoef(17) <= x"138348F5";
			FirCoef(18) <= x"18C0485A";
			FirCoef(19) <= x"1AAAA7DE";
			FirCoef(20) <= x"18C0485A";
			FirCoef(21) <= x"138348F5";
			FirCoef(22) <= x"0C4FD2A6";
			FirCoef(23) <= x"04EC7432";
			FirCoef(24) <= x"FEFDC161";
			FirCoef(25) <= x"FB8D79D0";
			FirCoef(26) <= x"FACDC875";
			FirCoef(27) <= x"FC284599";
			FirCoef(28) <= x"FE8BF3BE";
			FirCoef(29) <= x"00D8EC95";
			FirCoef(30) <= x"023FEE2C";
			FirCoef(31) <= x"0276640A";
			FirCoef(32) <= x"01B2AAE2";
			FirCoef(33) <= x"007B2CC7";
			FirCoef(34) <= x"FF621FAF";
			FirCoef(35) <= x"FECB6417";
			FirCoef(36) <= x"FED03D9A";
			FirCoef(37) <= x"FF46ED24";
			FirCoef(38) <= x"FFE310DB";

		elsif unsigned(tone) < 639 then -- 5.5kHz cutoff
			FirCoef(0) <= x"00C6E6D9";
			FirCoef(1) <= x"00642BF9";
			FirCoef(2) <= x"FF9D883B";
			FirCoef(3) <= x"FECB6417";
			FirCoef(4) <= x"FE6B69DB";
			FirCoef(5) <= x"FEDE4C51";
			FirCoef(6) <= x"0023D923";
			FirCoef(7) <= x"01BDC69F";
			FirCoef(8) <= x"02D466F5";
			FirCoef(9) <= x"0298EDA2";
			FirCoef(10) <= x"00BDA943";
			FirCoef(11) <= x"FDC80841";
			FirCoef(12) <= x"FB0984E3";
			FirCoef(13) <= x"FA306E5C";
			FirCoef(14) <= x"FC94F69C";
			FirCoef(15) <= x"028C79F6";
			FirCoef(16) <= x"0B148FD9";
			FirCoef(17) <= x"14074645";
			FirCoef(18) <= x"1ACECC81";
			FirCoef(19) <= x"1D555821";
			FirCoef(20) <= x"1ACECC81";
			FirCoef(21) <= x"14074645";
			FirCoef(22) <= x"0B148FD9";
			FirCoef(23) <= x"028C79F6";
			FirCoef(24) <= x"FC94F69C";
			FirCoef(25) <= x"FA306E5C";
			FirCoef(26) <= x"FB0984E3";
			FirCoef(27) <= x"FDC80841";
			FirCoef(28) <= x"00BDA943";
			FirCoef(29) <= x"0298EDA2";
			FirCoef(30) <= x"02D466F5";
			FirCoef(31) <= x"01BDC69F";
			FirCoef(32) <= x"0023D923";
			FirCoef(33) <= x"FEDE4C51";
			FirCoef(34) <= x"FE6B69DB";
			FirCoef(35) <= x"FECB6417";
			FirCoef(36) <= x"FF9D883B";
			FirCoef(37) <= x"00642BF9";
			FirCoef(38) <= x"00C6E6D9";

		elsif unsigned(tone) < 703 then -- 6kHz cutoff
			FirCoef(0) <= x"009CCB7D";
			FirCoef(1) <= x"0105B7CF";
			FirCoef(2) <= x"00D8A116";
			FirCoef(3) <= x"00000000";
			FirCoef(4) <= x"FEDC4C9C";
			FirCoef(5) <= x"FE241C3E";
			FirCoef(6) <= x"FE7C957C";
			FirCoef(7) <= x"00000000";
			FirCoef(8) <= x"02014F8B";
			FirCoef(9) <= x"034623D0";
			FirCoef(10) <= x"02AF709B";
			FirCoef(11) <= x"00000000";
			FirCoef(12) <= x"FC4B44A1";
			FirCoef(13) <= x"F9B5E0F7";
			FirCoef(14) <= x"FA89118C";
			FirCoef(15) <= x"00000000";
			FirCoef(16) <= x"096C4827";
			FirCoef(17) <= x"143382E4";
			FirCoef(18) <= x"1CBFEC13";
			FirCoef(19) <= x"20000000";
			FirCoef(20) <= x"1CBFEC13";
			FirCoef(21) <= x"143382E4";
			FirCoef(22) <= x"096C4827";
			FirCoef(23) <= x"00000000";
			FirCoef(24) <= x"FA89118C";
			FirCoef(25) <= x"F9B5E0F7";
			FirCoef(26) <= x"FC4B44A1";
			FirCoef(27) <= x"00000000";
			FirCoef(28) <= x"02AF709B";
			FirCoef(29) <= x"034623D0";
			FirCoef(30) <= x"02014F8B";
			FirCoef(31) <= x"00000000";
			FirCoef(32) <= x"FE7C957C";
			FirCoef(33) <= x"FE241C3E";
			FirCoef(34) <= x"FEDC4C9C";
			FirCoef(35) <= x"00000000";
			FirCoef(36) <= x"00D8A116";
			FirCoef(37) <= x"0105B7CF";
			FirCoef(38) <= x"009CCB7D";
			
		elsif unsigned(tone) < 767 then -- 6.5kHz cutoff
			FirCoef(0) <= x"FF9DECE5";
			FirCoef(1) <= x"00642BF9";
			FirCoef(2) <= x"012220BC";
			FirCoef(3) <= x"01349BE8";
			FirCoef(4) <= x"00507A6B";
			FirCoef(5) <= x"FEDE4C51";
			FirCoef(6) <= x"FDDD4413";
			FirCoef(7) <= x"FE423960";
			FirCoef(8) <= x"002F7B17";
			FirCoef(9) <= x"0298EDA2";
			FirCoef(10) <= x"03B9841A";
			FirCoef(11) <= x"0237F7BE";
			FirCoef(12) <= x"FE50BD87";
			FirCoef(13) <= x"FA306E5C";
			FirCoef(14) <= x"F9119CE0";
			FirCoef(15) <= x"FD738609";
			FirCoef(16) <= x"07675579";
			FirCoef(17) <= x"14074645";
			FirCoef(18) <= x"1E9185CE";
			FirCoef(19) <= x"22AAA7DE";
			FirCoef(20) <= x"1E9185CE";
			FirCoef(21) <= x"14074645";
			FirCoef(22) <= x"07675579";
			FirCoef(23) <= x"FD738609";
			FirCoef(24) <= x"F9119CE0";
			FirCoef(25) <= x"FA306E5C";
			FirCoef(26) <= x"FE50BD87";
			FirCoef(27) <= x"0237F7BE";
			FirCoef(28) <= x"03B9841A";
			FirCoef(29) <= x"0298EDA2";
			FirCoef(30) <= x"002F7B17";
			FirCoef(31) <= x"FE423960";
			FirCoef(32) <= x"FDDD4413";
			FirCoef(33) <= x"FEDE4C51";
			FirCoef(34) <= x"00507A6B";
			FirCoef(35) <= x"01349BE8";
			FirCoef(36) <= x"012220BC";
			FirCoef(37) <= x"00642BF9";
			FirCoef(38) <= x"FF9DECE5";

		elsif unsigned(tone) < 831 then -- 7kHz cutoff
			FirCoef(0) <= x"FF242070";
			FirCoef(1) <= x"FF46ED24";
			FirCoef(2) <= x"0027FA1A";
			FirCoef(3) <= x"01349BE8";
			FirCoef(4) <= x"017D1FE6";
			FirCoef(5) <= x"007B2CC7";
			FirCoef(6) <= x"FEB2745B";
			FirCoef(7) <= x"FD899BF5";
			FirCoef(8) <= x"FE460ED8";
			FirCoef(9) <= x"00D8EC95";
			FirCoef(10) <= x"03822BBE";
			FirCoef(11) <= x"03D7BA66";
			FirCoef(12) <= x"00AF1CB8";
			FirCoef(13) <= x"FB8D79D0";
			FirCoef(14) <= x"F8568A50";
			FirCoef(15) <= x"FB138BCD";
			FirCoef(16) <= x"05198288";
			FirCoef(17) <= x"138348F5";
			FirCoef(18) <= x"204199FE";
			FirCoef(19) <= x"25555821";
			FirCoef(20) <= x"204199FE";
			FirCoef(21) <= x"138348F5";
			FirCoef(22) <= x"05198288";
			FirCoef(23) <= x"FB138BCD";
			FirCoef(24) <= x"F8568A50";
			FirCoef(25) <= x"FB8D79D0";
			FirCoef(26) <= x"00AF1CB8";
			FirCoef(27) <= x"03D7BA66";
			FirCoef(28) <= x"03822BBE";
			FirCoef(29) <= x"00D8EC95";
			FirCoef(30) <= x"FE460ED8";
			FirCoef(31) <= x"FD899BF5";
			FirCoef(32) <= x"FEB2745B";
			FirCoef(33) <= x"007B2CC7";
			FirCoef(34) <= x"017D1FE6";
			FirCoef(35) <= x"01349BE8";
			FirCoef(36) <= x"0027FA1A";
			FirCoef(37) <= x"FF46ED24";
			FirCoef(38) <= x"FF242070";

		elsif unsigned(tone) < 895 then -- 7.5kHz cutoff
			FirCoef(0) <= x"FFD4BF09";
			FirCoef(1) <= x"FF0E3476";
			FirCoef(2) <= x"FF0142F6";
			FirCoef(3) <= x"00000000";
			FirCoef(4) <= x"0156FB8F";
			FirCoef(5) <= x"01B7AE57";
			FirCoef(6) <= x"006AE3A3";
			FirCoef(7) <= x"FE423960";
			FirCoef(8) <= x"FD380453";
			FirCoef(9) <= x"FEBF444E";
			FirCoef(10) <= x"021C1D6C";
			FirCoef(11) <= x"046FE718";
			FirCoef(12) <= x"02E9680E";
			FirCoef(13) <= x"FD97D49D";
			FirCoef(14) <= x"F86B9C30";
			FirCoef(15) <= x"F9096BB9";
			FirCoef(16) <= x"02998D04";
			FirCoef(17) <= x"12A9DE8B";
			FirCoef(18) <= x"21CE5B42";
			FirCoef(19) <= x"28000000";
			FirCoef(20) <= x"21CE5B42";
			FirCoef(21) <= x"12A9DE8B";
			FirCoef(22) <= x"02998D04";
			FirCoef(23) <= x"F9096BB9";
			FirCoef(24) <= x"F86B9C30";
			FirCoef(25) <= x"FD97D49D";
			FirCoef(26) <= x"02E9680E";
			FirCoef(27) <= x"046FE718";
			FirCoef(28) <= x"021C1D6C";
			FirCoef(29) <= x"FEBF444E";
			FirCoef(30) <= x"FD380453";
			FirCoef(31) <= x"FE423960";
			FirCoef(32) <= x"006AE3A3";
			FirCoef(33) <= x"01B7AE57";
			FirCoef(34) <= x"0156FB8F";
			FirCoef(35) <= x"00000000";
			FirCoef(36) <= x"FF0142F6";
			FirCoef(37) <= x"FF0E3476";
			FirCoef(38) <= x"FFD4BF09";

		elsif unsigned(tone) < 959 then -- 8kHz cutoff
			FirCoef(0) <= x"00C00DA1";
			FirCoef(1) <= x"00000000";
			FirCoef(2) <= x"FEF6AD70";
			FirCoef(3) <= x"FECB6417";
			FirCoef(4) <= x"00000000";
			FirCoef(5) <= x"019C27E9";
			FirCoef(6) <= x"01DA836E";
			FirCoef(7) <= x"00000000";
			FirCoef(8) <= x"FD8B502A";
			FirCoef(9) <= x"FD2A27F1";
			FirCoef(10) <= x"00000000";
			FirCoef(11) <= x"03D7BA66";
			FirCoef(12) <= x"0489EBA6";
			FirCoef(13) <= x"00000000";
			FirCoef(14) <= x"F94EA8DA";
			FirCoef(15) <= x"F778CC9A";
			FirCoef(16) <= x"00000000";
			FirCoef(17) <= x"117EAA2A";
			FirCoef(18) <= x"2336049E";
			FirCoef(19) <= x"2AAAA7DE";
			FirCoef(20) <= x"2336049E";
			FirCoef(21) <= x"117EAA2A";
			FirCoef(22) <= x"00000000";
			FirCoef(23) <= x"F778CC9A";
			FirCoef(24) <= x"F94EA8DA";
			FirCoef(25) <= x"00000000";
			FirCoef(26) <= x"0489EBA6";
			FirCoef(27) <= x"03D7BA66";
			FirCoef(28) <= x"00000000";
			FirCoef(29) <= x"FD2A27F1";
			FirCoef(30) <= x"FD8B502A";
			FirCoef(31) <= x"00000000";
			FirCoef(32) <= x"01DA836E";
			FirCoef(33) <= x"019C27E9";
			FirCoef(34) <= x"00000000";
			FirCoef(35) <= x"FECB6417";
			FirCoef(36) <= x"FEF6AD70";
			FirCoef(37) <= x"00000000";
			FirCoef(38) <= x"00C0053E";
		end if;
	end if;
end process;

end Behavioral;

