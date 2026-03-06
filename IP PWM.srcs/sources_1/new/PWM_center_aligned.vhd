----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 18:23:53
-- Design Name: PWM Center-Aligned (Alignement Central)
-- Module Name: PWM_center_aligned - Behavioral
-- Project Name: IP PWM
-- Target Devices: FPGA AMD / Générique
-- Description: 
--    Génère un signal PWM où l'impulsion est centrée sur la période.
--    Le compteur interne effectue un cycle triangulaire (0 -> Max -> 0).
--    Ce mode est particulièrement recommandé pour le pilotage de moteurs 
--    afin de limiter les harmoniques de courant.
-- 
-- Revision:
-- Revision 0.01 - File Created (06.03.2026)
-- Additional Comments:
--    Ce module implémente un compteur triangulaire (Up-Down). 
--    Contrairement au PWM classique (Edge-Aligned), le mode Center-Aligned 
--    double la fréquence de commutation apparente tout en gardant une 
--    fréquence de cycle fixe, ce qui réduit l'ondulation du courant 
--    dans les charges inductives comme les moteurs CC.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Nécessaire pour les opérations arithmétiques

entity PWM_center_aligned is
    generic (
        SYS_FREQ    : integer := 100_000_000; -- Fréquence horloge (100 MHz)
        PWM_FREQ    : integer := 10_000       -- Fréquence PWM souhaitée (10 kHz)
    );
    Port ( 
        Clk     : in  STD_LOGIC;
        nReset  : in  STD_LOGIC;
        Duty_In : in  STD_LOGIC_VECTOR (7 downto 0); -- Rapport cyclique 0-255
        PWM_Out : out STD_LOGIC
    );
end PWM_center_aligned;

architecture Behavioral of PWM_center_aligned is
    -- Pour un PWM centré, le compteur monte jusqu'à la moitié de la période
    constant HALF_PERIOD : integer := SYS_FREQ / (2 * PWM_FREQ);
    
    -- Signaux internes
    signal counter : integer range 0 to HALF_PERIOD := 0;
    signal up_down : std_logic := '1'; -- '1' pour incrémenter, '0' pour décrémenter
begin

    -- Processus principal : Gestion du compteur triangulaire et de la sortie
    process(Clk, nReset)
        variable threshold : integer;
    begin
        if nReset = '0' then
            counter <= 0;
            up_down <= '1';
            PWM_Out <= '0';
        elsif rising_edge(Clk) then
            
            -- 1. Logique du compteur Up-Down (Triangle)
            if up_down = '1' then
                if counter >= HALF_PERIOD - 1 then
                    up_down <= '0'; -- On a atteint le sommet, on redescend
                else
                    counter <= counter + 1;
                end if;
            else
                if counter <= 1 then
                    up_down <= '1'; -- On est en bas, on remonte
                else
                    counter <= counter - 1;
                end if;
            end if;

            -- 2. Calcul du seuil de comparaison
            -- On convertit le Duty_In (0-255) en une valeur proportionnelle à HALF_PERIOD
            threshold := (to_integer(unsigned(Duty_In)) * HALF_PERIOD) / 255;
            
            -- 3. Génération du signal PWM
            -- La sortie est à '1' quand le compteur est en dessous du seuil
            if counter < threshold then
                PWM_Out <= '1';
            else
                PWM_Out <= '0';
            end if;
            
        end if;
    end process;

end Behavioral;