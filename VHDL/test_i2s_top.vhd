-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
          COMPONENT TOP
          PORT(
                  CLK : in  STD_LOGIC;
						
						  -- I2S PINS
						SDTI : in STD_LOGIC;
						SDTO : out  STD_LOGIC;
						BCLK : in  STD_LOGIC;
						LRCK : in  STD_LOGIC;
						  
						-- OTHERS
						  
						RESET : in STD_LOGIC);
						
          END COMPONENT;
			 
			 SIGNAL CLK : STD_LOGIC := '0';	
						  -- I2S PINS
				SIGNAL		SDTI : STD_LOGIC := '0';
				SIGNAL		SDTO : STD_LOGIC := '0';
				SIGNAL		BCLK : STD_LOGIC := '0';
				SIGNAL		LRCK : STD_LOGIC := '0';
						  
						-- OTHERS
						  
				SIGNAL		RESET : STD_LOGIC:= '0';
				
				constant BCLK_period : time := 160 ns;
				constant Val1d : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
				constant Val2d : STD_LOGIC_VECTOR(23 downto 0) := X"FFFFF0";
				constant Val3d : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
				
				constant Val1g : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
				constant Val2g : STD_LOGIC_VECTOR(23 downto 0) := x"700000";
				constant Val3g : STD_LOGIC_VECTOR(23 downto 0) := x"7F0000";

  BEGIN

 	-- Instantiate the Unit Under Test (UUT)
   uut: TOP PORT MAP (
			 CLK  => CLK,
          SDTI => SDTI,
          BCLK => BCLK,
          LRCK => LRCK,
          SDTO => SDTO,
          RESET => RESET
        );

   BCLK_process :process
   begin
		BCLK <= '0';
		wait for BCLK_period/2;
		BCLK <= '1';
		wait for BCLK_period/2;
   end process;

  --  Test Bench Statements
     tb : PROCESS
	  
	  variable compteur : integer := 24;
	  
     BEGIN
		RESET <= '0';
      -- hold reset state for 100 ns.
      wait for BCLK_period*1;
		
		RESET <= '1';
		SDTI <= '0';
		-- RIGHT CHANNEL 1
		
		LRCK <= '1';
		wait for BCLK_period*1;
		
		while compteur > 0 loop
			SDTI <=  Val1d(compteur - 1); 
			compteur := compteur - 1;
			wait for BCLK_period*1;
		end loop;
		SDTI <= '0';
		compteur := 24;
		wait for BCLK_period*7;
		
		-- LEFT CHANNEL 1
		
		LRCK <= '0';
		SDTI <= '0';
		wait for BCLK_period*1;
		
		while compteur > 0 loop
			SDTI <=  Val1g(compteur - 1) ;
			compteur := compteur - 1;
			wait for BCLK_period*1;
		end loop;
		SDTI <= '0';
		compteur := 24;
		wait for BCLK_period*7;
		
		-- RIGHT CHANNEL 2
		
		LRCK <= '1';
		SDTI <= '0';
		wait for BCLK_period*1;

		while compteur > 0 loop
			SDTI <=  Val2d(compteur - 1);
			compteur := compteur - 1;
			wait for BCLK_period*1;
		end loop;
		SDTI <= '0';
		compteur := 24;
		wait for BCLK_period*7;
		
		-- LEFT CHANNEL 2
		
		LRCK <= '0';
		SDTI <= '0';
		wait for BCLK_period*1;

		while compteur > 0 loop
			SDTI <=  Val2g(compteur - 1); 
			compteur := compteur - 1;
			wait for BCLK_period*1;
		end loop;
		SDTI <= '0';
		compteur := 24;
		wait for BCLK_period*7;
		
		-- RIGHT CHANNEL 3
		
		LRCK <= '1';
		SDTI <= '0';
		wait for BCLK_period*1;

		while compteur > 0 loop
			SDTI <=  Val3d(compteur - 1); 
			compteur := compteur - 1;
			wait for BCLK_period*1;
		end loop;
		SDTI <= '0';
		compteur := 24;
		wait for BCLK_period*7;
		
		
		-- LEFT CHANNEL 3
		
		LRCK <= '0';
		SDTI <= '0';
		wait for BCLK_period*1;

		while compteur > 0 loop
			SDTI <=  Val3g(compteur - 1); 
			compteur := compteur - 1;
			wait for BCLK_period*1;
		end loop;
		SDTI <= '0';
		compteur := 24;
		wait for BCLK_period*7;

      wait;
 
     END PROCESS tb;
  --  End Test Bench 

  END;
