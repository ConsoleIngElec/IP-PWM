----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 17:40:05
-- Design Name: IP PWM Multi-Canaux Paramétrable
-- Module Name: PWM_multi_channels - Behavioral
-- Project Name: IP PWM
-- Target Devices: FPGA (Générique)
-- Tool Versions: Vivado 2018.3 / 2023.x
-- Description: 
--    Générateur PWM multi-canaux avec nombre de sorties (N) paramétrable via 
--    un generic. Chaque canal possède son propre registre de rapport cyclique 
--    indépendant. 
--    L'architecture utilise un compteur unique partagé pour optimiser les 
--    ressources logiques (Area optimization).
-- 
-- Dependencies: 
--    - PWM_pkg.vhd (nécessaire pour le type tableau duty_array)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--    L'implémentation utilise la directive VHDL 'GENERATE' pour instancier 
--    automatiquement les N comparateurs. Le rapport cyclique est codé sur 8 bits.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Définition d'un type tableau pour les entrées de rapport cyclique
package PWM_pkg is
    type duty_array is array (natural range <>) of unsigned(7 downto 0);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.PWM_pkg.all;

entity PWM_multi_channels is
    generic (
        NB_CHANNELS : integer := 4;  -- Nombre de canaux (N)
        SYS_FREQ    : integer := 100000000; -- 100 MHz
        PWM_FREQ    : integer := 10000      -- 10 kHz
    );
    port (
        Clk       : in  std_logic;
        nReset    : in  std_logic;
        -- Tableau d'entrées : une valeur de 8 bits par canal
        Duty_In   : in  duty_array(0 to NB_CHANNELS-1);
        -- Vecteur de sorties PWM
        PWM_Out   : out std_logic_vector(0 to NB_CHANNELS-1)
    );
end PWM_multi_channels;

architecture Behavioral of PWM_multi_channels is
    -- Calcul de la période (identique pour tous les canaux)
    constant PERIOD_MAX : integer := SYS_FREQ / PWM_FREQ;
    signal counter      : integer range 0 to PERIOD_MAX := 0;
begin

    -- Processus unique pour le compteur (partagé par tous les canaux)
    process(Clk, nReset)
    begin
        if nReset = '0' then
            counter <= 0;
        elsif rising_edge(Clk) then
            if counter >= PERIOD_MAX - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Génération des N canaux indépendants
    gen_pwm: for i in 0 to NB_CHANNELS-1 generate
        process(Clk, nReset)
            variable threshold : integer;
        begin
            if nReset = '0' then
                PWM_Out(i) <= '0';
            elsif rising_edge(Clk) then
                -- Conversion du Duty_In (0-255) en seuil par rapport à PERIOD_MAX
                threshold := (to_integer(Duty_In(i)) * PERIOD_MAX) / 255;
                
                if counter < threshold then
                    PWM_Out(i) <= '1';
                else
                    PWM_Out(i) <= '0';
                end if;
            end if;
        end process;
    end generate gen_pwm;

end Behavioral;