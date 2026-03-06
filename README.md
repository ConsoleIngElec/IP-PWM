# IP PWM Simple (Generic VHDL)

## Description
Ce module VHDL génère un signal PWM avec un rapport cyclique de 50%. 
Il est conçu pour être utilisé dans un **Block Design Vivado** sur les FPGA AMD.

## Paramètres (Generics)
* **CLK_FREQ_HZ** : Fréquence de l'horloge d'entrée (ex: 100_000_000).
* **PWM_FREQ_HZ** : Fréquence souhaitée pour le signal de sortie (ex: 1_000).

## Utilisation
1. Ajouter le fichier `PWM_simple.vhd` au projet Vivado.
2. Instancier le module dans votre design.
3. Configurer les fréquences via les paramètres Generics.