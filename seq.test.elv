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
  describe 'passing the sequence as an argument' {
    describe 'when the sequence is empty' {
      it 'should not call the consumer' {
        seq:enumerate [] { |index value|
          fail 'This should not be run'
        }
      }
    }

    describe 'when the sequence is non-empty' {
      it 'should iterate' {
        var current-result = ''

        seq:enumerate [A B C] { |index value|
          set current-result = $current-result''$index':'$value'; '
        }

        (expect $current-result)[to-be] '0:A; 1:B; 2:C; '
      }
    }
  }

  describe 'passing the sequence via pipe' {
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
}