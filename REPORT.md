# Rapport sur le projet de Génie Logiciel Avancé

Nous avons réalisé tout ce qui était demandé dans le sujet, à l'exception de la partie javascript.

## Point interessant sur notre projet : 
- Optimisation de la partie symbolique par suppression des `if` superflue
- Script permettant de passer d'un résultat d'une execution symbolique à un affichage visuel en prenant en configuration de départ le résultat.

## Difficulté rencontrés : 
- Difficulté sur la compréhension de l'arborescence du projet

##   Lancement du Jeu de la Vie
Pour lancer le jeu en mode concrete :
```sh
dune exec -- ono concrete test/cram/concrete/jdv.t/main.wat
```

Pour lancer le jeu en mode symbolique : 
```sh
dune exec -- ono concrete test/cram/concrete/jdv.t/main.wat
```
⚠️ Pour toute les commandes ci-dessous, les arguments des paramètres sont écris de la forme suivante {paramètre}, dans les commandes il faut évidemment ne pas mettre les guillements.

Nous avons fait un petit script permettant de prendre la sortie de l'execution symbolique du jeu de la vie pour pouvoir la convertir en fichier de configuration pouvant être utilisé par l'execution concrete.
Pour convertir la sortie symbolique en configuration on utilise donc le script `model_to_config.sh`:
```sh
dune exec -- ono symbolic --contraint {numero_contrainte} test/cram/symbolic/jdv.t/main.wat | ./model_to_config.sh
```

Commande complète pour lancer l'execution symbolique, et lancer le jeu en mode concrete avec la configuration en sortie : 
```sh
dune exec -- ono symbolic --contraint {numero_contrainte} --width {largeur} --height {hauteur} test/cram/symbolic/jdv.t/main.wat | ./model_to_config.sh {hauteur} {largeur} > cfg && cat cfg && dune exec -- ono concrete --steps 2 --n_printed 2 --start_with cfg test/cram/concrete/jdv.t/main.wat
```

## Commande disponible pour le jeu de la vie
⚠️ Pour toute les commandes ci-dessous, les arguments des paramètres sont écris de la forme suivante {paramètre}, dans les commandes il faut évidemment ne pas mettre les guillements.

### Concrete
1. `--seed {n}` : permet de préciser la seed à utiliser
2. `--steps {n}` : permet de préciser combien de tour on veut avant de terminer le programme
3. `--n_printed {n}` : permet d’afficher dans le terminal les n derniers tour du programme. Attention doit forcément être activé avec `--steps`.
4. `--start_with {filename}` : permet de lancer le jeu de la vie en commençant à partir d’une configuration précise
5. `--use_gui {bool}` : permet d’utiliser l’interface graphique au lieu de l’interface textuelle
  
### Symbolic
1. `--contraint {n}` : permet de sélectionner la contrainte que l’on recherche parmis la liste des contraintes plus basse, en la désignant par son numéro (par défaut 1)
2. `--height {n}` : permet de préciser la hauteur du terrain que l’on veut (par défaut 3)
3. `--width {n}` : permet de préciser la largeur du terrain que l’on veut (par défaut 3)

### Listes des contraintes implémentés : 
1. Au tour suivant, la cellule en position (0,0) doit être vivante.
2. Au tour suivant, la cellule en position (0,0) doit être morte.
3. Au tour suivant, il y a au moins une cellule vivante sur la grille.
4. Au tour suivant, toutes les cellules sont vivantes (ne fonctionne pas pour toutes les tailles).
5. Au tour suivant, toutes les cellules sont mortes.
6. Au tour suivant, la première ligne est vivante
7. Au tour suivant, la première colonne est vivante
8. Au tour suivant, il y a exactement 6 cellules vivantes dans la grille.
9. Au tour suivant, il existe une cellule isolée (i.e. dont toutes les cellules voisines sont mortes).
10. Au tour suivant, il existe une cellule entourée de cellules vivantes.
11. Au tour suivant, il existe deux cellules vivantes côte à côte.
12. Au tour suivant, il existe un motif en "L" de trois cellules vivantes.
13. Au tour suivant, il existe un motif carré de 2*2 cellules vivantes.
14. Au tour suivant, il existe une cellule morte qui est devenue vivante.
15. Au tour suivant, il y a une ligne/colonne avec une alternance de cellules vivantes/mortes.
16. Au tour suivant, il y a un motif en clignotant (un oscillateur de période 2).
17. Au tour suivant, il y a une diagonale vivante de 3 cellules.