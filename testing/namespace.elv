use ./assertions
use ./describe-context

fn create { |&allow-crash=$false|
  var total-tests = 0
  var total-failed = 0

  var test-closures = []

  var root-describe-context = (describe-context:create [])
  var current-describe-context = $root-describe-context

  fn describe { |description block|
    tmp current-describe-context = ($current-describe-context[ensure-describe] $description)

    $block
  }

  fn it { |description block|
    set total-tests = (+ $total-tests 1)

    var test-outcome = ($current-describe-context[run-test] $description $block)

    if (not $test-outcome) {
      set total-failed = (+ $total-failed 1)

      if $allow-crash {
        fail $test-outcome
      }
    }
  }

  fn fail-test {
    fail 'TEST SET TO FAIL'
  }

  var namespace = (ns [
    &describe~=$describe~
    &it~=$it~
    &fail-test~=$fail-test~
    &should-be~=$assertions:should-be~
    &expect-crash~=$assertions:expect-crash~
    &expect-log~=$assertions:expect-log~
  ])

  fn get-results {
    put [
      &is-ok=(== $total-failed 0)
      &total-tests=$total-tests
      &total-failed=$total-failed
      &total-passed=(- $total-tests $total-failed)
    ]
  }

  fn display-tree {
    $root-describe-context[display-tree]
  }

  put [
    &namespace=$namespace
    &get-results=$get-results~
    &display-tree=$display-tree~
  ]
}