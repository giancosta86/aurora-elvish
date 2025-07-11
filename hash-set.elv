use ./map
use ./seq

fn empty {
  put [&]
}

fn from {
  each { |value|
    put [$value 1]
  } |
    make-map
}

fn of { |first @additional|
  all [$first $@additional] |
    from
}

fn is-empty { |hash-set|
  == 0 (keys $hash-set |
    take 1 |
    count)
}

fn is-non-empty { |hash-set|
  != 0 (keys $hash-set |
    take 1 |
    count)
}

fn to-list {
  put [(keys (one))]
}

fn contains { |hash-set item|
  has-key $hash-set $item
}

fn add { |hash-set first-item @additional-items|
  all [$first-item $@additional-items] |
    seq:reduce $hash-set { |accumulator item|
      assoc $accumulator $item $true
    }
}

fn remove { |hash-set first-item @additional-items|
  all [$first-item $@additional-items] |
    seq:reduce $hash-set { |accumulator item|
      dissoc $accumulator $item
    }
}

fn union { |source @operands|
  all $operands |
    seq:reduce $source { |accumulator operand|
      map:merge $accumulator $operand
    }
}

fn intersection { |source @operands|
  all $operands |
    seq:reduce $source { |accumulator operand|
      map:filter $accumulator { |key _|
        has-key $operand $key
      }
    }
}

fn difference { |source @subtrahends|
  all $subtrahends |
    seq:reduce $source { |accumulator subtrahend|
      map:filter $accumulator { |key _|
        not (has-key $subtrahend $key)
      }
    }
}

fn symmetric-difference { |left right|
  difference (union $left $right) (intersection $left $right)
}
