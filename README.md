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

## Résultats de Simulation
Le module a été validé par simulation. On observe un rapport cyclique de 50% (5 cycles hauts pour 5 cycles bas à une fréquence de 10MHz).

![Simulation PWM](doc/PWM_simple_tb.png)

## Simulation du PWM Variable
Voici le chronogramme obtenu lors de la simulation (25%, 50% et 75%) :

![Simulation PWM Variable](doc/PWM_variable.png)

## 📈 Validation par Simulation
Le bon fonctionnement du module a été vérifié par un Testbench simulant 3 canaux avec des rapports cycliques différents.

### Scénario de test :
1. **Initialisation** : Reset actif (`nReset = '0'`), toutes les sorties sont à 0.
2. **Rapports cycliques** :
   - Canal 0 : **10%** (Duty = 25)
   - Canal 1 : **50%** (Duty = 128)
   - Canal 2 : **90%** (Duty = 230)
3. **Changement dynamique** : Inversion des valeurs en cours de simulation pour vérifier la réactivité.

### Résultat obtenu :
![Simulation PWM Multi-Canaux](doc/PWM_multi_channels.png)
On observe une synchronisation parfaite des fronts montants, validant l'utilisation du compteur partagé.