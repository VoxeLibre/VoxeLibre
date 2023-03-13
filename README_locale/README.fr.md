# MineClone2
Un jeu non-officiel similaire à Minecraft pour Minetest. Forké depuis Mineclone par davedevils. Développé par de nombreuses personnes. Pas développé ni supporté par Mojang AB.

### Gameplay 
Vous atterissez dans un monde fait entièrement de cubes et généré aléatoirement. Vous pouvez explorer le monde, miner et construire presque n'importe quel bloc pour créer de nouvelles structures. Vous pouvez choisir de jouer en "mode survie" dans lequel vous devez combattre des monstres et la faim et progresser lentement dans différents aspects du jeu, comme l'extraction de minerai, l'agriculture, la construction de machines et ainsi de suite. Ou alors vous pouvez jouer en "mode créatif" où vous pouvez construire à peu près n'importe quoi instantanément.

### Résumé du Gameplay

* Jeu de type bac-à-sable, sans objetifs
* Survie : combattez des monstres hostiles et la faim
* Creusez pour du minerai et d'autres trésors
* Magie : gagnez de l'expérience et enchantez les outils
* Utilisez les blocs ramassés pour construire de magnifiques bâtiments, votre imagination est la seule limite
* Ramassez des fleurs (et d'autres sources de teinture) et colorez votre monde
* Trouvez des graines et commencez à cultiver
* Trouvez ou fabriquez des centaines d'objets
* Construisez un réseau ferroviaire complexe et amusez-vous avec les wagonnets
* En mode créatif vous pouvez construire presque n'importe quoi gratuitement et sans limite

## Comment jouer (démarrer rapidement)
### Commencer
* **Frappez un arbre** jusqu'à ce qu'il casse et donne du bois
* Placez le **bois dans la grille 2x2** (la "grille de fabrication" de votre menu d'inventaire) et fabriquez 4 planches de bois
* Placer les 4 planches de bois dans la grille 2x2 et **fabriquez un établi**
* **Faites un clic droit sur l'établi** (icone livre) pour apprendre toutes les recettes possibles
* **Fabriquez une pioche de bois** pour miner la pierre
* Différents outils minent différentes sortes de blocs. Essayez-les !
* Continuez à jouer comme vous voulez. Amusez-vous !

### Agriculture
* Trouvez des graines
* Fabriquez une houe
* Faites un clic droit sur la terre ou des blocs similaires avec la houe pour créer des terres agricoles
* Placer des graines sur des terres agricoles et regardez les pousser
* Récoltez les plantes une fois matûres
* Les terres agricoles proche de l'eau deviennent humides et accélèrent la croissance

### Four
* Fabriquez un four
* Le four permet d'obtenir plus d'objets
* L'emplacement du haut doit contenir un objet fondable (par ex : minerai de fer)
* L'emplacement du bas doit contenir un objet combustible (par ex : charbon)
* Voir le guide d'artisanat pour en apprendre plus sur les objets fondables et combustibles

### Aide supplémentaire
Plus d'aide à propos du jeu, des blocs, objets et plus encore peuvent être trouvés dans le jeu. Vous pouvez accéder à l'aide depuis le menu inventaire.

### Objets spéciaux
Les objets suivants sont intéressants pour le mode Créatif et pour les constructeurs de cartes d'aventure. Ils ne peuvent être obtenus dans le jeu ou dans l'inventaire créatif. 

* Barrière : `mcl_core:barrier`

Utilisez la commande de chat `/giveme` pour les obtenir. Voir l'aide interne au jeu pour une explication.

## Installation
Ce jeu nécessite [Minetest](http://minetest.net) pour fonctionner (version 5.4.1 ou plus). Vous devez donc installer Minetest d'abord. Seules les versions stables de Minetest sont officielement supportées.
Il n'y a pas de support de MineClone2 dans les versions développement de Minetest.

Pour installer MineClone2 (si ce n'est pas déjà fait), déplacez ce dossier dans le dossier “games” de Minetest. Consultez l'aide de Minetest pour en apprendre plus.

## Liens utiles 
Le dépôt de MineClone2 est hébergé sur Mesehub. Pour contribuer ou signaler des problèmes, allez là-bas.

* Mesehub : <https://git.minetest.land/MineClone2/MineClone2>
* Discord : <https://discord.gg/xE4z8EEpDC>
* YouTube : <https://www.youtube.com/channel/UClI_YcsXMF3KNeJtoBfnk9A>
* IRC : <https://web.libera.chat/#mineclone2>
* Matrix : <https://app.element.io/#/room/#mc2:matrix.org>
* Reddit : <https://www.reddit.com/r/MineClone2/>
* Forums Minetest : <https://forum.minetest.net/viewtopic.php?f=50&t=16407>
* ContentDB : <https://content.minetest.net/packages/wuzzy/mineclone2/>
* OpenCollective : <https://opencollective.com/mineclone2>

## Objectif
* Essentiellement, créer un clone de Minecraft stable, moddable, libre et gratuit basé sur le moteur de jeu Minetest avec des fonctionnalités abouties, utilisable à la fois en mode solo et multijoueur. Actuellement, beaucoup des fonctionnalités de **Minecraft Java Edition** sont déjà implémentées et leur amélioration est prioritaire sur les nouvelles demandes.
* Avec une priorité moindre, implémenter les fonctionnalités des versions **Minecraft + OptiFine** (OptiFine autant que supporté par le moteur Minetest). Cela signifie que les fonctionnalités présentes dans les versions listées sont priorisées.
* Dans l'idéal, créer une expérience performante qui tourne bien sur des ordinateurs à basse performance. Malheureusement, en raison des mécanismes de Minecraft et des limitations du moteur Minetest ainsi que de la petite taille de la communauté de joueurs sur des ordinateurs à basses performances, les optimisations sont difficiles à explorer.

## Statut de complétion
Ce jeu est actuellement au stade **beta**.
Il est jouable mais incomplet en fonctionnalités.
La rétro-compatibilité n'est pas entièrement garantie, mettre votre monde à jour peut causer de petits bugs.
Si vous voulez utiliser la version de développement de MineClone2 en production, la branche master est habituellement relativement stable. Les branches de test fusionnent souvent des pull requests expérimentales et doivent être considérées comme moins stable.

Les principales fonctionnalités suivantes sont disponibles :

* Outils, armes
* Armure
* Système de fabrication : grille 2x2, établi (grille 3x3), four, incluant un guide de fabrication
* Coffres, grands coffres, coffre ender, boites de Shulker
* Fours, entonnoirs
* Faim
* La plupart des monstres et animaux
* Tous les minerais de Minecraft
* La plupart des blocs de l'overworld
* Eau et lave
* Météo
* 28 biomes + 5 biomes du Nether
* Le Nether, monde souterrain brûlant dans une autre dimension
* Circuits Redstone (partiel)
* Effets de Statut (partiel)
* Expérience
* Enchantement
* Brassage, potions, flèches trempées (partiel)
* Bâteaux
* Feu
* Blocs de construction : escaliers, dalles, portes, trappes, barrières, portillons, murets
* Horloge
* Boussole
* Éponge
* Bloc de slime 
* Petites plantes et pousses
* Teintures
* Bannières
* Blocs de décoration : verre, verre teinté, vitres, barres de fer, terre cuites (et couleurs), têtes et plus
* Cadres d'objets 
* Juke-boxes
* Lits
* Menu d'inventaire
* Inventaire créatif
* Agriculture
* Livres pour écrire
* Commandes
* Villages
* L'End 
* et plus !

Les fonctionnalités suivantes sont incomplètes :

* Certains monstres et animaux
* Certains composants de Redstone
* Wagonnets spéciaux
* Quelques blocs et objets non-triviaux

Fonctionnalités bonus (absentes de Minecraft) :

* Guide d'artisanat intégré au jeu qui montre les recettes d'artisanat et de cuisson
* Système d'aide intégré au jeu contenant des informations à propos des techniques de base, blocs, objets et plus
* Recettes d'artisanat temporaires. Elles existent uniquement pour rendre des objets accessibles qui ne le seraient pas autrement sauf en mode créatif. Elles seront retirées au cours de l'avancement du développement et de l'ajout de nouvelles fonctionnalités.
* Pousses dans les coffres en mapgen v6
* Entièrement moddable (grâce la puissante API Lua de Minetest)
* Nouveaux blocs et objets :
    * Outil de recherche, montre l'aide de ce qu'il touche
    * Plus de dalles et d'escaliers
    * Portillon en briques du Nether
    * Barrière en briques du Nether rouges
    * Portillon en briques du Nether rouges
* Structures de remplacement - ces petites variantes de structures de Minecraft servent de remplacement en attendant qu'on arrive à en faire fonctionner de plus grandes :
    * Cabine dans les bois (Manoir des bois)
    * Avant-poste du Nether (Forteresse)

Différences techniques avec Minecraft :

* Limite en hauteur de 31000 blocs (bien plus grand que Minecraft)
* Taille horizontale du monde 62000×62000 blocs (bien plus petit que Minecraft mais toujours très grand)
* Toujours assez incomplet et buggé
* Des blocs, objets, ennemis et fonctionnalités manquent
* Quelques objets ont des noms légèrement différents pour être plus faciles à distinguer
* Des musiques différentes pour le juke-boxe
* Des textures différentes (Pixel Perfection)
* Des sons différents (sources diverses)
* Un moteur de jeu différent (Minetest)
* Des bonus cachés différents

...et enfin MineClone2 est un logiciel libre !

## Autres fichiers readme

* `LICENSE.txt` : Le texte de la licence GPLv3
* `CONTRIBUTING.md` : Information pour ceux qui veulent contribuer
* `API.md` : Pour les modders Minetest qui veulent modder ce jeu
* `LEGAL.md` : Information légale
* `CREDITS.md` : Liste de toutes les personnes qui ont contribué
