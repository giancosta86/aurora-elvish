use os

fn -print-expected-and-actual { |inputs|
  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]

  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]

  print (styled $expected-description': ' green bold)
  pprint $expected

  print (styled $actual-description': ' red bold)
  pprint $actual
}

fn should-equal { |expected|
  one | each { |actual|
    var expected-string = (to-string $expected)
    var actual-string = (to-string $actual)

    if (not-eq $expected-string $actual-string) {
      -print-expected-and-actual [
        &expected-description='Expected string'
        &expected=$expected-string
        &actual-description='Actual string'
        &actual=$actual-string
      ]

      fail 'Assertion failed'
    }
  }
}

fn should-be { |expected|
  one | each { |actual|
    if (not-eq $expected $actual) {
      -print-expected-and-actual [
        &expected-description='Expected'
        &expected=$expected
        &actual-description='Actual'
        &actual=$actual
      ]

      fail 'Assertion failed'
    }
  }
}

fn expect-crash { |block|
  try {
    $block
  } catch e {
    put $e
  } else {
    fail 'The given code block did not fail!'
  }
}