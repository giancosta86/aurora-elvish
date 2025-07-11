use ./exception

describe 'Testing for the return exception' {
  describe 'when the return keyword is actually used' {
    it 'should output $true' {
      expect-crash {
        return
      } |
        exception:is-return (all) |
        should-be $true
    }
  }

  describe 'when another exception is thrown' {
    it 'should output $false' {
      expect-crash {
        fail 'KABOOM!'
      } |
        exception:is-return (all) |
        should-be $false
    }
  }
}

describe 'Testing for failure' {
  describe 'when the exception is not a failure' {
    it 'should output $false' {
      expect-crash {
        return
      } |
        exception:is-fail (all) |
        should-be $false
    }
  }

  describe 'when the exception is actually a failure' {
    describe 'when no content is specified' {
      it 'should output $true' {
        expect-crash {
          fail KABOOM
        } |
          exception:is-fail (all) |
          should-be $true
      }
    }

    describe 'when no partial match is requested' {
      describe 'when the actual content is equal to the expected content' {
        it 'should output $true' {
          expect-crash {
            fail KABOOM
          } |
            exception:is-fail (all) &with-content=KABOOM &partial=$false |
              should-be $true
        }
      }

      describe 'when the actual content contains the expected content' {
        it 'should output $false' {
          expect-crash {
            fail KABOOM
          } |
            exception:is-fail (all) &with-content=BOO &partial=$false |
              should-be $false
        }
      }

      describe 'when the actual content does not contain the expected content' {
        it 'should output $false' {
          expect-crash {
            fail KABOOM
          } |
            exception:is-fail (all) &with-content=DODO &partial=$false |
              should-be $false
        }
      }
    }

    describe 'when content is specified' {
      describe 'when a partial match is requested' {
        describe 'when the actual content is equal to the expected content' {
          it 'should output $true' {
            expect-crash {
            fail KABOOM
          } |
            exception:is-fail (all) &with-content=KABOOM &partial=$true |
              should-be $true
          }
        }

        describe 'when the actual content contains the expected content' {
          it 'should output $true' {
            expect-crash {
            fail KABOOM
          } |
            exception:is-fail (all) &with-content=BOO &partial=$true |
              should-be $true
          }
        }

        describe 'when the actual content does not contain the expected content' {
          it 'should output $false' {
            expect-crash {
            fail KABOOM
          } |
            exception:is-fail (all) &with-content=DODO &partial=$true |
              should-be $false
          }
        }
      }
    }
  }
}