(module
    (func $sleep (import "ono" "sleep") (param f32))
    (func $print_cell (import "ono" "print_cell") (param i32))
    (func $newline (import "ono" "newline"))
    (func $clear_screen (import "ono" "clear_screen"))
    (func $print_i32 (import "ono" "print_i32") (param i32))
    (func $random_i32_bounded (import "ono" "random_i32_bounded") (param i32) (result i32))
    
    (global $w i32 (i32.const 40))
    (global $h i32 (i32.const 30))
    (memory 1)

    (func $read_cell (param $row i32) (param $col i32) (result i32)
          (local $index2d i32)
          (local.set $index2d
            (i32.add
              (i32.mul (local.get $row) (global.get $w))
              (local.get $col)
            )
          )
          (i32.load (i32.mul (local.get $index2d) (i32.const 4)))
    )

    (func $print_grid
        (local $row i32)
        (local $col i32)
        (local $is_cur_cell_alive i32)
        
        (call $clear_screen)

        (local.set $row (i32.const 0))
        (block $break_row
          (loop $print_row
            (local.set $col (i32.const 0))
            (block $break_column
              (loop $print_column
                (local.set $is_cur_cell_alive (call $read_cell (local.get $row) (local.get $col)))
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
    
    (func $main
        (loop $main_loop
            ;; for tests
            (call $fill_random)
            
            (call $print_grid)
            (call $sleep (f32.const 1.0))
            (br $main_loop)
        )
    )
    
    (start $main)
    
)
