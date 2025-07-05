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
            &line-number=1
            &namespace=alpha
            &identifier=beta
          ]
      }
    }

    describe 'parsing a callable identifier' {
      it 'should work' {
        -parse-single-identifier 'alpha:fi~' |
          should-be [
            &line-number=1
            &namespace=alpha
            &identifier=fi~
          ]
      }
    }

    describe 'parsing a variable identifier' {
      it 'should work' {
        -parse-single-identifier '$alpha:my-var' |
          should-be [
            &line-number=1
            &namespace=alpha
            &identifier=my-var
          ]
      }
    }

    describe 'parsing a multi-namespace identifier' {
      it 'should work' {
        -parse-single-identifier '$alpha:beta:gamma:delta' |
          should-be [
            &line-number=1
            &namespace=alpha
            &identifier=beta:gamma:delta
          ]
      }
    }

    describe 'parsing a functional identifier between brackets' {
      it 'should work' {
        -parse-single-identifier '&reporters=[$cli:display~]' |
          should-be [
            &line-number=1
            &namespace=cli
            &identifier=display~
          ]
      }
    }

    describe 'parsing a redirection merged with a scoped variable' {
      it 'should work' {
        -parse-single-identifier 'echo Test 2>$os:dev-null' |
          should-be [
            &line-number=1
            &namespace=os
            &identifier=dev-null
          ]
      }
    }

    describe 'parsing a string with escaped \n' {
      it 'should find no identifier' {
        ns-identifiers:parse 'Description:\nTest' |
          count |
          should-be 0
      }
    }

    describe 'parsing a colon between two variables' {
      it 'should find no identifier' {
        ns-identifiers:parse "$alpha':'$beta" |
          count |
          should-be 0
      }
    }

    describe 'parsing a colon followed by a space' {
      it 'should find no identifier' {
        ns-identifiers:parse 'Name: ' |
          count |
          should-be 0
      }
    }
  }

  describe 'when parsing multiple namespaced identifiers in the same source code' {
    var parsed-identifiers = [(
      ns-identifiers:parse 'This is some sample string that should be a source code file.

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
      put $parsed-identifiers[0] |
        should-be [
          &line-number=5
          &namespace=alpha
          &identifier=beta
        ]
    }

    it 'should parse a callable identifier' {
      put $parsed-identifiers[1] |
        should-be [
          &line-number=7
          &namespace=alpha
          &identifier=fi~
        ]
    }

    it 'should parse a variable identifier' {
      put $parsed-identifiers[2] |
        should-be [
          &line-number=9
          &namespace=alpha
          &identifier=my-var
        ]
    }

    it 'should parse a multi-namespace identifier' {
      put $parsed-identifiers[3] |
        should-be [
          &line-number=11
          &namespace=alpha
          &identifier=beta:gamma:delta
        ]
    }
  }
}