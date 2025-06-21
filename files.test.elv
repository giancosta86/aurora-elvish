use os
use path
use str
use ./files

describe 'Requesting a temp path' {
  describe 'when not passing a pattern' {
    it 'should use the default pattern' {
      var default-prefix = 'elvish-'

      var temp-path = (files:temp-path)

      path:base $temp-path |
        str:has-prefix (all) $default-prefix |
        should-be $true
    }
  }

  describe 'when passing a custom pattern' {
    var custom-prefix = 'alpha-'
    var custom-suffix = '-omega'

    var temp-path = (files:temp-path $custom-prefix'*'$custom-suffix)

    it 'should have the requested prefix' {
      path:base $temp-path |
        str:has-prefix (all) $custom-prefix |
        should-be $true
    }

    it 'should have the requested suffix' {
      path:base $temp-path |
        str:has-suffix (all) $custom-suffix |
        should-be $true
    }
  }
}

describe 'Preserving file state' {
  describe 'if the file existed' {
    it 'should restore the original file in the end' {
      var test-file = LICENSE

      files:preserve-state $test-file {
        rm $test-file
      }

      os:is-regular $test-file |
        should-be $true
    }
  }

  describe 'if the file did not exist' {
    it 'should remove the file in the end' {
      var test-file = SOME_INEXISTING_FILE

      files:preserve-state $test-file {
        echo Some text > $test-file
      }

      os:is-regular $test-file |
        should-be $false
    }
  }
}