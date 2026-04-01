(module
    (func $sym_i32 (import "ono" "i32_symbol") (result i32))
    (func $ask_for_a_value (import "ono" "ask_for_a_value") (result i32))
    (func $ask_for_b_value (import "ono" "ask_for_b_value") (result i32))
    (func $ask_for_c_value (import "ono" "ask_for_c_value") (result i32))
    (func $ask_for_d_value (import "ono" "ask_for_d_value") (result i32))


    (global $a (mut i32) (i32.const 0))
    (global $b (mut i32) (i32.const 0))
    (global $c (mut i32) (i32.const 0))
    (global $d (mut i32) (i32.const 0))

    (start $test_solution)

    (func $test_solution
        (global.set $a (call $ask_for_a_value))
        (global.set $b (call $ask_for_b_value))
        (global.set $c (call $ask_for_c_value))
        (global.set $d (call $ask_for_d_value))

        (drop
            (call $is_solution (call $sym_i32) (global.get $a) (global.get $b) (global.get $c) (global.get $d))
        )

    )

    (func $is_solution (param $x i32) (param $a i32) (param $b i32) (param $c i32) (param $d i32) (result i32)
        (local $square_x i32)
        (local $cube_x i32)
        (local $final_value i32)

        (local.set $square_x
            (i32.mul
                (local.get $x)
                (local.get $x)))

        (local.set $cube_x
            (i32.mul
                (local.get $square_x)
                (local.get $x)))

        (local.set $final_value
            (i32.add
                (i32.add
                    (i32.mul (local.get $a) (local.get $cube_x))
                    (i32.mul (local.get $b) (local.get $square_x))
                )
                (i32.add
                    (i32.mul (local.get $c) (local.get $x))
                    (local.get $d)
                )
            )
        )

        (if (result i32) (i32.eq (local.get $final_value) (i32.const 0))
            (then (unreachable))
            (else (local.get $x))
        )
    )
)

