use ./lang

describe 'Function detector' {
  describe 'when passing a non-function value' {
    it 'should put $false' {
      lang:is-function 98 |
        should-be $false
    }
  }

  describe 'when passing a function' {
    it 'should put $true' {
      fn my-function { echo 'Hello' }

      lang:is-function $my-function~ |
        should-be $true
    }
  }

  describe 'when passing a code block' {
    it 'should put $true' {
      var code = { echo 'Hello' }

      lang:is-function $code |
        should-be $true
    }
  }
}

describe 'Ternary selector' {
  describe 'when the condition is true' {
    it 'should return the left operand' {
      lang:ternary $true 92 95 |
        should-be 92
    }
  }

  describe 'when the condition is right' {
    it 'should return the right operand' {
      lang:ternary $false 92 95 |
        should-be 95
    }
  }

  describe 'when passing code blocks' {
    it 'should return the code block without executing it' {
      var block = (lang:ternary $true { fail 'Left' } { fail 'Right' })

      lang:is-function $block |
        should-be $true
    }
  }
}

describe 'Ensuring that a put is performed' {
  describe 'when a put is performed' {
    it 'should just do nothing' {
      { put Hello } | lang:ensure-put &default=World |
        should-be Hello
    }
  }

  describe 'when no put is performed by the block' {
    it 'should put the default value' {
      { } | lang:ensure-put &default=World |
        should-be World
    }
  }
}