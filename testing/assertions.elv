use os
use ./format

fn should-equal { |expected|
  one | each { |actual|
    var expected-string = (to-string $expected)
    var actual-string = (to-string $actual)

    if (not-eq $expected-string $actual-string) {
      format:print-expected-and-actual [
        &expected-description='Expected string'
        &expected=$expected-string
        &actual-description='Actual string'
        &actual=$actual-string
      ]

      fail 'Expectation failed'
    }
  }
}

fn should-be { |expected|
  one | each { |actual|
    if (not-eq $expected $actual) {
      format:print-expected-and-actual [
        &expected-description='Expected'
        &expected=$expected
        &actual-description='Actual'
        &actual=$actual
      ]

      fail 'Expectation failed'
    }
  }
}

fn expect-crash { |block|
  try {
    $block > $os:dev-null 2>&1
  } catch e {
    put $e
  } else {
    fail 'The code block did not fail!'
  }
}