use ./seq

fn get-value { |&default=$nil source key|
  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}

fn entries { |source|
  keys $source | each { |key|
    put [$key $source[$key]]
  }
}

fn merge { |@sources|
  all $sources |
    each $entries~ |
    seq:reduce [&] { |accumulator entry|
      var key value = (all $entry)
      assoc $accumulator $key $value
    }
}

fn drill-down { |&default=$nil source @properties|
  var current-source = $source

  for property $properties {
    var value = (get-value $current-source $property)

    if $value {
      set current-source = $value
    } else {
      put $default
      return
    }
  }

  put $current-source
}