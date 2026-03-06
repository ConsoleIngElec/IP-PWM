----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 17:55:00
-- Design Name: IP PWM
-- Module Name: PWM_multi_channels_tb - Behavioral
-- Project Name: IP PWM
-- Target Devices: FPGA
-- Tool Versions: Vivado
-- Description: 
--    Banc de test (Testbench) pour valider le module PWM multi-canaux.
--    Vérifie l'indépendance de 3 canaux configurés avec des rapports 
--    cycliques distincts (10%, 50% et 90%).
-- 
-- Dependencies: 
--    - PWM_pkg (pour le type duty_array)
--    - PWM_multi_channels (Entité à tester)
-- 
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.PWM_pkg.all; -- Utilisation du package pour gérer les tableaux de duty cycle

entity PWM_multi_channels_tb is
-- Un testbench n'a pas de ports (c'est une entité "boîte noire")
end PWM_multi_channels_tb;

architecture Behavioral of PWM_multi_channels_tb is

    -- Configuration des constantes de simulation
    constant NB_CHANNELS : integer := 3;            -- Test sur 3 canaux indépendants
    constant SYS_FREQ    : integer := 100_000_000;  -- Horloge système à 100 MHz
    constant PWM_FREQ    : integer := 1_000_000;    -- Fréquence PWM à 1 MHz (accélérée pour simuler plus vite)
    constant CLK_PERIOD  : time    := 10 ns;        -- Période correspondant à 100 MHz

    -- Signaux de connexion vers l'UUT (Unit Under Test)
    signal tb_Clk     : std_logic := '0';
    signal tb_nReset  : std_logic := '0';
    signal tb_Duty_In : duty_array(0 to NB_CHANNELS-1);
    signal tb_PWM_Out : std_logic_vector(0 to NB_CHANNELS-1);

begin

    -- 1. Instanciation de l'unité à tester (UUT)
    UUT: entity work.PWM_multi_channels
        generic map (
            NB_CHANNELS => NB_CHANNELS,
            SYS_FREQ    => SYS_FREQ,
            PWM_FREQ    => PWM_FREQ
        )
        port map (
            Clk     => tb_Clk,
            nReset  => tb_nReset,
            Duty_In => tb_Duty_In,
            PWM_Out => tb_PWM_Out
        );

    -- 2. Générateur d'horloge système
    clk_process : process
    begin
        -- Limite la simulation à 50 microsecondes pour ne pas saturer la mémoire (évite les fichiers .wdb trop lourds)
        while now < 50 us loop 
            tb_Clk <= '0';
            wait for CLK_PERIOD / 2;
            tb_Clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait; -- Arrête la génération une fois le temps limite atteint
    end process;

    -- 3. Scénario de test (Stimulus)
    stim_proc: process
    begin        
        -- Phase 1 : Initialisation et Reset
        -- Toutes les sorties doivent rester à '0'
        tb_nReset <= '0';
        
        -- Définition des rapports cycliques initiaux :
        -- Canal 0 : ~10% (25/255) | Canal 1 : ~50% (128/255) | Canal 2 : ~90% (230/255)
        tb_Duty_In <= (to_unsigned(25, 8), to_unsigned(128, 8), to_unsigned(230, 8));
        wait for 50 ns;
        
        -- Phase 2 : Démarrage du système
        tb_nReset <= '1';
        
        -- Observation du comportement sur 40 microsecondes (plusieurs cycles PWM)
        wait for 40 us;

        -- Phase 3 : Test du changement dynamique
        -- Inversion des valeurs pour prouver que chaque canal réagit indépendamment
        -- Canal 0 -> 90% | Canal 1 -> 10% | Canal 2 -> 50%
        tb_Duty_In <= (to_unsigned(230, 8), to_unsigned(25, 8), to_unsigned(128, 8));
        
        -- Fin de la simulation
        wait;
    end process;

end Behavioral;
