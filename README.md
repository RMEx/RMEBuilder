#RMEBuilder V2
> RMEBuilder V2 est un outil simple pour faciliter le **téléchargement**, l'**installation**, la **mise à jour**, le **partage** et le **développement** de scripts et **collections de scripts RGSS3** (RPG Maker VX Ace).
Ce projet est actuellement maintenu par [RMEx](https://github.com/RMEx). Cependant, le code source de l'application est libre, sous licence **LGPL**, et à ce titre, toute contribution est la bienvenue.


## Portée du projet

RMEBuilder s'adresse à **tous les utilisateurs** de RPG Maker VX Ace.
- **Utilisateurs lambdas** :
 - Trouvez, téléchargez, installez et mettez à jour les scripts et collections de votre choix pour votre projet RPG Maker, directement à partir d'une interface minimaliste simple d'utilisation.  

- **Développeurs** :
 - Composez vos scripts sous forme de fichiers .rb afin de les modifier avec votre éditeur de texte favori ([Atom](https://atom.io/), [Sublime Text](http://www.sublimetext.com/), [Notepad++](http://notepad-plus-plus.org/), etc.).
 - Compilez rapidement vos paquets dans le Scripts.rvdata2, ou compilez une seule fois un lien dynamique entre vos fichiers .rb et le Scripts.rvdata2 pour les tester directement sans passer par l'éditeur de scripts de RPG Maker, et aussi pouvoir collaborer plus facilement.
 - Composez librement des scripts plus conséquents en les organisant en paquets de plusieurs fichiers.
 - Renseignez les dépendances de vos scripts, pour qu'elles soient embarquées automatiquement à leur compilation/installation.
 - Clonez un paquet existant afin de reprendre le travail d'un autre scripteur.
 - Soumettez vos paquets en faisant un simple pull-request sur la [liste des paquets diffusés par RMEBuilder](https://github.com/RMEx/RMEPackages/blob/master/packages.rb), pour permettre à tous de les trouver, télécharger et installer plus rapidement et facilement avec RMEBuilder.

## Installation

Il vous suffit de télécharger la dernière release ([RMEBuilder.zip](https://github.com/RMEx/RMEBuilder/releases)), et de décompresser le contenu de l'archive dans le répertoire de votre choix.

## Lancement

Vous pouvez lancer RMEBuilder en cliquant sur l'exécutable `RMEBuilder.bat`.  
Un splash screen assez kitsh devrait laisser afficher un `prompt`, pour saisir des commandes.

A chaque fois que vous lancez RMEBuilder, il se synchronise avec les paquets disponnibles sur le dépôt Funkywork, ([ici](https://github.com/RMEx/RMEPackages/blob/master/packages.rb)).

Au premier démarrage, RMEBuilder vous demande de sélectionner le répertoire du projet cible.
Ce lien sera mémorisé au prochain démarrage, vous pouvez à tout moment le vérifier ou le modifier avec la commande `target`.

## Utilisation

Partie en cours de rédaction. : )


## Packager un script
Pour qu'un script puisse être lu par RMEBuilder, il lui faut un schema, qui se nomme `package.rb`. Vous pouvez vous inspirer du [schéma de RME](https://raw.githubusercontent.com/RMEx/RME/master/src/package.rb) où de celui du [Display text](https://raw.githubusercontent.com/nukiFW/RPGMaker/master/DisplayText/package.rb) (qui introduit des dépendances). Un scripteur n'aura pas trop de mal à comprendre son fonctionnement.

### Propager un script
Le packaging permet à tout le monde de placer ses scripts dans le répertoire `customPackages`, cependant, pour rendre un script disponnible depuis le web, il suffit de faire une `pullrequest` sur le fichier [https://github.com/funkywork/RMEPackages/blob/master/packages.rb](https://github.com/RMEx/RMEPackages/blob/master/packages.rb) et ajouter dans la liste des paquets un lien (dropbox, github ou ce que vous voulez) vers le package.rb de votre script. Une fois que la requête est validée. Une fois qu'un utilisateur relancera RMEBuilder, sa liste de package sera mise à jours.

> **Attention**, il faut impérativement que vous scripts soient encodés en UTF-8, n'hésitez donc pas à rajouter, en en-tête cette ligne : `# -*- coding: utf-8 -*-`

## Conclusion
N'hésitez pas à partager vos scripts via ce moyen ! Bonne utilisation
