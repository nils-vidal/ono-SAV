(module
    (func $sleep (import "ono" "sleep") (param f32))
    (func $print_cell (import "ono" "print_cell") (param i32))
    (func $newline (import "ono" "newline"))
    (func $clear_screen (import "ono" "clear_screen"))
    (func $print_i32 (import "ono" "print_i32") (param i32))
    (func $print_i64 (import "ono" "print_i64") (param i64))
    (func $random_i32_bounded (import "ono" "random_i32_bounded") (param i32) (result i32))
    (func $read_int (import "ono" "read_int") (result i64))
    (func $read_step (import "ono" "read_step") (result i32))
    (func $read_number_line_to_print (import "ono" "read_number_line_to_print") (result i32))
    
    (global $w i32 (i32.const 40))
    (global $h i32 (i32.const 30))
    (memory 1)

    
    (func $is_alive (param $col i32) (param $row i32) (result i32)
        (local $index2d i32)
        (if ;; teste borne supérieure
            (i32.or
                (i32.ge_s ;; si col est plus grand que w
                    (local.get $col) 
                    (global.get $w)
                )
                (i32.ge_s ;; si row est plus grand que h
                    (local.get $row)
                    (global.get $h)
                )
            )
            (then 
                (return (i32.const 0))
            )
        )
        (if ;; teste borne inferieure
            (i32.or
                (i32.lt_s ;; si col est plus petit que 0
                    (local.get $col)
                    (i32.const 0)
                )
                (i32.lt_s ;; si row est plus petit que 0
                    (local.get $row)
                    (i32.const 0)
                )
            )

            (then 
                (return (i32.const 0))
            )
        )
        (local.set $index2d
            (i32.add
                (i32.mul (local.get $row) (global.get $w))
                (local.get $col)
            )
        )
        (i32.load (i32.mul (local.get $index2d) (i32.const 4)))
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

    (func $print_grid (param $clear i32)
        (local $row i32)
        (local $col i32)
        (local $is_cur_cell_alive i32)
         
        (if
            (local.get $clear) ;; (clear = 0) => on clear pas le screen  
            (then (call $clear_screen))
        )

        (local.set $row (i32.const 0))
        (block $break_row
          (loop $print_row
            (local.set $col (i32.const 0))
            (block $break_column
              (loop $print_column
                (local.set $is_cur_cell_alive (call $is_alive (local.get $col) (local.get $row)))
                (call $print_cell (local.get $is_cur_cell_alive))
                (local.set $col (i32.add (local.get $col) (i32.const 1)))
                (br_if $break_column (i32.ge_u (local.get $col) (global.get $w)))
                (br $print_column)
              )
            )

            (local.set $row (i32.add (local.get $row) (i32.const 1)))
            (call $newline)
            (br_if $break_row (i32.ge_u (local.get $row) (global.get $h)))
            (br $print_row)
          )
        )
        (call $newline)
    )
    
    ;; for tests
    (func $fill_random
        (local $num_cells i32)
            (local $i i32)
            (local $flag i32)
            (local.set $num_cells (i32.mul (global.get $w) (global.get $h)))
            (local.set $flag (i32.const 0))
            (local.set $i (i32.const 0))
            (block $break_init
                (loop $init_loop
                    (i32.store
                        (i32.mul (local.get $i) (i32.const 4))
                        (local.get $flag)
                    )
                    (local.set $flag (call $random_i32_bounded (i32.const 2)))
                    (local.set $i (i32.add (local.get $i) (i32.const 1)))
                    (br_if $break_init (i32.ge_u (local.get $i) (local.get $num_cells)))
                    (br $init_loop)
                )
            )
    )

    (func $step
        (local $array_size i32)
        (local $row i32)
        (local $column i32)
        (local $res i32)
        (local $top_stack i32)
        (local $cell_alive i32)
        (local $live i32)
        (local $alive_neigbhors_count i32)
        (local $current_coord_index i32)

        (local.set $array_size (i32.mul (global.get $w) (global.get $h)))


        (local.set $column (i32.const 0))
        (local.set $row (i32.const 0))

        (block $break_row_1
            (loop $loop_row_1
                (br_if $break_row_1 (i32.eq (local.get $row) (global.get $h)))

                (block $break_col_1
                    (loop $loop_col_1
                        (br_if $break_col_1 (i32.eq (local.get $column) (global.get $w)))

                        (local.set $res (call $count_alive_neighbours (local.get $column) (local.get $row)))

                        ;; (if (i32.and (i32.le_s (local.get $row) (i32.const 2)) (i32.le_s (local.get $column) (i32.const 2)))
                        ;;     (then
                        ;;         (call $print_i32 (local.get $column))
                        ;;         (call $print_i32 (i32.const -1))
                        ;;         (call $print_i32 (local.get $row))
                        ;;         (call $print_i32 (i32.const -1))
                        ;;         (call $print_i32 (local.get $res))
                        ;;         (call $print_i32 (i32.const -1111111))
                        ;;         (call $newline)
                        ;;     )
                        ;; )

                        (i32.store
                            (i32.add
                                (i32.mul
                                    (i32.add
                                        (local.get $column)
                                        (i32.mul (local.get $row) (global.get $w))
                                    )
                                    (i32.const 4)
                                )
                                (local.get $array_size)
                            )
                            (local.get $res)
                        )

                        (local.set $column 
                            (i32.add (local.get $column) (i32.const 1))
                        )
                        (br $loop_col_1)
                    )
                )

                (local.set $column (i32.const 0))
                (local.set $row 
                    (i32.add (local.get $row) (i32.const 1))
                )
                (br $loop_row_1)
            )
        )

        (local.set $row (i32.const 0))
        (local.set $column (i32.const 0))

        (block $break_row_2
            (loop $loop_row_2
                (br_if $break_row_2 (i32.eq (local.get $row) (global.get $h)))

                (block $break_col_2
                    (loop $loop_col_2
                        (br_if $break_col_2 (i32.eq (local.get $column) (global.get $w)))

                        (local.set $current_coord_index
                            (i32.add
                                (i32.mul (local.get $row) (global.get $w))
                                (local.get $column)
                            )
                        )

                        (local.set $cell_alive
                            (i32.load 
                                (i32.mul (local.get $current_coord_index) (i32.const 4))
                            )
                        )

                        (local.set $alive_neigbhors_count
                            (i32.load
                                (i32.add
                                    (i32.mul (local.get $current_coord_index) (i32.const 4))
                                    (local.get $array_size)
                                )
                            )
                        )

                        (if (i32.eq (local.get $cell_alive) (i32.const 1))
                            (then
                                (local.set $live
                                    (i32.or
                                        (i32.eq (local.get $alive_neigbhors_count) (i32.const 2))
                                        (i32.eq (local.get $alive_neigbhors_count) (i32.const 3))
                                    )
                                )
                            )
                            (else
                                (local.set $live
                                    (i32.eq (local.get $alive_neigbhors_count) (i32.const 3))
                                )
                            )
                        )

                        (local.set $live
                            (i32.or
                                (local.get $live)
                                (i32.eq (call $random_i32_bounded (i32.const 100)) (i32.const 0))
                            )
                        )

                        (i32.store
                            (i32.mul (local.get $current_coord_index) (i32.const 4))
                            (local.get $live)
                        )

                        (local.set $column (i32.add (local.get $column) (i32.const 1)))
                        (br $loop_col_2)
                    )
                )

                (local.set $column (i32.const 0))
                (local.set $row (i32.add (local.get $row) (i32.const 1)))
                (br $loop_row_2)
            )
        )
    )

    (func $draw (param $steps_max i32) (param $current_steps i32) (param $n_to_print i32)
        (if
            (i32.ge_u ;; condition => steps_max - current_steps > n_to_print
                (i32.sub ;; steps_max - current_steps
                    (local.get $steps_max)
                    (local.get $current_steps)
                )
                (local.get $n_to_print)
            )
            (then return) ;; then => on print pas
            (else
                (call $print_grid (i32.const 0))
                (call $sleep (f32.const 0.5))
                (call $newline)
            ) ;; else => on print
        )
    )

    (func $main
        (local $number_steps i32)
        (local $current_number_steps i32)
        (local $n_to_print i32)
        (local.set $n_to_print (call $read_number_line_to_print))
        (local.set $number_steps (call $read_step))
        (local.set $current_number_steps (i32.const 1)) ;; =1 car si option --steps non précisé la boucle reste infine car 1 > 0 donc 1+x > 0, avec x le nombre de tour de boucle


        (call $fill_random)
        (block $break_main_loop
            (loop $main_loop
                ;; for tests


                (if
                    (i32.eq ;; si il n'y a pas besoin de faire l'affichage particulier
                        (local.get $n_to_print)
                        (i32.const 0)
                    )
                    (then 
                        (call $print_grid (i32.const 1))
                        (call $sleep (f32.const 1.0))
                    ) ;; print en clearant le screen
                    (else ;; sinon on fait l'affiche que des n derniers état du jeu
                        (call $draw
                            (local.get $number_steps)
                            (local.get $current_number_steps)
                            (local.get $n_to_print)
                        )
                    )
                )

                (call $step)

                ;; test si fin, sinon +1 a current number step
                (br_if $break_main_loop (i32.eq (local.get $current_number_steps) (local.get $number_steps)))
                (local.set $current_number_steps (i32.add (local.get $current_number_steps) (i32.const 1)))

                (br $main_loop)
            )
        )
    )

    (start $main)
    
)
