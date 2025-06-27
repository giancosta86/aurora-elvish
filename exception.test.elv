use ./exception

describe 'Testing for the return exception' {
  describe 'when the return keyword is actually used' {
    it 'should output $true' {
      try {
        return
      } catch e {
        exception:is-return $e |
          should-be $true
      }
    }
  }

  describe 'when another exception is thrown' {
    it 'should output $false' {
      try {
        fail 'KABOOM!'
      } catch e {
        exception:is-return $e |
          should-be $false
      }
    }
  }
}