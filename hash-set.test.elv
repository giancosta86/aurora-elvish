use ./hash-set

describe 'Hash set' {
  describe 'empty creation' {
    it 'should work' {
      put (hash-set:empty) |
        should-be [&]
    }
  }

  describe 'creation from sequence' {
    describe 'when the sequence is empty' {
      it 'should work' {
        all [] |
          hash-set:from |
          keys (all) |
          count |
          should-be 0
      }
    }

    describe 'when the sequence has items' {
      it 'should work' {
        all [alpha beta gamma] |
          hash-set:from |
          keys (all) |
          count |
          should-be 3
      }
    }
  }

  describe 'creation from enumeration' {
    describe 'when passing a single item' {
      it 'should work' {
        hash-set:of alpha |
          keys (all) |
          count |
          should-be 1
      }
    }

    describe 'when passing multiple items' {
      it 'should work' {
        hash-set:of alpha beta gamma |
          keys (all) |
          count |
          should-be 3
      }
    }
  }

  describe 'contains' {
    describe 'when the item is in the set' {
      it 'should put $true' {
        hash-set:of alpha beta gamma |
          hash-set:contains (all) beta |
          should-be $true
      }
    }

    describe 'when the item is not in the set' {
      it 'should put $false' {
        hash-set:of alpha beta gamma |
          hash-set:contains (all) OMEGA |
          should-be $false
      }
    }
  }

  describe 'adding items' {
    describe 'when adding a single item' {
      it 'should work' {
        var result = (
          hash-set:of alpha beta gamma |
            hash-set:add (all) sigma
        )

        hash-set:contains $result alpha |
          should-be $true

        hash-set:contains $result beta |
          should-be $true

        hash-set:contains $result gamma |
          should-be $true

        hash-set:contains $result sigma |
          should-be $true
      }
    }

    describe 'when adding multiple items' {
      it 'should work' {
        var result = (
          hash-set:of alpha beta gamma |
            hash-set:add (all) sigma tau
        )

        hash-set:contains $result alpha |
          should-be $true

        hash-set:contains $result beta |
          should-be $true

        hash-set:contains $result gamma |
          should-be $true

        hash-set:contains $result sigma |
          should-be $true

        hash-set:contains $result tau |
          should-be $true
      }
    }
  }

  describe 'removing items' {
    describe 'when removing a single item' {
      it 'should work' {
        var result = (
          hash-set:of alpha beta gamma |
            hash-set:remove (all) beta
        )

        hash-set:contains $result alpha |
          should-be $true

        hash-set:contains $result beta |
          should-be $false

        hash-set:contains $result gamma |
          should-be $true
      }
    }

    describe 'when adding multiple items' {
      it 'should work' {
        var result = (
          hash-set:of alpha beta gamma |
            hash-set:remove (all) alpha gamma
        )

        hash-set:contains $result alpha |
          should-be $false

        hash-set:contains $result beta |
          should-be $true

        hash-set:contains $result gamma |
          should-be $false
      }
    }
  }
}