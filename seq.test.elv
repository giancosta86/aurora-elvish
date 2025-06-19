use ./seq

describe 'Is-empty test' {
  describe 'when the source is a list' {
    describe 'when the list is empty' {
      it 'should put $true' {
        (expect (seq:is-empty []))[to-be] $true
      }
    }

    describe 'when the list is not empty' {
      it 'should put $false' {
        (expect (seq:is-empty [A B C]))[to-be] $false
      }
    }
  }

  describe 'when the source is a string' {
    describe 'when the string is empty' {
      it 'should put $true' {
        (expect (seq:is-empty ''))[to-be] $true
      }
    }

    describe 'when the string is not empty' {
      it 'should put $false' {
        (expect (seq:is-empty 'Hello'))[to-be] $false
      }
    }
  }
}

describe 'Is-non-empty test' {
  describe 'when the source is a list' {
    describe 'when the list is empty' {
      it 'should put $false' {
        (expect (seq:is-non-empty []))[to-be] $false
      }
    }

    describe 'when the list is not empty' {
      it 'should put $true' {
        (expect (seq:is-non-empty [A B C]))[to-be] $true
      }
    }
  }

  describe 'when the source is a string' {
    describe 'when the string is empty' {
      it 'should put $false' {
        (expect (seq:is-non-empty ''))[to-be] $false
      }
    }

    describe 'when the string is not empty' {
      it 'should put $true' {
        (expect (seq:is-non-empty 'World'))[to-be] $true
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

      (expect $current-result)[to-be] '0:A; 1:B; 2:C; '
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

      (expect $mapped-items)[to-equal] [a+b=90 x+y=92]
    }
  }
}

describe 'Reduction' {
  describe 'when the sequence is empty' {
    it 'should return the initial value' {
      var result = (all [] | seq:reduce 0 $'+~')

      (expect $result)[to-equal] 0
    }
  }

  describe 'when the sequence has one item' {
    it 'should apply the operator' {
      var result = (all [92] | seq:reduce 0 $'+~')

      (expect $result)[to-equal] 92
    }
  }

  describe 'when the sequence has two items' {
    it 'should apply the operator' {
      var result = (all [82 13] | seq:reduce 0 $'+~')

      (expect $result)[to-equal] 95
    }
  }

  describe 'when the sequence has three items' {
    it 'should apply the operator' {
      var result = (all [65 25 8] | seq:reduce 0 $'+~')

      (expect $result)[to-equal] 98
    }
  }

  it 'should support break' {
    var result = (all [65 25 8] | seq:reduce 0 { |left right|
      if (==s $right 8) {
        break
      }

      + $left $right
    })

    (expect $result)[to-equal] 90
  }
}