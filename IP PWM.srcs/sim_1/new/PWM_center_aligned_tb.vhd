----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 18:30:36
-- Design Name: Testbench PWM Center-Aligned (Alignement Central)
-- Module Name: PWM_center_aligned_tb - Behavioral
-- Project Name: IP PWM
-- Target Devices: FPGA AMD / Générique
-- Tool Versions: Vivado 2018.3 / 2023.x
-- Description: 
--    Banc de test conçu pour valider la génération du PWM à alignement central.
--    Le test vérifie :
--    1. Le comportement du compteur triangulaire (Up/Down).
--    2. La symétrie de l'impulsion de sortie par rapport au centre de la période.
--    3. La réactivité du module lors de changements dynamiques du rapport cyclique.
-- 
-- Dependencies: 
--    - PWM_center_aligned.vhd (Unité à tester)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--    Pour faciliter l'observation sur le chronogramme, la fréquence PWM est 
--    volontairement fixée à 1 MHz dans le generic. Cela permet d'observer 
--    plusieurs cycles complets sans générer des fichiers de simulation trop lourds.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_center_aligned_tb is
-- Entité vide pour un testbench
end PWM_center_aligned_tb;

architecture Behavioral of PWM_center_aligned_tb is

    -- Constantes de simulation
    constant SYS_FREQ    : integer := 100_000_000; -- 100 MHz
    constant PWM_FREQ    : integer := 1_000_000;   -- 1 MHz (accéléré pour la simulation)
    constant CLK_PERIOD  : time    := 10 ns;

    -- Signaux de test
    signal tb_Clk     : std_logic := '0';
    signal tb_nReset  : std_logic := '0';
    signal tb_Duty_In : std_logic_vector(7 downto 0) := (others => '0');
    signal tb_PWM_Out : std_logic;

begin

    -- 1. Instanciation de l'UUT (Unit Under Test)
    UUT: entity work.PWM_center_aligned
        generic map (
            SYS_FREQ => SYS_FREQ,
            PWM_FREQ => PWM_FREQ
        )
        port map (
            Clk     => tb_Clk,
            nReset  => tb_nReset,
            Duty_In => tb_Duty_In,
            PWM_Out => tb_PWM_Out
        );

    -- 2. Génération de l'horloge
    clk_process : process
    begin
        while now < 50 us loop
            tb_Clk <= '0';
            wait for CLK_PERIOD / 2;
            tb_Clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- 3. Scénario de test
    stim_proc: process
    begin
        -- Phase 1 : Reset
        tb_nReset <= '0';
        tb_Duty_In <= std_logic_vector(to_unsigned(128, 8)); -- 50%
        wait for 100 ns;
        
        -- Phase 2 : Démarrage à 50%
        tb_nReset <= '1';
        wait for 10 us;
        
        -- Phase 3 : Test à 25% (Impulsion plus fine mais toujours centrée)
        tb_Duty_In <= std_logic_vector(to_unsigned(64, 8));
        wait for 10 us;
        
        -- Phase 4 : Test à 75% (Impulsion plus large mais toujours centrée)
        tb_Duty_In <= std_logic_vector(to_unsigned(192, 8));
        wait for 10 us;

        wait;
    end process;

end Behavioral;