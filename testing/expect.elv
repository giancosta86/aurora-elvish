use ../lang
use ./format

fn -resolve-subject { |subject|
  if (lang:is-function $subject) {
    $subject
  } else {
    put $subject
  }
}

fn expect { |subject|
  var resolved-subject = (-resolve-subject $subject)

  put [
    &to-equal={ |expected|
      var expected-string = (to-string $expected)
      var actual-string = (to-string $resolved-subject)

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

    &to-exact-equal={ |expected|
      if (not-eq $expected $resolved-subject) {
        format:print-expected-and-actual [
          &expected-description='Expected'
          &expected=$expected
          &actual-description='Actual'
          &actual=$resolved-subject
        ]

        fail 'Expectation failed'
      }
    }
  ]
}