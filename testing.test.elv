use str

describe 'Arithmetic' {
  describe 'addition' {
    it 'should work' {
      echo Testing addition...

      + 90 2 |
        should-equal 92
    }
  }

  describe 'division' {
    it 'should work' {
      / 90 10 |
        should-equal 9
    }

    describe 'when dividing by zero' {
      it 'should fail with no subsequent check' {
        expect-crash {
          / 98 0
        }
      }

      it 'should fail with subsequent check' {
        expect-crash {
          / 98 0
        } |
        each { |e|
          str:contains (to-string $e[reason]) divisor
        } |
        should-be $true
      }
    }
  }
}