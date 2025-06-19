use os
use ./files

describe 'Presderving file state' {
  describe 'if the file existed' {
    it 'should restore the original file in the end' {
      var test-file = LICENSE

      files:preserve-state $test-file {
        rm $test-file
      }

      (expect (os:is-regular $test-file))[to-be] $true
    }
  }

  describe 'if the file did not exist' {
    it 'should remove the file in the end' {
      var test-file = SOME_INEXISTING_FILE

      files:preserve-state $test-file {
        echo Some text > $test-file
      }

      (expect (os:is-regular $test-file))[to-be] $false
    }
  }
}