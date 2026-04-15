# Changelog

## 0.4 - 2026-04-15

### Added
- interpreteur symbolique
- ajout de la configuration initiale : case (1,1) en vie
- ajout de la configuration initiale : case (1,1) morte
- ajout de la configuration initiale : au moins une cellule en vie

## 0.3 - 2026-03-20

### Added
- implémentation totale du jeu de la vie
- ajout du parametre --seed permettant de lancer un jeu de la vie en précisant une seed
- ajout du parametre --steps permettant d'arreter le jeu de la vie à un certain nombre de tour
- ajout du parametre --n_printed, devant s'executer avec le parametre --step obligatoirement, permettant de n'afficher que les n derniers tour du jeu de la vie
- ajout du parametre --start_with, permettant de lancer le jeu de la vie en précisant un fichier pour préciser l'état de base
- ajout du parametre --use_gui permettant, si il est mit à true d'utiliser l'interface graphique plutot que l'interface textuelle
- ajout de tests pour vérifier le fonctionnement général du jeu de la vie

## 0.2 - 2026-02-18

### Added
- ajout des fonctions print_i32, print_i64 et random_i32
- ajout des test random_i32.wat, square.wat et factorial.wat permettant de tester respectivement les fonctions random_i32, print_i64 et print_i32

## 0.1 - 2025-12-16

- first version
