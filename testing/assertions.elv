use os
use str
use ../command
use ../lang

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

      fail 'should-equal assertion failed'
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

      fail 'should-be assertion failed'
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

fn expect-log { |&partial=$false expected block|
  var capture-result = (command:capture-to-log $block)

  defer $capture-result[clean]

  var log = ($capture-result[get-log])

  if $partial {
    if (not (str:contains $log $expected)) {
      -print-expected-and-actual [
        &expected-description='Expected partial log'
        &expected=$expected
        &actual-description='Actual log'
        &actual=$log
      ]

      fail 'should-be (&partial) assertion failed'
    }
  } else {
    if (not-eq $log $expected) {
      -print-expected-and-actual [
        &expected-description='Expected log'
        &expected=$expected
        &actual-description='Actual log'
        &actual=$log
      ]

      fail 'should-be assertion failed'
    }
  }
}
