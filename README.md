#RMEBuilder
RMEBuilder est un outil d'automatisation de génération de fichiers `Scripts.rvdata2` permettant d'organiser son code sous forme de bibliothèques (pouvant entretenir des relations de dépendances) éditable avec votre éditeur préféré.

##Contexte
RMEBuilder a été crée durant l'implémentation du plugin [RME](https://www.github.com/funkywork/RME). En effet, pour que le code (qui est assez fourni) soit maintenable, nous avons dût le morceler en plusieurs fichiers.

###Problématique de RPGMaker
RPGMaker a été pensé pour que des utilisateurs sans aucune connaissance en programmation (autre que l'arithmétique générale) puisse se débrouiller. Bien que permettant un usage du langage Ruby, l'interface n'a pas été pensée pour que l'intégration en continu de script soit évidente.

###Solution proposée
Nous avons décidé d'écrire un projet RPGMaker VXAce qui automatise la génération du fichier `Scripts.rvdata2` sur la base d'un fichier de déscription qui permet de gérer des imbrication de scripts, et des dépendances. L'avantage principal (de notre point de vue) est que l'on peut se servir de l'éditeur de notre choix, et qu'ilne faut pas copier/coller sans arrêt des portions de code. Il suffit de cliquer sur un exécutable.

![Processus](http://funkywork.github.io/RMEBuilder/images/process.png)

##Utilisation
RMEBuilder est assez facile à utiliser, nous allons voir comment nous en servir au long de cette introduction. Au delà de l'apport en confort et en facilité que l'outil apporte pour la construction de projets scriptés d'envergure, nous espérons que les scripteurs n'hésiteront pas à proposer des schémas pour rendre l'installation de leurs scripts facilement.

###Téléchargement et organisation du projet
Vous pouvez soit clôner ce projet (pour les adepts de GIT), soit le télécharger sous forme de ZIP au moyen de [ce lien](https://github.com/funkywork/RMEBuilder/archive/master.zip). Une fois le projet récupéré, seul le répertoire `Builder/` nous intéressera.


####Architecture interne
Le répertoire `Builder/` est organisé de cette manière:

*    Builder/
     *   RMEBuilder/
	 *   build_dev.bat
	 *   build_prod.bat

*   __RMEBuilder__ est le répertoire qui comporte les information d'exécution pour créer un `Scripts.rvdata2`. Ce répertoire n'est utile que pour ceux désireux de comprendre comment RMEBuilder a été rédigé. (Et pour changer la cible de compilation que nous verrons plus tard dans ce didacticiel);
*   __build_dev.bat__ est l'exécutable pour construire le `Scripts.rvdata2` en mode développement (cette notion sera vue plus tard);
*   __build_prod.bat__ est l'exécutable pour construire le `Scripts.rvdata2` en mode production (cette notion sera vue plus tard).

Pour installer RMEBuilder dans un projet, il suffit de copier/coller le répertoire `Builder/` dans un répertoire qui lui même contiendra un répertoire de votre projet RPGMaker VXAce.
Généralement, j'organise mes répertoires de projets de cette manière :
```
Mon projet
	-Répertoire du projet VXAce
	-Lib
	-Builder
```
Cela me permet de séparer mes bibliothèques de scripts (que je placerai dans Lib), mon Builder et mon projet RPGMaker VXAce. Cependant, vous êtes libre de choisir l'arborescence de votre choix.

###Construction d'un schéma d'assemblage
Pour que RMEBuilder puisse construire votre `Scripts.rvdata2`, il lui faut des informations. Par exemple par rapport au schéma, où se trouve le projet auquel il faut greffer le rvdata2, quelles bibliothèques (nous verrons plus loin qu'est ce qu'une bibliothèque) doit il inclure, après quel script faut-il insérer les bibliothèques. Etc. Pour cela, il faut créer un fichier nommé `build_schema.rb` (il doit impérativement être encodé en __UTF-8__, comme tous les scripts que vous importerez). Ce schéma, par défaut doit être placé dans le répertoire `Builder/`, cependant, il est possible de changer sa position en modifier le fichier `Builder/RMEBuilder/target.rb`. C'est dans ce fichier que nous évoquerons toutes les information de construction.

####Informations minimales
Le strict minimum des informations à fournir pour que RMEBuilder fonctionne bien sont :
*   L'emplacement, par rapport au fichier `build_schema.rb` du répertoire où se trouve l'exécutable (`Game.exe`), soit, le répertoire du projet RPGMaker VXAce.
*   Le nom de l'emplacement script après le quel il faudra insérer les scripts externes.

Par exemple, voici comment se présente mon `build_schema.rb` à moi :
```ruby
# -*- coding: utf-8 -*-
project_directory "../projectVXAce/"
insert_after "Scene_Gameover"
```
La première ligne est un peu de la paranoïa de ma part, j'ajoute une anotation pour garantir que le fichier soit encodé en UTF-8. Ensuite, en me référant à l'architecture proposée plus haut, le chemin du projet VXAce et je voudrais que mes scripts s'insèrent après `Scene_Gameover`.
Rien de très compliqué, je pense que le code est assez explicite.

####Notion et construction de bibliothèque
Notre schéma étant initialisé, nous ne pouvons pas encore faire grand chose. Pour le rendre utile, il va falloir lui inclure des bibliothèques. Une bibliothèque est un regroupement de scripts. Par exemple, dans le contexte RME, la bibliothèque RME correspondrait à tous les scripts s'y référant.
RMEBuilder permet d'ordonner ces bibliothèques et de les inclures dans le rvdata2.

#####Construction d'une bibliothèque
Pour construire (ou référencer) une bibliothèque, il suffit d'ajouter dans votre
fichier `build_schema.rb` une description de bibliothèque. Voici son schéma:

```ruby
library(name, folder){
	# Ici se placera le contenu de votre bibliothèque
}
```

Concrètement, on décrit une bibliothèque par son nom et par l'endroit où se trouvent les fichiers sources. Par exemple `Lib/UneLib/src/`.
Ensuite, entre les accolades, on décrira des informations complémentaires à notre bibliothèque.

*   __define_version__ a, b, c  
    Permet de définir une version pour la bibliothèque. Par exemple :
	`define_version 1, 2` pour décrire la version `1.2.0`.
	Ou alors `define_version 2` pour décrire la version `2.0.0`. Ou encore `define_version 1,2,3` pour décrire la version `1.2.3`. On peut au maximum mettre 3 nombres dans la définition d'une version. la définition d'une version permettra de créer un système d'imbrication et de dépendances. Si aucune information de version n'a été fournie, la version sera par défaut à `1.0.0`.

*   __describe__ text  
   Permet d'ajouter une déscription à une bibliothèque. Par exemple : `describe "Bibliothèque pour ajouter un système de quête au jeu!"`

*   __author__ name, email  
    Cette commande permet d'ajouter un auteur à la bibliothèque. On peut en ajouter autant que l'on en souhaite. Le paramètre `email` n'est pas obligatoire.

> `describe` et `author` sont des commandes qui agissent à la génération du script, un en-tête est ajouté avec une description de la bibliothèque et la liste des auteurs, si il y en as.

*   __add_component__ name, file  
    C'est un peu le coeur du module de bibliothèque. Il s'agit de l'ajout d'un fichier à inclure dans la bibliothèque. On peut en mettre autant que l'on veut. On leur donne un nom (qui sera le nom affiché dans l'emplacement dans script) et le chemin pour accéder au fichier. Ce chemin est relatif au chemin défini par l'argument `folder` dans la définition de la bibliothèque. Lors de la génération du rvdata2, les "components" seront insérés par d'ordre d'ajout. Par exemple :
	```ruby
	project_directory "project/"
	insert_after "Scene_Gameover"

	# Define a library
	library("RME", 'Lib/RME/src'){ 
	
 	  define_version 1, 0, 0
	  describe "RME is a powerful tool to improve your RPGMaker VXAce experience!"

	  add_author "Nuki", "xaviervdw@gmail.com"
	  add_author "Hiino"
	  add_author "Raho"
	  add_author "Grim", "grimfw@gmail.com"

	  add_component "RME.SDK",            "SDK.rb"
	  add_component "RME.EvEx",           "EvEx.rb"
	  add_component "RME.DocGenerator",   "DocGenerator.rb"
	  add_component "RME.Documentation",  "Doc.rb"

	}
	```
	Voici un build_schema pour construire la version actuelle de RME.

*   __add_dependency__ name, version  
   Cette commande permet d'obliger la présence d'une autre bibliothèque pour fonctionner. Son premier argument est une chaine de caractères du nom de la bibliothèque requise, le deuxième (pouvant être ommis) est la version. Par défaut, la version vaut `1.0`. On peut ajouter autant de dépendances que l'on veut. Par exemple :
   
   ```ruby
	project_directory "project/"
	insert_after "Scene_Gameover"

	# Define a library
	library("RME", 'Lib/RME/src'){ 
	
 	  define_version 1, 0, 0
	  describe "RME is a powerful tool to improve your RPGMaker VXAce experience!"

	  add_author "Nuki", "xaviervdw@gmail.com"
	  add_author "Hiino"
	  add_author "Raho"
	  add_author "Grim", "grimfw@gmail.com"

	  add_component "RME.SDK",            "SDK.rb"
	  add_component "RME.EvEx",           "EvEx.rb"
	  add_component "RME.DocGenerator",   "DocGenerator.rb"
	  add_component "RME.Documentation",  "Doc.rb"

	}

	library('Test', 'Lib/Test/src'){
	  describe "Un petit test"
	  add_component "Test de script", "test.rb"
	  add_dependency "RME", vsn(1,0,0)
	}
	```
	Cette proposition de compilation fonctionnera car `RME 1.0.0` est installé. Si j'avais demandé comme dépendance `add_dependency "RME", vsn(1,0,2)` par exemple, la compilation aurait échouée.

*   __inline__
    Il s'agit d'un simple attribut, qui ajouté dans la déscription de la bibliothèque, indique que toute la bibliothèque va être compressée en un seul emplacement script dans l'éditeur de script. Sans cet argument, chaque `component` du script est répartit dans un emplacement.

####Externalisation des bibliothèques
Un des objectifs de RMEBuilder, est aussi de permettre de la modularité dans l'ajout/suppression de scripts. Pour éviter de rendre le fichier de schéma trop lourd, il est possible de créer une bibliothèque dans un fichier externe. Et dans l'inclure dans le schéma. Par exemple, imaginons que RME se trouve dans `Lib/RME/src`. Nous pourrions écrire un schéma `RMESchema.rb` dans `Lib/RME/` :

```ruby
library("RME", 'src'){ 
	
	define_version 1, 0, 0
	describe "RME is a powerful tool to improve your RPGMaker VXAce experience!"

	add_author "Nuki", "xaviervdw@gmail.com"
	add_author "Hiino"
	add_author "Raho"
	add_author "Grim", "grimfw@gmail.com"

	add_component "RME.SDK",            "SDK.rb"
	add_component "RME.EvEx",           "EvEx.rb"
	add_component "RME.DocGenerator",   "DocGenerator.rb"
	add_component "RME.Documentation",  "Doc.rb"

}
```

Et notre `build_schema.rb` :

```ruby
project_directory "project/"
insert_after "Scene_Gameover"
load_schema 'Lib/RME/', 'RMESchema.rb'
```

Comme vous pouvez le voir, le `folder` de la bibliothèque est relatif au schéma qui l'appelle. la fonction `load_schema` prend deux arguments. Le premier étant le répertoire où se trouve le schéma, le second étant le nom du schéma. Il est possible d'ommettre le premier argument si le schéma à charger se trouve dans le même répertoire.
