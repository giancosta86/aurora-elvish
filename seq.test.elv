use ./seq

describe 'Is-empty test' {
  describe 'when the source is a list' {
    describe 'when the list is empty' {
      it 'should output $true' {
        seq:is-empty [] |
          should-be $true
      }
    }

    describe 'when the list is not empty' {
      it 'should output $false' {
        seq:is-empty [A B C] |
          should-be $false
      }
    }
  }

  describe 'when the source is a string' {
    describe 'when the string is empty' {
      it 'should output $true' {
        seq:is-empty '' |
          should-be $true
      }
    }

    describe 'when the string is not empty' {
      it 'should output $false' {
        seq:is-empty 'Hello' |
          should-be $false
      }
    }
  }
}

describe 'Is-non-empty test' {
  describe 'when the source is a list' {
    describe 'when the list is empty' {
      it 'should output $false' {
        seq:is-non-empty [] |
          should-be $false
      }
    }

    describe 'when the list is not empty' {
      it 'should output $true' {
        seq:is-non-empty [A B C] |
          should-be $true
      }
    }
  }

  describe 'when the source is a string' {
    describe 'when the string is empty' {
      it 'should output $false' {
        seq:is-non-empty '' |
          should-be $false
      }
    }

    describe 'when the string is not empty' {
      it 'should output $true' {
        seq:is-non-empty 'World' |
          should-be $true
      }
    }
  }
}

describe 'Enumerating' {
  describe 'when the sequence is empty' {
    it 'should not call the consumer' {
      all [] | seq:enumerate { |index value|
        fail 'This should not be run'
      }
    }
  }

  describe 'when the sequence is non-empty' {
    it 'should iterate' {
      var current-result = ''

      all [A B C] | seq:enumerate { |index value|
        set current-result = $current-result''$index':'$value'; '
      }

      put $current-result |
        should-be '0:A; 1:B; 2:C; '
    }
  }

  describe 'when passing the first index' {
    it 'should start from the given index' {
      put [(all [A B C] | seq:enumerate &start-index=35 { |index value|
        put [$index $value]
      })] |
        should-be [
          [(num 35) A] #TODO! Inspect this, by removing the (num) call
          [(num 36) B]
          [(num 37) C]
        ]
    }
  }
}

describe 'Iterating and spreading as consumer arguments' {
  describe 'when the sequence is empty' {
    it 'should not call the consumer' {
      all [] |
        seq:each-spread { |a b| fail 'THIS SHOULD NOT RUN' }
    }
  }

  describe 'when there are items' {
    it 'should call the consumer for every sequence of items' {
      var mapped-items = [(
        all [[a b 90] [x y 92]] |
          seq:each-spread { |left right result| put $left'+'$right'='$result }
      )]

      put $mapped-items |
        should-be [a+b=90 x+y=92]
    }
  }
}

describe 'Reduction' {
  describe 'when the sequence is empty' {
    it 'should return the initial value' {
      all [] | seq:reduce 0 $'+~' |
        should-be 0
    }
  }

  describe 'when the sequence has one item' {
    it 'should apply the operator' {
      all [92] | seq:reduce 0 $'+~' |
        should-be 92
    }
  }

  describe 'when the sequence has two items' {
    it 'should apply the operator' {
      all [82 13] | seq:reduce 0 $'+~' |
        should-be 95
    }
  }

  describe 'when the sequence has three items' {
    it 'should apply the operator' {
      all [65 25 8] | seq:reduce 0 $'+~' |
        should-be 98
    }
  }

  it 'should support break' {
    all [65 25 8] | seq:reduce 0 { |left right|
      if (==s $right 8) {
        break
      }

      + $left $right
    } |
      should-be 90
  }
}

describe 'Getting a value at a given index' {
  describe 'when the index exists' {
    it 'should output the related value' {
      seq:get-at [A B C] 2 |
        should-be C
    }
  }

  describe 'when the index does not exist' {
    describe 'when a default value is passed' {
      it 'should output such default value' {
        seq:get-at &default=Dodo [A B C] 90 |
          should-be Dodo
      }
    }

    describe 'when no default value is passed' {
      it 'should output $nil' {
        seq:get-at [A B C] 90 |
          should-be $nil
      }
    }
  }
}

describe 'Getting the shared prefix of two sequences' {
  describe 'when the sequences are both empty' {
    it 'should output an empty list' {
      seq:get-prefix [] [] |
        should-be []
    }
  }

  describe 'when the sequences are equal' {
    it 'should output such sequence' {
      seq:get-prefix [A B C] [A B C] |
        should-be [A B C]
    }
  }

  describe 'when one is the prefix of the other' {
    describe 'when the left operand is shorter' {
      it 'should output such operand' {
        seq:get-prefix [A B C] [A B C D E F] |
          should-be [A B C]
      }
    }

    describe 'when the right operand is shorter' {
      it 'should output such operand' {
        seq:get-prefix [A B C D E F] [A B C] |
          should-be [A B C]
      }
    }
  }

  describe 'when the two sequences only partially overlap' {
    it 'should output the shared prefix' {
      seq:get-prefix [A B C D M N O S T] [A B C S T] |
        should-be [A B C]
    }
  }
}

describe 'Turning an empty sequence to default' {
  describe 'when not passing a default value' {
    describe 'for strings' {
      describe 'when empty' {
        it 'should output $nil' {
          seq:empty-to-default '' |
            should-be $nil
        }
      }

      describe 'when non-empty' {
        it 'should output the collection itself' {
          seq:empty-to-default 'Dodo' |
            should-be 'Dodo'
        }
      }
    }

    describe 'for lists' {
      describe 'when empty' {
        it 'should output $nil' {
          seq:empty-to-default [] |
            should-be $nil
        }
      }

      describe 'when non-empty' {
        it 'should output the collection itself' {
          seq:empty-to-default [A B C] |
            should-be [A B C]
        }
      }
    }

    describe 'for maps' {
      describe 'when empty' {
        it 'should output $nil' {
          seq:empty-to-default [&] |
            should-be $nil
        }
      }

      describe 'when non-empty' {
        it 'should output the collection itself' {
          seq:empty-to-default [&A=90 &B=92] |
            should-be [&A=90 &B=92]
        }
      }
    }
  }

  describe 'when passing a default value' {
    describe 'when the source is empty' {
      it 'should return such value' {
        var test-default = my-default

        seq:empty-to-default &default=$test-default '' |
          should-be $test-default

        seq:empty-to-default &default=$test-default [] |
          should-be $test-default

        seq:empty-to-default &default=$test-default [&] |
          should-be $test-default
      }
    }
  }
}