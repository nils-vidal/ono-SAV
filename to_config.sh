#!/bin/bash
awk '
  /^model[[:space:]]*\{/ { in_model = 1; n = 0; next }
  in_model && /^\}/ {
    side = int(sqrt(n))
    while (side * side < n) side++
    cols = side
    rows = side
    print rows "," cols
    for (i = 0; i < n; i += cols) {
      row = ""
      for (j = 0; j < cols && i + j < n; j++) row = row vals[i + j]
      print row
    }
    in_model = 0
    n = 0
    next
  }
  in_model && $1 == "symbol" {
    name = $2
    sub(/^symbol_/, "", name)
    vals[name + 0] = $4
    if (name + 0 + 1 > n) n = name + 0 + 1
  }
'