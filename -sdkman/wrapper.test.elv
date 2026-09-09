use path
use ./paths
use ./test-shared
use ./wrapper

>> 'SDKMAN' {
  >> 'wrapper' {
    >> 'requesting the version' {
      capture {
        wrapper:sdk version
      } |
        should-contain SDKMAN
    }
  }
}