fn is-empty { |container| == (count $container) 0 }

fn is-non-empty { |container| != (count $container) 0 }

fn enumerate { |consumer|
  var index = 0

  each { |item|
    $consumer $index $item
    set index = (+ $index 1)
  }
}

fn each-spread { |consumer|
  each { |items|
    call $consumer $items [&]
  }
}

fn reduce { |initial-value operator|
  var result = $initial-value

  each { |item|
    set result = ($operator $result $item)
  }

  put $result
}
