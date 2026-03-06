----------------------------------------------------------------------------------
-- Company: Université de Bordeaux (IMS.Bordeaux)
-- Engineer: Consolé MBOUBA
-- 
-- Create Date: 06.03.2026 16:27:23
-- Design Name: IP PWM
-- Module Name: PWM_variable - Behavioral
-- Project Name: IP PWM
-- Target Devices: Toutes les cartes de AMD 
-- Tool Versions: Toutes les versions Vivado
-- Description: PWM avec rapport cyclique réglable (0 à 100%) via une entrée 8 bits.
--              Duty_In = 0   -> 0%
--              Duty_In = 128 -> 50%
--              Duty_In = 255 -> 100%
-- Dependencies: 
-- 
-- Revision: Version 1.0
-- Revision 0.01 - File Created
-- Ce module permet un contrôle dynamique de la puissance.
-- Résolution : 8 bits (256 niveaux de rapport cyclique).
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_variable is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000; -- Horloge à 100 MHz
        PWM_FREQ_HZ : integer := 100_000       -- Fréquence PWM à 100 kHz
    );
    Port ( 
        Clk      : in  STD_LOGIC;
        nReset   : in  STD_LOGIC;
        Duty_In  : in  STD_LOGIC_VECTOR(7 downto 0); -- Valeur entre 0 et 255
        PWM_Out  : out STD_LOGIC
    );
end PWM_variable;

architecture Behavioral of PWM_variable is

    -- Calcul du nombre total de cycles pour une période
    constant PERIOD_COUNT : integer := CLK_FREQ_HZ / PWM_FREQ_HZ;
    
    -- Signaux internes
    signal counter   : integer range 0 to PERIOD_COUNT - 1 := 0;
    signal threshold : integer range 0 to PERIOD_COUNT := 0;

begin

    -- Calcul du seuil dynamique (Règle de 3)
    -- On convertit Duty_In en entier pour faire le calcul
    threshold <= (to_integer(unsigned(Duty_In)) * PERIOD_COUNT) / 255;

    pwm_proc : process(Clk, nReset)
    begin
        if nReset = '0' then
            counter <= 0;
            PWM_Out <= '0';
        elsif rising_edge(Clk) then
            
 
            if counter < (PERIOD_COUNT - 1) then
                counter <= counter + 1;
            else
                counter <= 0;
            end if;


            if counter < threshold then
                PWM_Out <= '1';
            else
                PWM_Out <= '0';
            end if;
            
        end if;
    end process;

end Behavioral;
