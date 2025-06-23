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

fn difference { |source @subtrahends|
  all $subtrahends |
    seq:reduce $source { |accumulator subtrahend|
      map:filter $accumulator { |key _|
        not (has-key $subtrahend $key)
      }
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

fn symmetric-difference { |left right|
  difference (union $left $right) (intersection $left $right)
}
