use ./ns-identifiers

fn -parse-single-identifier { |code|
  var parsed-identifiers = [(ns-identifiers:parse $code)]

  if (> (count $parsed-identifiers) 1) {
    fail 'The test code snippet can only contain one namespaced identifier!'
  }

  put $parsed-identifiers[0]
}

describe 'Parsing namespaced identifiers' {
  describe 'when parsing each identifier individually' {
    describe 'parsing a basic identifier' {
      it 'should work' {
        -parse-single-identifier 'alpha:beta' |
          should-be [
            &namespace=alpha
            &identifier=beta
          ]
      }
    }

    describe 'parsing a callable identifier' {
      it 'should work' {
        -parse-single-identifier 'alpha:fi~' |
          should-be [
            &namespace=alpha
            &identifier=fi~
          ]
      }
    }

    describe 'parsing a variable identifier' {
      it 'should work' {
        -parse-single-identifier '$alpha:my-var' |
          should-be [
            &namespace=alpha
            &identifier=my-var
          ]
      }
    }

    describe 'parsing a multi-namespace identifier' {
      it 'should work' {
        -parse-single-identifier '$alpha:beta:gamma:delta' |
          should-be [
            &namespace=alpha
            &identifier=beta:gamma:delta
          ]
      }
    }
  }

  describe 'when parsing multiple namespaced identifiers in the same source code' {
    var parsed-identifiers = [(
      ns-identifiers:parse '
      This is some sample string that should be a source code file.

      Colons followed by spaces like this: should not be parsed. Nor :a, :b or similar ones.

      * Basic identifier -> alpha:beta

      * Callable identifier -> (alpha:fi~)

      * (Variable identifier -> $alpha:my-var)

      * [Multi-namespace identifier -> $alpha:beta:gamma:delta)
      '
    )]

    it 'should parse them all' {
      count $parsed-identifiers |
        should-be 4
    }

    it 'should parse a basic identifier' {
      has-value $parsed-identifiers [
        &namespace=alpha
        &identifier=beta
      ] |
        should-be $true
    }

    it 'should parse a callable identifier' {
      has-value $parsed-identifiers [
        &namespace=alpha
        &identifier=fi~
      ] |
        should-be $true
    }

    it 'should parse a variable identifier' {
      has-value $parsed-identifiers [
        &namespace=alpha
        &identifier=my-var
      ] |
        should-be $true
    }

    it 'should parse a multi-namespace identifier' {
      has-value $parsed-identifiers [
        &namespace=alpha
        &identifier=beta:gamma:delta
      ] |
        should-be $true
    }
  }
}