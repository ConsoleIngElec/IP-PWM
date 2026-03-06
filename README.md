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

### 📈 Validation par Simulation (Multi-Canaux)

Le bon fonctionnement de l'IP PWM Multi-Canaux a été vérifié par un Testbench simulant 3 sorties indépendantes avec des rapports cycliques variés.

#### **Scénario de test :**
1. **Initialisation** : Application d'un Reset actif à l'état bas (`nReset = '0'`). On vérifie que toutes les sorties sont forcées à '0' pour la sécurité du système.
2. **Rapports cycliques configurés** :
   - Canal 0 : **10%** (Valeur Duty : 25)
   - Canal 1 : **50%** (Valeur Duty : 128)
   - Canal 2 : **90%** (Valeur Duty : 230)
3. **Changement dynamique** : Modification des valeurs `Duty_In` en cours de simulation pour valider la réactivité instantanée du module sans glitch.

#### **Résultat obtenu :**
![Simulation PWM Multi-Canaux](doc/PWM_multi_channels.png)

**Analyse :** La simulation confirme une synchronisation parfaite des fronts montants entre les différents canaux. Cela valide l'architecture à **compteur partagé**, qui permet une économie significative de ressources logiques (LUT) sur le FPGA.

---

### 🟢 Validation par Simulation (Center-Aligned)

La simulation du module **Center-Aligned** démontre une précision accrue dans la génération du signal, indispensable pour les applications de mécatronique.

#### **Scénario de test :**
1.  **Initialisation** : Le signal `nReset` à '0' garantit que la sortie `PWM_Out` reste inactive au démarrage.
2.  **Génération Triangulaire** : Observation du compteur interne (Up-Down) pour valider la forme d'onde symétrique.
3.  **Rapport cyclique** : Test à un rapport cyclique de **~31%** (Duty = 80) pour vérifier le centrage de l'impulsion par rapport à la période.

#### **Résultat obtenu :**
![Simulation PWM Center-Aligned](doc/PWM_center_aligned_sim.png)

**Analyse :** Contrairement au mode classique (Edge-Aligned), l'impulsion est parfaitement centrée au milieu du cycle. Cette symétrie permet de réduire les harmoniques de courant, prolongeant ainsi la durée de vie des moteurs pilotés et diminuant les perturbations électromagnétiques (EMI).