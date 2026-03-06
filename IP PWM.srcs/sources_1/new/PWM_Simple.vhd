----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 14:31:15
-- Design Name: IP PWM
-- Module Name: PWM_simple - Behavioral
-- Project Name: IP PWM
-- Target Devices: Toutes les cartes de AMD 
-- Tool Versions: Toutes les versions Vivado
-- Description: PWM à canal unique, aligné à gauche (edge-aligned), 
--              avec un rapport cyclique (Duty Cycle) fixe de 50%.
--              La fréquence s'adapte automatiquement via les Generics.
-- 
-- Revision: Version 1.0
-- Revision 0.01 - File Created
-- Additional Comments: Ce module est conçu pour être instancié dans un 
--                      IP Integrator (Block Design) sous Vivado.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_simple is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000; 
        PWM_FREQ_HZ : integer := 1_000         
    );
    Port ( 
        Clk     : in  STD_LOGIC; 
        nReset  : in  STD_LOGIC;
        PWM_Out : out STD_LOGIC 
    );
end PWM_simple;

architecture Behavioral of PWM_simple is

    -- Calcul du nombre de coups d'horloge pour une période complète
    -- Ce calcul est effectué une seule fois par l'outil de synthèse.
    constant TERMINAL_COUNT : integer := CLK_FREQ_HZ / PWM_FREQ_HZ;
    
    -- Seuil pour le rapport cyclique de 50%
    constant THRESHOLD      : integer := TERMINAL_COUNT / 2;
    signal counter : integer range 0 to TERMINAL_COUNT - 1:= 0;

begin

    -- Process de génération du signal PWM
    pwm_process : process(Clk, nReset)
    begin
        if nReset = '0' then
            counter <= 0;
            PWM_Out <= '0';
            
        elsif rising_edge(Clk) then
            if counter < (TERMINAL_COUNT - 1) then
                counter <= counter + 1;
            else
                counter <= 0; 
            end if;

            -- LOGIQUE DE SORTIE (Edge-Aligned)
            -- Le signal est à '1' de 0 jusqu'à la moitié de la période, puis à '0'
            if counter < THRESHOLD then
                PWM_Out <= '1';
            else
                PWM_Out <= '0';
            end if;
        end if;
    end process;

end Behavioral;