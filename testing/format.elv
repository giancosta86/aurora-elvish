fn print-expected-and-actual { |inputs|
  var expected-description = $inputs[expected-description]
  var expected = $inputs[expected]

  var actual-description = $inputs[actual-description]
  var actual = $inputs[actual]

  print (styled $expected-description': ' green bold)
  pprint $expected

  print (styled $actual-description': ' red bold)
  pprint $actual
}

fn print-exception { |e|
  pprint $e
}