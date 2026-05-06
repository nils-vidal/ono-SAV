(module
    (func $sym_i32 (import "ono" "i32_symbol") (result i32))
    (func $sym_cell (import "ono" "sym_cell") (result i32))
    (func $mutation_factor (import "ono" "mutation_factor") (result i32))
    (func $get_num_contrainte (import "ono" "get_num_contrainte") (result i32))
    (func $get_width (import "ono" "get_width") (result i32))
    (func $get_height (import "ono" "get_height") (result i32))


    (global $w (mut i32) (i32.const 10))
    (global $h (mut i32) (i32.const 10))
    (memory 1)

    (func $is_alive (param $col i32) (param $row i32) (result i32)
        (local $in_bounds i32)
        (local $cell_addr i32)

        (local.set $in_bounds
            (i32.and
                (i32.and
                    (i32.ge_s (local.get $col) (i32.const 0))
                    (i32.lt_s (local.get $col) (global.get $w))
                )
                (i32.and
                    (i32.ge_s (local.get $row) (i32.const 0))
                    (i32.lt_s (local.get $row) (global.get $h))
                )
            )
        )

        (local.set $cell_addr
            (i32.mul
                (i32.add
                    (i32.mul (local.get $row) (global.get $w))
                    (local.get $col)
                )
                (i32.const 4)
            )
        )

        (i32.and
            (i32.load
                (select (local.get $cell_addr) (i32.const 0) (local.get $in_bounds))
            )
            (local.get $in_bounds)
        )
    )

    (func $count_alive_neighbours (param $col i32) (param $row i32) (result i32)
        (call $is_alive ;; is_alive(col, row+1)
            (local.get $col) 
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $is_alive ;; is_alive(col, row-1)
            (local.get $col) 
            (i32.sub (local.get $row) (i32.const 1))
        )   
        (call $is_alive ;; is_alive(col-1, row)
            (i32.sub (local.get $col) (i32.const 1)) 
            (local.get $row)
        )
        (call $is_alive ;; is_alive(col+1, row)
            (i32.add (local.get $col) (i32.const 1)) 
            (local.get $row)
        )
        (call $is_alive ;; is_alive(col-1, row-1)
            (i32.sub (local.get $col) (i32.const 1)) 
            (i32.sub (local.get $row) (i32.const 1))
        )    
        (call $is_alive ;; is_alive(col+1, row+1)
            (i32.add (local.get $col) (i32.const 1)) 
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $is_alive ;; is_alive(col-1, row+1)
            (i32.sub (local.get $col) (i32.const 1)) 
            (i32.add (local.get $row) (i32.const 1))
        )
        (call $is_alive ;; is_alive(col+1, row-1)
            (i32.add (local.get $col) (i32.const 1))
            (i32.sub (local.get $row) (i32.const 1))
        )

        i32.add
        i32.add
        i32.add
        i32.add
        i32.add
        i32.add
        i32.add
        ;; retour implicite sur la derniere valeur de la pile qui est l'addition de tous les appels de is_alive
    )
    
    ;; for tests
    (func $fill_symbolic
        (local $num_cells i32)
        (local $i i32)
        (local.set $num_cells (i32.mul (global.get $w) (global.get $h)))
        (local.set $i (i32.const 0))
        (block $break_init
            (loop $init_loop
                (i32.store
                    (i32.mul (local.get $i) (i32.const 4))
                    (call $sym_cell)
                )
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br_if $break_init (i32.ge_u (local.get $i) (local.get $num_cells)))
                (br $init_loop)
            )
        )
    )


    (func $cell_index (param $col i32) (param $row i32) (result i32)
        (i32.add
            (i32.mul (local.get $row) (global.get $w))
            (local.get $col)
        )
    )

    (func $store_neighbour_count (param $index i32) (param $array_size i32) (param $count i32)
        (i32.store
            (i32.mul
                (i32.add
                    (local.get $index)
                    (local.get $array_size)
                )
                (i32.const 4)
            )
            (local.get $count)
        )
    )

    (func $load_neighbour_count (param $index i32) (param $array_size i32) (result i32)
        (i32.load
            (i32.mul
                (i32.add
                    (local.get $index)
                    (local.get $array_size)
                )
                (i32.const 4)
            )
        )
    )

    (func $next_cell_state (param $cell_alive i32) (param $alive_neighbours_count i32) (result i32)
        (i32.or
            (i32.or
                (i32.and
                    (local.get $cell_alive)
                    (i32.eq (local.get $alive_neighbours_count) (i32.const 2))
                )
                (i32.eq (local.get $alive_neighbours_count) (i32.const 3))
            )
            (i32.eq (call $mutation_factor) (i32.const 0))
        )
    )

    (func $compute_all_neighbour_counts (param $array_size i32)
        (local $row i32)
        (local $column i32)
        (local $index i32)
        (local $count i32)

        (local.set $column (i32.const 0))
        (local.set $row (i32.const 0))

        (block $break_row
            (loop $loop_row
                (br_if $break_row (i32.eq (local.get $row) (global.get $h)))

                (block $break_col
                    (loop $loop_col
                        (br_if $break_col (i32.eq (local.get $column) (global.get $w)))

                        (local.set $index (call $cell_index (local.get $column) (local.get $row)))
                        (local.set $count (call $count_alive_neighbours (local.get $column) (local.get $row)))
                        (call $store_neighbour_count (local.get $index) (local.get $array_size) (local.get $count))

                        (local.set $column (i32.add (local.get $column) (i32.const 1)))
                        (br $loop_col)
                    )
                )

                (local.set $column (i32.const 0))
                (local.set $row (i32.add (local.get $row) (i32.const 1)))
                (br $loop_row)
            )
        )
    )

    (func $apply_all_next_states (param $array_size i32)
        (local $row i32)
        (local $column i32)
        (local $index i32)
        (local $cell_alive i32)
        (local $alive_neighbours_count i32)
        (local $live i32)

        (local.set $column (i32.const 0))
        (local.set $row (i32.const 0))

        (block $break_row
            (loop $loop_row
                (br_if $break_row (i32.eq (local.get $row) (global.get $h)))

                (block $break_col
                    (loop $loop_col
                        (br_if $break_col (i32.eq (local.get $column) (global.get $w)))

                        (local.set $index (call $cell_index (local.get $column) (local.get $row)))
                        (local.set $cell_alive
                            (i32.load
                                (i32.mul (local.get $index) (i32.const 4))
                            )
                        )
                        (local.set $alive_neighbours_count
                            (call $load_neighbour_count (local.get $index) (local.get $array_size))
                        )
                        (local.set $live
                            (call $next_cell_state
                                (local.get $cell_alive)
                                (local.get $alive_neighbours_count)
                            )
                        )

                        (i32.store
                            (i32.mul (local.get $index) (i32.const 4))
                            (local.get $live)
                        )

                        (local.set $column (i32.add (local.get $column) (i32.const 1)))
                        (br $loop_col)
                    )
                )

                (local.set $column (i32.const 0))
                (local.set $row (i32.add (local.get $row) (i32.const 1)))
                (br $loop_row)
            )
        )
    )

    (func $step
        (local $array_size i32)
        (local.set $array_size (i32.mul (global.get $w) (global.get $h)))

        (call $compute_all_neighbour_counts (local.get $array_size))
        (call $apply_all_next_states (local.get $array_size))
    )




    ;; -------------------- CONFIG --------------------
    (func $first_cell_alive ;; config 1
        (if (i32.eq (call $is_alive (i32.const 1) (i32.const 1)) (i32.const 0))
            (then (unreachable)) ;; Si morte, ce chemin ne nous intéresse pas !
        )
    )


    (func $first_cell_dead ;; config 2
        (if (i32.ne (call $is_alive (i32.const 1) (i32.const 1)) (i32.const 0))
            (then (unreachable)) ;; Si morte, ce chemin ne nous intéresse pas !
        )
    )

    (func $at_least_one_alive ;; config 3
        (local $i i32)
        (local $num_cells i32)
        (local $any_alive i32)
        (local.set $num_cells (i32.mul (global.get $w) (global.get $h)))
        (local.set $i (i32.const 0))
        (local.set $any_alive (i32.const 0))

        (block $break_check
            (loop $check_loop
                (local.set $any_alive
                    (i32.or
                        (local.get $any_alive)
                        (i32.load (i32.mul (local.get $i) (i32.const 4)))
                    )
                )
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br_if $break_check (i32.ge_u (local.get $i) (local.get $num_cells)))
                (br $check_loop)
            )
        )
        (if (local.get $any_alive)
            (then (unreachable))
        )
    )
    
    ;; 5. Au tour suivant, toutes les cellules sont mortes.
    (func $all_dead
        (local $i i32)
        (local $num_cells i32)
        (local $any_alive i32)
        (local.set $num_cells (i32.mul (global.get $w) (global.get $h)))
        (local.set $i (i32.const 0))
        (local.set $any_alive (i32.const 0))

        (block $break_check
            (loop $check_loop
                (local.set $any_alive
                    (i32.or
                        (local.get $any_alive)
                        (i32.load (i32.mul (local.get $i) (i32.const 4)))
                    )
                )
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br_if $break_check (i32.ge_u (local.get $i) (local.get $num_cells)))
                (br $check_loop)
            )
        )
        (if (i32.eqz (local.get $any_alive))
            (then (unreachable))
        )
    )
    
    ;; 7. Au tour suivant, il y a une colonne complète de cellules vivantes entre (x, y) et (x, y′) .
    (func $column_alive (param $x i32) (param $y1 i32) (param $y2 i32)
      (local $i i32)
      (local $all_alive i32)
      (local.set $i (local.get $y1))
      (local.set $all_alive (i32.const 1))

      (block $break_check
        (loop $check_loop
          (local.set $all_alive
            (i32.and
              (local.get $all_alive)
              (call $is_alive (local.get $x) (local.get $i))
            )
          )
          (local.set $i (i32.add (local.get $i) (i32.const 1)))
          (br_if $break_check (i32.gt_s (local.get $i) (local.get $y2)))
          (br $check_loop)
        )
      )
      (if (local.get $all_alive)
        (then (unreachable))
      )
    )

    ;; 9. Au tour suivant, il existe une cellule isolée (i.e. dont toutes les cellules voisines sont mortes).
    (func $isolated_cell
        (local $col i32)
        (local $row i32)
        (local $any_isolated i32)
        (local $interior i32)
        (local $isolated i32)

        (local.set $any_isolated (i32.const 0))
        (local.set $row (i32.const 0))

        (block $break_row
            (loop $loop_row
                (br_if $break_row (i32.eq (local.get $row) (global.get $h)))

                (local.set $col (i32.const 0))
                (block $break_col
                    (loop $loop_col
                        (br_if $break_col (i32.eq (local.get $col) (global.get $w)))

                        ;; interior = non-border cell
                        (local.set $interior
                            (i32.and
                                (i32.and
                                    (i32.gt_s (local.get $col) (i32.const 0))
                                    (i32.lt_s (local.get $col) (i32.sub (global.get $w) (i32.const 1)))
                                )
                                (i32.and
                                    (i32.gt_s (local.get $row) (i32.const 0))
                                    (i32.lt_s (local.get $row) (i32.sub (global.get $h) (i32.const 1)))
                                )
                            )
                        )

                        ;; isolated = interior & alive & (neighbours == 0)
                        (local.set $isolated
                            (i32.and
                                (i32.and
                                    (local.get $interior)
                                    (call $is_alive (local.get $col) (local.get $row))
                                )
                                (i32.eqz
                                    (call $count_alive_neighbours (local.get $col) (local.get $row))
                                )
                            )
                        )

                        (local.set $any_isolated
                            (i32.or (local.get $any_isolated) (local.get $isolated))
                        )

                        (local.set $col (i32.add (local.get $col) (i32.const 1)))
                        (br $loop_col)
                    )
                )

                (local.set $row (i32.add (local.get $row) (i32.const 1)))
                (br $loop_row)
            )
        )

        (if (local.get $any_isolated)
            (then (unreachable))
        )
    )

    ;; 11. Au tour suivant, il existe deux cellules vivantes côte à côte.
    (func $two_adjacent_alive
        (local $col i32)
        (local $row i32)
        (local $any_adj i32)

        (local.set $any_adj (i32.const 0))
        (local.set $row (i32.const 0))
        (block $break_row
            (loop $loop_row
                (br_if $break_row (i32.eq (local.get $row) (global.get $h)))

                (local.set $col (i32.const 0))
                (block $break_col
                    (loop $loop_col
                        (br_if $break_col (i32.eq (local.get $col) (global.get $w)))

                        ;; horizontal | vertical adjacency
                        (local.set $any_adj
                            (i32.or
                                (local.get $any_adj)
                                (i32.or
                                    (i32.and
                                        (call $is_alive (local.get $col) (local.get $row))
                                        (call $is_alive
                                            (i32.add (local.get $col) (i32.const 1))
                                            (local.get $row)
                                        )
                                    )
                                    (i32.and
                                        (call $is_alive (local.get $col) (local.get $row))
                                        (call $is_alive
                                            (local.get $col)
                                            (i32.add (local.get $row) (i32.const 1))
                                        )
                                    )
                                )
                            )
                        )

                        (local.set $col (i32.add (local.get $col) (i32.const 1)))
                        (br $loop_col)
                    )
                )

                (local.set $row (i32.add (local.get $row) (i32.const 1)))
                (br $loop_row)
            )
        )

        (if (local.get $any_adj)
            (then (unreachable))
        )
    )

    ;; 13. Au tour suivant, il existe un motif carré de 2*2 cellules vivantes.
    (func $square_2x2_alive
        (local $col i32)
        (local $row i32)
        (local $any_square i32)

        (local.set $any_square (i32.const 0))
        (local.set $row (i32.const 0))
        (block $break_row
            (loop $loop_row
                (br_if $break_row
                    (i32.ge_s (local.get $row) (i32.sub (global.get $h) (i32.const 1)))
                )

                (local.set $col (i32.const 0))
                (block $break_col
                    (loop $loop_col
                        (br_if $break_col
                            (i32.ge_s (local.get $col) (i32.sub (global.get $w) (i32.const 1)))
                        )

                        (local.set $any_square
                            (i32.or
                                (local.get $any_square)
                                (i32.and
                                    (i32.and
                                        (call $is_alive (local.get $col) (local.get $row))
                                        (call $is_alive
                                            (i32.add (local.get $col) (i32.const 1))
                                            (local.get $row)
                                        )
                                    )
                                    (i32.and
                                        (call $is_alive
                                            (local.get $col)
                                            (i32.add (local.get $row) (i32.const 1))
                                        )
                                        (call $is_alive
                                            (i32.add (local.get $col) (i32.const 1))
                                            (i32.add (local.get $row) (i32.const 1))
                                        )
                                    )
                                )
                            )
                        )

                        (local.set $col (i32.add (local.get $col) (i32.const 1)))
                        (br $loop_col)
                    )
                )

                (local.set $row (i32.add (local.get $row) (i32.const 1)))
                (br $loop_row)
            )
        )

        (if (local.get $any_square)
            (then (unreachable))
        )
    )

    ;; 15. Au tour suivant, il y a une ligne/colonne avec une alternance
    ;; de cellules vivantes/mortes.
    (func $alternating_line
        (local $i i32)
        (local $j i32)
        (local $alt i32)
        (local $any_alt i32)

        (local.set $any_alt (i32.const 0))

        ;; Lignes: pour chaque row, alt = AND sur (a XOR b) de paires adjacentes.
        (local.set $j (i32.const 0))
        (block $break_rows
            (loop $loop_rows
                (br_if $break_rows (i32.eq (local.get $j) (global.get $h)))

                (local.set $alt (i32.const 1))
                (local.set $i (i32.const 0))
                (block $break_pair
                    (loop $loop_pair
                        (br_if $break_pair
                            (i32.ge_s (local.get $i) (i32.sub (global.get $w) (i32.const 1)))
                        )
                        (local.set $alt
                            (i32.and
                                (local.get $alt)
                                (i32.xor
                                    (call $is_alive (local.get $i) (local.get $j))
                                    (call $is_alive
                                        (i32.add (local.get $i) (i32.const 1))
                                        (local.get $j)
                                    )
                                )
                            )
                        )
                        (local.set $i (i32.add (local.get $i) (i32.const 1)))
                        (br $loop_pair)
                    )
                )
                (local.set $any_alt (i32.or (local.get $any_alt) (local.get $alt)))

                (local.set $j (i32.add (local.get $j) (i32.const 1)))
                (br $loop_rows)
            )
        )

        ;; Colonnes: même idée, col fixe, pair sur lignes adjacentes.
        (local.set $i (i32.const 0))
        (block $break_cols
            (loop $loop_cols
                (br_if $break_cols (i32.eq (local.get $i) (global.get $w)))

                (local.set $alt (i32.const 1))
                (local.set $j (i32.const 0))
                (block $break_pair2
                    (loop $loop_pair2
                        (br_if $break_pair2
                            (i32.ge_s (local.get $j) (i32.sub (global.get $h) (i32.const 1)))
                        )
                        (local.set $alt
                            (i32.and
                                (local.get $alt)
                                (i32.xor
                                    (call $is_alive (local.get $i) (local.get $j))
                                    (call $is_alive
                                        (local.get $i)
                                        (i32.add (local.get $j) (i32.const 1))
                                    )
                                )
                            )
                        )
                        (local.set $j (i32.add (local.get $j) (i32.const 1)))
                        (br $loop_pair2)
                    )
                )
                (local.set $any_alt (i32.or (local.get $any_alt) (local.get $alt)))

                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br $loop_cols)
            )
        )

        (if (local.get $any_alt)
            (then (unreachable))
        )
    )

    ;; 17. Au tour suivant, il y a une diagonale vivante de N cellules.
    (func $diagonal_alive (param $n i32)
        (local $c i32)
        (local $r i32)
        (local $k i32)
        (local $all i32)
        (local $any_diag i32)
        (local $cmax i32)
        (local $rmax i32)

        (local.set $cmax (i32.sub (global.get $w) (local.get $n)))
        (local.set $rmax (i32.sub (global.get $h) (local.get $n)))
        (local.set $any_diag (i32.const 0))

        ;; Direction 1: descendante-droite (col+k, row+k)
        (local.set $r (i32.const 0))
        (block $break_r1
            (loop $loop_r1
                (br_if $break_r1 (i32.gt_s (local.get $r) (local.get $rmax)))

                (local.set $c (i32.const 0))
                (block $break_c1
                    (loop $loop_c1
                        (br_if $break_c1 (i32.gt_s (local.get $c) (local.get $cmax)))

                        (local.set $all (i32.const 1))
                        (local.set $k (i32.const 0))
                        (block $break_k1
                            (loop $loop_k1
                                (br_if $break_k1 (i32.eq (local.get $k) (local.get $n)))
                                (local.set $all
                                    (i32.and
                                        (local.get $all)
                                        (call $is_alive
                                            (i32.add (local.get $c) (local.get $k))
                                            (i32.add (local.get $r) (local.get $k))
                                        )
                                    )
                                )
                                (local.set $k (i32.add (local.get $k) (i32.const 1)))
                                (br $loop_k1)
                            )
                        )
                        (local.set $any_diag (i32.or (local.get $any_diag) (local.get $all)))

                        (local.set $c (i32.add (local.get $c) (i32.const 1)))
                        (br $loop_c1)
                    )
                )

                (local.set $r (i32.add (local.get $r) (i32.const 1)))
                (br $loop_r1)
            )
        )

        ;; Direction 2: descendante-gauche (col-k, row+k), col part de n-1
        (local.set $r (i32.const 0))
        (block $break_r2
            (loop $loop_r2
                (br_if $break_r2 (i32.gt_s (local.get $r) (local.get $rmax)))

                (local.set $c (i32.sub (local.get $n) (i32.const 1)))
                (block $break_c2
                    (loop $loop_c2
                        (br_if $break_c2 (i32.ge_s (local.get $c) (global.get $w)))

                        (local.set $all (i32.const 1))
                        (local.set $k (i32.const 0))
                        (block $break_k2
                            (loop $loop_k2
                                (br_if $break_k2 (i32.eq (local.get $k) (local.get $n)))
                                (local.set $all
                                    (i32.and
                                        (local.get $all)
                                        (call $is_alive
                                            (i32.sub (local.get $c) (local.get $k))
                                            (i32.add (local.get $r) (local.get $k))
                                        )
                                    )
                                )
                                (local.set $k (i32.add (local.get $k) (i32.const 1)))
                                (br $loop_k2)
                            )
                        )
                        (local.set $any_diag (i32.or (local.get $any_diag) (local.get $all)))

                        (local.set $c (i32.add (local.get $c) (i32.const 1)))
                        (br $loop_c2)
                    )
                )

                (local.set $r (i32.add (local.get $r) (i32.const 1)))
                (br $loop_r2)
            )
        )

        (if (local.get $any_diag)
            (then (unreachable))
        )
    )

    ;; -------------------- CONFIG --------------------


    (func $select_config
        (local $num i32)
        (local.set $num (call $get_num_contrainte))
        
        ;; 1. Au tour suivant, la cellule (1, 1) est vivante.
        (if (i32.eq (local.get $num) (i32.const 1))
            (then (call $first_cell_alive) (return))
        )
        ;; 2. Au tour suivant, la cellule (1, 1) est morte.
        (if (i32.eq (local.get $num) (i32.const 2))
            (then (call $first_cell_dead) (return))
        )

        ;; 3. Au tour suivant, il y a au moins une cellule vivante sur la grille.
        (if (i32.eq (local.get $num) (i32.const 3))
            (then (call $at_least_one_alive) (return))
        )
        ;; 5. Au tour suivant, toutes les cellules sont mortes.
        (if (i32.eq (local.get $num) (i32.const 5))
            (then (call $all_dead) (return))
        )
        ;; 7. Au tour suivant, il y a une colonne complète de cellules vivantes.
        (if (i32.eq (local.get $num) (i32.const 7))
            (then
                (call $column_alive
                    (i32.const 0)
                    (i32.const 0)
                    (i32.sub (global.get $h) (i32.const 1))
                )
                (return)
            )
        )
        ;; 9. Au tour suivant, il existe une cellule isole.
        (if (i32.eq (local.get $num) (i32.const 9))
            (then (call $isolated_cell) (return))
        )
        ;; 11. Au tour suivant, il existe deux cellules vivantes côte à côte.
        (if (i32.eq (local.get $num) (i32.const 11))
            (then (call $two_adjacent_alive) (return))
        )
        ;; 13. Au tour suivant, il existe un motif carré de 2x2 cellules vivantes.
        (if (i32.eq (local.get $num) (i32.const 13))
            (then (call $square_2x2_alive) (return))
        )
        ;; 15. Au tour suivant, il y a une ligne/colonne en alternance.
        (if (i32.eq (local.get $num) (i32.const 15))
            (then (call $alternating_line) (return))
        )
        ;; 17. Au tour suivant, il y a une diagonale vivante de N cellules.
        (if (i32.eq (local.get $num) (i32.const 17))
            (then (call $diagonal_alive (i32.const 3)) (return))
        )
    )

    (func $main
        (global.set $w (call $get_width))
        (global.set $h (call $get_height))

        (call $fill_symbolic) ;; initialisation du board
        (call $step) ;; application d'un tour de boucle
        
        (call $select_config) ;; on cherche la config interessante demandé soit par l'utilisateur en ligne de commande, soit une aléatoire 
    )

    (start $main)
    
)
