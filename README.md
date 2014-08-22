#RMEBuilder
RMEBuilder est un outil d'automatisation de génération de fichiers `Scripts.rvdata2` permettant d'organiser son code sous forme de bibliothèques (pouvant entretenir des relations de dépendances) éditable avec votre éditeur préféré.

##Contexte
RMEBuilder a été crée durant l'implémentation du plugin [RME](https://www.github.com/funkywork/RME). En effet, pour que le code (qui est assez fourni) soit maintenable, nous avons dût le morceler en plusieurs fichiers.

###Problématique de RPGMaker
RPGMaker a été pensé pour que des utilisateurs sans aucune connaissance en programmation (autre que l'arithmétique générale) puisse se débrouiller. Bien que permettant un usage du langage Ruby, l'interface n'a pas été pensée pour que l'intégration en continu de script soit évidente.

###Solution proposée
Nous avons décidé d'écrire un projet RPGMaker VXAce qui automatise la génération du fichier `Scripts.rvdata2` sur la base d'un fichier de déscription qui permet de gérer des imbrication de scripts, et des dépendances. L'avantage principal (de notre point de vue) est que l'on peut se servir de l'éditeur de notre choix, et qu'ilne faut pas copier/coller sans arrêt des portions de code. Il suffit de cliquer sur un exécutable.y

![Processus](http://funkywork.github.io/RMEBuilder/images/process.png)


