(module
    (func $print_i32 (import "ono" "print_i32") (param i32))
    (func $sym_i32 (import "sym" "sym_i32") (result i32))

    (global $a (mut i32) (i32.const 0))
    (global $b (mut i32) (i32.const 0))
    (global $c (mut i32) (i32.const 0))
    (global $d (mut i32) (i32.const 0))

    (start $test_solution)

    (func $test_solution
        (call $is_solution ($sym_i32) (local.get $a) (local.get $b) (local.get $c) (local.get $d))
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

        ;; fst product (a * x^3)

        (i32.mul
            (local.get $a)
            (local.get $cube_x)
        )

        ;; snd product (b * x^2)

        (i32.mul
            (local.get $b)
            (local.get $square_x)
        )

        ;; thrd product (c * x)

        (i32.mul
            (local.get $c)
            (local.get $x)
        )

        ;; d

        local.get $d

        i32.add
        i32.add
        i32.add

        (local.set $final_value)

        (if (i32.eq (local.get $final_value) (i32.const 0))
            (then
                unreachable
            )
            (else
                (return (local.get $x))
            )
        )
    )
)

