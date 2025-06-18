use ./files

describe 'Backing up a file' {
  describe 'if the file exists' {
    it 'should be restored in the end' {
      fail-test
    }
  }

  describe 'if the file did not exist' {
    it 'should be removed in the end' {
      fail-test
    }
  }
}