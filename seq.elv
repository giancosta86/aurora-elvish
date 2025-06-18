fn is-empty { |container| == (count $container) 0 }

fn is-non-empty { |container| != (count $container) 0 }

fn enumerate { |@inputs|
  var input-count = (count $inputs)

  if (== $input-count 1) {
    var consumer = $inputs[0]
    var index = 0

    each { |item|
      $consumer $index $item
      set index = (+ $index 1)
    }
  } elif (== $input-count 2) {
    var sequence consumer = (all $inputs)

    range 0 (count $sequence) | each { |index|
      var item = $sequence[$index]
      $consumer $index $item
    }
  } else {
    fail 'Invalid arity! 1 or 2 arguments expected!'
  }
}