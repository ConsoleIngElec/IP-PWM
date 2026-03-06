----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 16:37:29
-- Design Name: IP PWM
-- Module Name: PWM_variable_tb - Behavioral
-- Project Name: IP PWM
-- Target Devices: FPGA (Générique)
-- Tool Versions: Vivado toutes versions
-- Description: Banc de test pour valider le module PWM à rapport cyclique variable.
--              Le test change dynamiquement la valeur de Duty_In (25%, 50%, 75%)
--              pour vérifier la variation de la largeur d'impulsion en sortie.
-- 
-- Dependencies: PWM_variable.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- On utilise une fréquence PWM élevée (10MHz) pour la simulation afin de 
-- visualiser rapidement plusieurs périodes sur le chronogramme.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_variable_tb is
-- Les Testbenches n'ont pas de ports
end PWM_variable_tb;

architecture Behavioral of PWM_variable_tb is

    -- 1. Déclaration du composant à tester (UUT)
    component PWM_variable
        generic (
            CLK_FREQ_HZ : integer := 100_000_000;
            PWM_FREQ_HZ : integer := 10_000_000  -- 10MHz pour voir les cycles facilement
        );
        Port ( 
            Clk      : in  STD_LOGIC;
            nReset   : in  STD_LOGIC;
            Duty_In  : in  STD_LOGIC_VECTOR(7 downto 0);
            PWM_Out  : out STD_LOGIC
        );
    end component;

    -- 2. Signaux internes pour connecter l'UUT
    signal tb_Clk     : STD_LOGIC := '0';
    signal tb_nReset  : STD_LOGIC := '0';
    signal tb_Duty_In : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tb_PWM_Out : STD_LOGIC;

    -- Constante de temps pour l'horloge (100 MHz = 10ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Instanciation de l'UUT (Unit Under Test)
    uut: PWM_variable
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            PWM_FREQ_HZ => 10_000_000
        )
        port map (
            Clk      => tb_Clk,
            nReset   => tb_nReset,
            Duty_In  => tb_Duty_In,
            PWM_Out  => tb_PWM_Out
        );

    -- 4. Génération de l'horloge
    clk_process : process
    begin
        tb_Clk <= '0';
        wait for CLK_PERIOD/2;
        tb_Clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 5. Processus de Stimulus (Le scénario de test)
    stim_proc: process
    begin
        -- Initialisation (Reset)
        tb_nReset <= '0';
        tb_Duty_In <= x"00";
        wait for 50 ns;
        tb_nReset <= '1';
        wait for 20 ns;

        -- TEST 1 : Rapport cyclique à 25% (64 en décimal)
        -- Sur 10 cycles, on devrait avoir 2 ou 3 cycles à '1'
        tb_Duty_In <= std_logic_vector(to_unsigned(64, 8));
        wait for 500 ns;

        -- TEST 2 : Rapport cyclique à 50% (128 en décimal)
        -- On devrait avoir 5 cycles à '1' et 5 cycles à '0'
        tb_Duty_In <= std_logic_vector(to_unsigned(128, 8));
        wait for 500 ns;

        -- TEST 3 : Rapport cyclique à 75% (191 en décimal)
        -- On devrait avoir environ 7 ou 8 cycles à '1'
        tb_Duty_In <= std_logic_vector(to_unsigned(191, 8));
        wait for 500 ns;

        -- Fin de la simulation
        wait;
    end process;

end Behavioral;