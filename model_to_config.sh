#!/bin/bash

rows="$1"
cols="$2"

awk -v rows="$rows" -v cols="$cols" '
  function best_rect(n,   c) {
    c = int(sqrt(n))
    while (c > 1 && n % c != 0) c--
    return c
  }

  /^model[[:space:]]*\{/ {
    in_model = 1
    n = 0
    delete vals
    next
  }

  in_model && /^\}/ {
    r = rows
    c = cols

    if (r == "" || c == "") {
      c = best_rect(n)
      r = int(n / c)
    }

    if (r * c < n) {
      print "Error: provided dimensions too small" > "/dev/stderr"
      exit 1
    }

    print r "," c

    for (i = 0; i < r; i++) {
      row = ""
      for (j = 0; j < c; j++) {
        idx = i * c + j
        row = row ((idx in vals) ? vals[idx] : " ")
      }
      print row
    }

    in_model = 0
    next
  }

  in_model && $1 == "symbol" {
    name = $2
    sub(/^symbol_/, "", name)
    idx = name + 0
    vals[idx] = $4
    if (idx + 1 > n) n = idx + 1
  }
'
