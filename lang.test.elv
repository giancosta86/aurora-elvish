use ./lang

describe 'Function detector' {
  describe 'when passing a non-function value' {
    it 'should put $false' {
      (expect (lang:is-function 98))[to-be] $false
    }
  }

  describe 'when passing a function' {
    it 'should put $true' {
      fn my-function { echo 'Hello' }

      (expect (lang:is-function $my-function~))[to-be] $true
    }
  }

  describe 'when passing a code block' {
    it 'should put $true' {
      var code = { echo 'Hello' }

      (expect (lang:is-function $code))[to-be] $true
    }
  }
}

describe 'Ternary selector' {
  describe 'when the condition is true' {
    it 'should return the left operand' {
      var output = (lang:ternary $true 92 95)

      (expect $output)[to-be] 92
    }
  }

  describe 'when the condition is right' {
    it 'should return the right operand' {
      var output = (lang:ternary $false 92 95)

      (expect $output)[to-be] 95
    }
  }

  describe 'when passing code blocks' {
    it 'should return the code block without executing it' {
      var block = (lang:ternary $true { fail 'Left' } { fail 'Right' })

      (expect (lang:is-function $block))[to-be] $true
    }
  }
}

describe 'Ensuring that a put is performed' {
  describe 'when a put is performed' {
    it 'should just do nothing' {
      var output = ({
        put Hello
      } | lang:ensure-put &default=World)

      (expect $output)[to-be] Hello
    }
  }

  describe 'when no put is performed by the block' {
    it 'should put the default value' {
      var output = ({ } | lang:ensure-put &default=World)

      (expect $output)[to-be] World
    }
  }
}