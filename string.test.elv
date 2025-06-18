use ./string

describe 'Converting empty string to default' {
  describe 'when the string is empty' {
    describe 'when passing a default value' {
      it 'should put the default value' {
        var output = (string:empty-to-default &default=90 '')

        (expect $output)[to-equal] 90
      }
    }

    describe 'when not passing a default value' {
      it 'should put $nil' {
        var output = (string:empty-to-default '')

        (expect $output)[to-be] $nil
      }
    }
  }

  describe 'when the string is not empty' {
    describe 'when passing a default value' {
      it 'should put the string itself' {
        var output = (string:empty-to-default &default=90 Hello)

        (expect $output)[to-be] Hello
      }
    }

    describe 'when not passing a default value' {
      it 'should put the string itself' {
        var output = (string:empty-to-default Hello)

        (expect $output)[to-be] Hello
      }
    }
  }
}
