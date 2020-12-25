# GSB gestion cloture
![](https://img.shields.io/badge/Fait_avec-Visual_Studio-blue.svg) ![](https://img.shields.io/badge/Version-1.0-green.svg)  

Le cahier des charges de l’application Frais GSB stipule que la fiche d’un visiteur est clôturée au dernier
jour du mois. Cette clôture sera réalisée via cette application avec les modalités suivantes :

  - Récupération des fiches créées du mois N-1 et leur mise à jour, en les mettant à l’état ‘CL’ ;
  en supposant que la campagne de validation va se passer entre le 1er et le 10 du mois courant, on va, en comparant les dates, s’assurer que l’on se trouve bien dans cet intervalle-là.
  - Et de la même manière, à partir du 20è jour du mois, on va mettre à jour les fiches validées du
  mois précédent en les passant à l’état ‘RB’.

## Procédure pour installer le service : 
  - Lancer le cmd en mode administrateur.
  - Déplacer vous dans le repertoire bin/release du projet. 
  ex : 
  ```shell
    C:\Users\User\source\repos\dussartcorp\-GSB_gestion_cloture\bin\Release
  ```
  cd C:\Users\User\source\repos\dussartcorp\-GSB_gestion_cloture\bin\Release
  - Dans de cmd éxecuter la commande suivante pour installer le service. : 
    ```shell
      C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe GSB_gestion_cloture.exe
    ```
  - Dans la barre de recherche de votre barre de tâches taper : Services et cliquer sur le programme.
  - Cherchez ensuite le service suivant : Gsb gestion cloture et cliquer sur démarrer (à noter que le service se relance toutes les heures).
  
