use os
use str
use ../command
use ./assertions
use ./format

fn create {
  var description-path = []
  var test-closures = []

  var passed = 0
  var failed = 0

  fn get-full-description { |description|
    var full-description-components = [$@description-path $description]
    str:join ' -> ' $full-description-components
  }

  fn describe { |description block|
    tmp description-path = [$@description-path $description]

    $block
  }

  fn it { |description block|
    var full-description = (get-full-description $description)

    try {
      command:silence-until-error &description=(styled $full-description red bold) {
        try {
          $block
        } catch e {
          format:print-exception $e
          fail $e
        }
      }
    } catch e {
      set failed = (+ $failed 1)
    } else {
      set passed = (+ $passed 1)
    }
  }

  fn fail-test {
    fail 'TEST SET TO FAIL'
  }

  ns [
    &describe~=$describe~
    &it~=$it~
    &fail-test~=$fail-test~
    &should-be~=$assertions:should-be~
    &should-equal~=$assertions:should-equal~
    &expect-crash~=$assertions:expect-crash~
    &get-passed~={ put $passed }
    &get-failed~={ put $failed }
  ]
}