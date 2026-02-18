(module
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $fac (param $n i32) (result i32)

        (if
          (i32.eq
            (local.get $n)
            (i32.const 0))
          (then (return (i32.const 1))))
        (return 
          (i32.mul
            (local.get $n)
            (call $fac
              (i32.sub 
                (local.get $n)
                (i32.const 1)))
          )
        )
  )

  (func $main
    i32.const 5
    call $fac
    call $print_i32
  )
  (start $main)
)

