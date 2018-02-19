----------------------------------------------------------------------------------
-- Anti_Rebond
-- 
-- Auteur: Jasmin St-Laurent
-- Date de création:    20:21:30 04/07/2015
--
-- Collège de Maisonneuve - 243-410 - Application des circuits programmables
--
-- Ce circuit élimine le rebond que peuvent avoir des boutons poussoirs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.log2;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.round;


entity Anti_Rebond is
	Generic ( 
		-- Durée en millisecondes pendant laquelle le signal Bouton doit rester stable avant 
		-- que la sortie du module ne change
		REBOND_MS : REAL := 10.0;			
		PERIODE_HORLOGE_NS : REAL := 20.0	-- Période du signal Horloge en nanosecondes
	);
    Port ( 
    	Bouton : in  STD_LOGIC;		-- Bouton avec rebond
        Sortie : out  STD_LOGIC;	-- Bouton avec rebond supprimé
        Horloge : in  STD_LOGIC		-- Horloge pour ce module
    );
end Anti_Rebond;


architecture Behavioral of Anti_Rebond is
	
	-- État du module Anti-Rebond
	type Etat_Type is (BAS, HAUT, ATTENTE_BAS, ATTENTE_HAUT);
	signal Etat, Etat_Suivant : Etat_Type;
	
	-- Nombre réel contenant le nombre de cycles d'horloge équivalent à REBOND_MS
	constant PERIODE_COMPTEUR_REAL : REAL := round(1_000_000.0*REBOND_MS/PERIODE_HORLOGE_NS);
	
	-- Nombre de bit que doit avoir le compteur pour compter pendant un temps équivalent à REBOND_MS
	constant NB_BITS_COMPTEUR : NATURAL := natural(ceil(log2(PERIODE_COMPTEUR_REAL)));
	
	-- Nombre non signé équivalent à PERIODE_COMPTEUR_REAL
	constant PERIODE_COMPTEUR : UNSIGNED := to_unsigned(natural(PERIODE_COMPTEUR_REAL), NB_BITS_COMPTEUR);
	
	-- Compteur servant à mesurer le temps écoulé depuis le changement de niveau du signal Bouton
	signal Compteur, Compteur_Suivant : UNSIGNED(NB_BITS_COMPTEUR -1 downto 0);

begin

	-- Processus séquentiel - Actualisation des signaux lors du front montant de l'horloge
	process(Horloge)
	begin
		if rising_edge(Horloge) then
			Etat <= Etat_Suivant;
			Compteur <= Compteur_Suivant;
		end if;
	end process;
	
	
	-- Processus combinatoire
	-- Détermine l'état suivant, la valeur suivante du compteur et le niveau de la sortie
	process(Etat, Compteur, Bouton)
	begin
		-- Par défaut les signaux Etat et Compteur gardent leur valeur actuelle
		Etat_Suivant <= Etat;
		Compteur_Suivant <= Compteur;
		
		case Etat is 
			
			when BAS =>
				if Bouton = '1' then
					Etat_Suivant <= ATTENTE_HAUT;
					Compteur_Suivant <= PERIODE_COMPTEUR;
				end if;
				
				Sortie <= '0';
				
			when HAUT =>
				if Bouton = '0' then
					Etat_Suivant <= ATTENTE_BAS;
					Compteur_Suivant <= PERIODE_COMPTEUR;
				end if;
				
				Sortie <= '1';
				
			when ATTENTE_BAS =>
				Compteur_Suivant <= Compteur - 1;
				
				if Compteur = 0 then
					Etat_Suivant <= BAS;
				elsif Bouton = '1' then
					Etat_Suivant <= HAUT;
				end if;
				
				Sortie <= '1';
				
			when ATTENTE_HAUT =>
				Compteur_Suivant <= Compteur - 1;
				
				if Compteur = 0 then
					Etat_Suivant <= HAUT;
				elsif Bouton = '0' then
					Etat_Suivant <= BAS;
				end if;
				
				Sortie <= '0';
				
		end case;
		
	end process;
		
end Behavioral;

