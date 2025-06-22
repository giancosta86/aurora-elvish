use os
use path
use ./directories

describe 'The mkcd command' {
  describe 'when the target directory does not exist' {
    var test-root = (os:temp-dir)
    defer { rm -rf $test-root }

    tmp pwd = $test-root

    var components = [alpha beta gamma delta]

    directories:mkcd $@components

    it 'should create that directory and its parents' {
      os:is-dir (path:join $test-root $@components) |
        should-be &strictly $true
    }

    it 'should move to that directory' {
      path:base $pwd |
        should-be $components[-1]
    }
  }

  describe 'when the target directory already exists' {
    it 'should just move to that directory' {
      var test-root = (os:temp-dir)
      defer { rm -rf $test-root }

      tmp pwd = $test-root

      var components = [ro sigma tau]

      os:mkdir-all (path:join $@components)

      directories:mkcd $@components

      path:base $pwd |
        should-be $components[-1]
    }
  }
}