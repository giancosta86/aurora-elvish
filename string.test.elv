use ./string

describe 'Converting empty string to default' {
  describe 'when the string is empty' {
    describe 'when passing a default value' {
      it 'should put the default value' {
        string:empty-to-default &default=90 '' |
          should-be 90
      }
    }

    describe 'when not passing a default value' {
      it 'should put $nil' {
        string:empty-to-default '' |
          should-be $nil
      }
    }
  }

  describe 'when the string contains only whitespaces' {
    var string-with-spaces = "     \t   "

    describe 'when trimming is enabled' {
      describe 'when a default value is passed' {
        it 'should put such default value' {
          var custom-default = 'Dodo'

          string:empty-to-default &trim &default=$custom-default $string-with-spaces |
            should-be $custom-default
        }
      }

      describe 'when no default value is passed' {
        it 'should put $nil' {
          string:empty-to-default &trim $string-with-spaces |
            should-be $nil
        }
      }
    }

    describe 'when trimming is disabled' {
      it 'should put the string as it is' {
        string:empty-to-default $string-with-spaces &trim=$false |
          should-be $string-with-spaces
      }
    }
  }

  describe 'when the string has actual characters' {
    describe 'when passing a default value' {
      it 'should put the string itself' {
        string:empty-to-default &default=90 Hello |
          should-be Hello
      }
    }

    describe 'when not passing a default value' {
      it 'should put the string itself' {
        string:empty-to-default Hello |
          should-be Hello
      }
    }
  }
}
