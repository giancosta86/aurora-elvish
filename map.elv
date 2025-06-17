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

fn each-entry { |source consumer|
  entries $source | each { |entry|
    var key = $entry[0]
    var value = $entry[1]

    $consumer $key $value
  }
}

fn merge { |@sources|
  var result = [&]

  for source $sources {
    each-entry $source { |key value|
      set result = (assoc $result $key $value)
    }
  }

  put $result
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