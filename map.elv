use builtin
use ./seq

fn get-value { |&default=$nil source key|
  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}

fn keys { |&ordered=$false map|
  if $ordered {
    builtin:keys $map |
      order
  } else {
    builtin:keys $map
  }
}

fn entries { |&ordered=$false source|
  keys &ordered=$ordered $source | each { |key|
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

  all $properties | each { |property|
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

fn filter { |source key-value-predicate|
  entries $source |
    seq:each-spread { |key value|
      if ($key-value-predicate $key $value) {
        put [$key $value]
      }
    } |
    make-map
}