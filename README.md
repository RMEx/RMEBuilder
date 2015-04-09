#RMEBuilder (v2.01)
> RMEBuilder est un outil pour faciliter l'installation et l'exécution de scripts **RPGMaker VXAce**. Le projet est actuellement maintenu par [funkywork](https://github.com/funkywork). Cependant, le code source de l'application est libre, sous licence **LGPL**, et à ce titre, toute contribution est la bienvenue.

Dans les faits, **RMEBuilder** s'inspire des gestionnaires de paquets disponnible dans les distributions Linux (comme **Aptitude**, par exemple).

## Démarrer avec RMEBuilder

### Télécharger RMEBuilder
Il vous suffit de cliquer sur ce lien : [Télécharger RMEBuilder2](https://github.com/funkywork/RMEBuilder/releases/download/Production/RMEBuilder.zip).  
Et de décompresser le contenu de l'archive dans un répertoire contenant un projet.

### Structure d'un projet
La structure d'un projet destiné à être compilé via **RMEBuilder** respecte généralement cette forme :

*   Projet_source/
*   RMEBuilder/
*   RMEBuilder.bat

**Projet_source** est le projet dont le fichier **Script.rvdata** sera compilé, et **RMEBuilder** contient les fichiers nécéssaires au fonctionnement de RMEBuilder. **RMEBuilder.bat** est l'exécutable pour lancer une compilation.

> Il est évident que le répertoire (Projet_source) peut avoir le nom que vous désirez.

### Paramétrer RMEBuilder
Etant donnée que le répertoire contenant le projet peut avoir n'importe quel nom, il faut avant tout préciser vers quel projet il faut compiler. Pour cela, rendez vous dans le fichier `RMEBuilder/target.rb`. Le contenu de ce fichier est :

```ruby
=begin
  This file is for target configuration.
  You can change the project's target
=end

TARGET = "../ProjectExample"
SCHEMA = "build_schema.rb"
```
Il vous suffit de remplacer `ProjectExample` par le nom du répertoire contenant votre projet.

#### Créer un Build_schema
Une fois que RMEBuilder sait dans quel répertoire se trouve votre projet, il faut créer un Build_schema. Pour ça, il suffit de créer à la racine du répertoire de votre projet (donc dans `ProjectExample/`, dans cet exemple), un fichier `build_schema.rb`. C'est dans ce fichier que vous pourrez ajouter les paquets à installer.

## Utilisation de RMEBuilder
Une fois que votre projet est correctement initialisé, vous pouvez lancer RMEBuilder en cliquant sur l'exécutable `RMEBuilder.bat`. Un splash screen assez kitsh devrait laisser afficher un `prompt`, pour saisir des commandes.

A chaque fois que vous lancez RMEBuilder, il se synchronise avec les paquets disponnibles sur le dépôt Funkywork, ([ici](https://github.com/funkywork/RMEPackages/blob/master/packages.rb)).

L'utilisation de RMEBuilder se fait au moyen de saisie de commandes. Nous les étudierons au fur et à mesure que nous avancerons dans ce document.

### Ajout de scripts à un projet
La manière la plus simple d'ajouter un script à un projet est de se rendre dans le `build_schema` et d'ajouter simplement cette ligne : `package("nom du paquet")`. Par exemple, pour ajouter le script "display-text", il suffit d'ajouter dans le fichier `build_schema.rb` la ligne `package("display-text")`. Une fois ceci fait, lancer RMEBuilder et exécuter la commande `build` **AVEC LE PROJET RPGMAKER FERME**. Si les paquets ne sont pas connu du projet, RMEBuilder en téléchargera la dernière version (ainsi que les scripts dont dépendent celui installé) et créera un espace dans l'éditeur de script avec les paquets installés.

Dans cet exemple, non seulement le `display-text` sera installé, mais aussi le `standardize-RGSS` dont dépend le `display-text`.

> Vous pouvez mettre autant d'appel de package dans votre build_schema.rb, par exemple, voici celui du projet sur lequel je travail en ce moment :

```ruby
package("display-text")
package("nuki-buzzer")
package("tone-tester")
```

### Mettre à jours un paquet
Il est à tout moment possible de mettre un paquet à jours, en lancant RMEBuilder et en saisissant la commande `update nom_du_paquet`, par exemple `update nuki-buzzer`. L'ancien script sera supprimé et le nouveau téléchargé. Il suffit ensuite de faire (avec le projet fermé dans RPGMaker) `build`.

## Clonage de paquets
Il est aussi possible de cloner un paquet, pour le placer dans le répertoire `RMEBuilder/customPackages`, lors d'une "build", ce sera toujours le paquet présent dans le customPackage qui aura la priorité.

Cette méthode est pratique pour construire un script, sans avoir besoin de le diffuser sur le net mais aussi pour les scripts qui ont une phase de gestation longue. On peut donc utiliser, dans RMEBuilder, la commande `reclone nom-du-paquet` pour écraser la version clônée localement par la dernière version disponnible.

> Pour réutiliser le paquet de manière classique, sans clônage, il suffit de le supprimer dans le répertoire `RMEBuilder/customPackages`. Un lancement de la commande `build` retéléchargera le paquet dans le répertoire classique des paquets.

## Supprimer un paquet
Il suffit de supprimer son appel dans `build_schema.rb` et de relancer la commande `build`.

## Chargement dynamiques de paquets
A chaque modification de script, par exemple, de script clôné, il faut rebuilder le projet. Une solution consiste à utiliser la commande `build dev` plutôt que `build` car elle génère des liens vers les fichiers. On peut donc modifier leurs contenus sans devoir rebuilder à chaque modification. En effet, le Rebuild n'est nécéssaire que lorsque l'on rajoute un fichier dans un paquet ou un paquet.

Il est conseillé d'utiliser, en phase de développement du jeu la commande `build dev` et une fois que le jeu est terminé, la commande `build` pour produire un Scripts.rvdata2 sans aucune dépendance.

## Packager un script
Pour qu'un script puisse être lu par RMEBuilder, il lui faut un schema, qui se nomme `package.rb`. Vous pouvez vous inspirer du [schéma de RME](https://raw.githubusercontent.com/funkywork/RME/master/src/package.rb) où de celui du [Display text](https://raw.githubusercontent.com/nukiFW/RPGMaker/master/DisplayText/package.rb) (qui introduit des dépendances). Un scripteur n'aura pas trop de mal à comprendre son fonctionnement.

### Propager un script
Le packaging permet à tout le monde de placer ses scripts dans le répertoire `customPackages`, cependant, pour rendre un script disponnible depuis le web, il suffit de faire une `pullrequest` sur le fichier [https://github.com/funkywork/RMEPackages/blob/master/packages.rb](https://github.com/funkywork/RMEPackages/blob/master/packages.rb) et ajouter dans la liste des paquets un lien (dropbox, github ou ce que vous voulez) vers le package.rb de votre script. Une fois que la requête est validée. Une fois qu'un utilisateur relancera RMEBuilder, sa liste de package sera mise à jours.

> **Attention**, il faut impérativement que vous scripts soient encodés en UTF-8, n'hésitez donc pas à rajouter, en en-tête cette ligne : `# -*- coding: utf-8 -*-`

## Conclusion
N'hésitez pas à partager vos scripts via ce moyen ! Bonne utilisation
