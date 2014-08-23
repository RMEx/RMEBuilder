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
