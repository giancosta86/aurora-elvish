use ./string

describe 'Converting empty string to default' {
  describe 'when the string is empty' {
    describe 'when passing a default value' {
      it 'should put the default value' {
        string:empty-to-default &default=90 '' |
          should-equal 90
      }
    }

    describe 'when not passing a default value' {
      it 'should put $nil' {
        string:empty-to-default '' |
          should-be $nil
      }
    }
  }

  describe 'when the string is not empty' {
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
