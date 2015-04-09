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
