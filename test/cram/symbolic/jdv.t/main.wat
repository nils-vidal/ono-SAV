(module
    (func $sym_i32 (import "ono" "i32_symbol") (result i32))
    (func $mutation_factor (import "ono" "mutation_factor") (result i32))

    (global $w (mut i32) (i32.const 40))
    (global $h (mut i32) (i32.const 30))
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
    
    ;; for tests
    (func $fill_symbolic
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
                    (local.set $flag (call $sym_i32))
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
        (local $live i32)

        (if (i32.eq (local.get $cell_alive) (i32.const 1))
            (then
                (local.set $live
                    (i32.or
                        (i32.eq (local.get $alive_neighbours_count) (i32.const 2))
                        (i32.eq (local.get $alive_neighbours_count) (i32.const 3))
                    )
                )
            )
            (else
                (local.set $live
                    (i32.eq (local.get $alive_neighbours_count) (i32.const 3))
                )
            )
        )

        (i32.or
            (local.get $live)
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


    (func $main
        (call $fill_symbolic) ;; initialisation du board
        (call $step) ;; application des contraites
    )

    (start $main)
    
)
