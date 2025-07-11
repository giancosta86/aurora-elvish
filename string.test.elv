use ./string

describe 'Converting empty string to default' {
  describe 'when the string is empty' {
    describe 'when passing a default value' {
      it 'should output the default value' {
        string:empty-to-default &default=90 '' |
          should-be 90
      }
    }

    describe 'when not passing a default value' {
      it 'should output $nil' {
        string:empty-to-default '' |
          should-be $nil
      }
    }
  }

  describe 'when the string contains only whitespaces' {
    var string-with-spaces = "     \t   "

    describe 'when trimming is enabled' {
      describe 'when a default value is passed' {
        it 'should output such default value' {
          var custom-default = 'Dodo'

          string:empty-to-default &trim &default=$custom-default $string-with-spaces |
            should-be $custom-default
        }
      }

      describe 'when no default value is passed' {
        it 'should output $nil' {
          string:empty-to-default &trim $string-with-spaces |
            should-be $nil
        }
      }
    }

    describe 'when trimming is disabled' {
      it 'should output the string as it is' {
        string:empty-to-default $string-with-spaces &trim=$false |
          should-be $string-with-spaces
      }
    }
  }

  describe 'when the string has actual characters' {
    describe 'when passing a default value' {
      it 'should output the string itself' {
        string:empty-to-default &default=90 Hello |
          should-be Hello
      }
    }

    describe 'when not passing a default value' {
      it 'should output the string itself' {
        string:empty-to-default Hello |
          should-be Hello
      }
    }
  }
}

describe 'Getting the minimal string' {
  describe 'for a string' {
    it 'should output the string itself' {
      string:get-minimal Dodo |
        should-be Dodo
    }
  }

  describe 'for a number' {
    it 'should output the number, without "num" prefix' {
      string:get-minimal (num 90) |
        should-be '90'
    }
  }

  describe 'for a boolean' {
    it 'should output the constant itself' {
      string:get-minimal $true |
        should-be '$true'
    }
  }

  describe 'for $nil' {
    it 'should return the constant itself' {
      string:get-minimal $nil |
        should-be '$nil'
    }
  }

  describe 'when converting a list' {
    it 'should work for a flat list' {
      string:get-minimal [A (num 92) $false $nil] |
        should-be '[A 92 ''$false'' ''$nil'']'
    }

    it 'should work for nested lists' {
      string:get-minimal [
        [
          (num 98)
          (num 92)
          A
          B
          $true
        ]
        C
        [
          [
            (num 95)
          ]
        ]
      ] |
        should-be '[''[98 92 A B ''''$true'''']'' C ''[''''[95]'''']'']'
    }
  }

  describe 'when converting a map' {
    it 'should work for a flat map' {
      string:get-minimal [
        &A=(num 90)
        &B=$true
        &(num 92)=K
      ] |
        should-be '[&92=K &A=90 &B=''$true'']'
    }

    it 'should work for nested maps' {
      string:get-minimal [
        &X=[(num 92) C]
        &Y=[&S=(num 32) &T=[90 95]]
      ] |
        should-be '[&X=''[92 C]'' &Y=''[&S=32 &T=''''[90 95]'''']'']'
    }
  }
}