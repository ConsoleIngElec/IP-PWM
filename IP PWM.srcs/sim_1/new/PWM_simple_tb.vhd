----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 15:25:29
-- Design Name: IP PWM
-- Module Name: PWM_simple_tb - Behavioral
-- Project Name: IP PWM
-- Target Devices: Toutes les cartes de AMD 
-- Tool Versions: Toutes les versions Vivado
-- Description: Banc de test pour valider le signal PWM 50%.
--              Simule une horloge à 100MHz et vérifie le comportement du reset.
-- 
-- Revision: Version 1.0
-- Revision 0.01 - File Created
-- Additional Comments: Ce fichier doit être placé dans le dossier /sim du projet.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_simple_tb is
end PWM_simple_tb;

architecture Behavioral of PWM_simple_tb is

    -- Constantes de temps
    constant CLK_PERIOD : time := 10 ns; -- Horloge à 100 MHz

    -- Signaux internes pour piloter l'UUT (Unit Under Test)
    signal tb_Clk     : std_logic := '0';
    signal tb_nReset  : std_logic := '0';
    signal tb_PWM_Out : std_logic;

begin

    -- Instanciation du module à tester
    -- On force les fréquences pour avoir un résultat visible rapidement en simu
    UUT: entity work.PWM_simple
        generic map (
            CLK_FREQ_HZ => 100_000_000, -- 100 MHz
            PWM_FREQ_HZ => 10_000_000   -- 10 MHz (pour voir un changement tous les 5 cycles)
        )
        port map (
            Clk     => tb_Clk,
            nReset  => tb_nReset,
            PWM_Out => tb_PWM_Out
        );

    -- Générateur d'horloge
    clk_process : process
    begin
        while now < 2 us loop
            tb_Clk <= '0';
            wait for CLK_PERIOD / 2;
            tb_Clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait; -- Arrête le process pour éviter une boucle infinie à la fin
    end process;

    -- Scénario de test (Stimuli)
    stim_proc: process
    begin		
        -- 1. Initialisation sous Reset
        tb_nReset <= '0';
        wait for 100 ns;
        
        -- 2. Libération du Reset
        tb_nReset <= '1';
        
        -- 3. Observation du signal PWM
        -- On attend assez longtemps pour voir plusieurs périodes
        wait for 1 us;

        -- Message de fin dans la console Tcl de Vivado
        report "### SIMULATION TERMINEE - VERIFIEZ LES WAVEFORMS ###" severity note;
        wait;
    end process;

end Behavioral;