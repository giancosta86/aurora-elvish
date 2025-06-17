use ./console
use ./map

fn create { |is-enabled-retriever|
  put [
    &echo={ |@rest|
      if ($is-enabled-retriever) {
        console:echo $@rest
      }
    }

    &print={ |@rest|
      if ($is-enabled-retriever) {
        console:print $@rest
      }
    }

    &printf={ |&newline=$false template @values|
      if ($is-enabled-retriever) {
        console:printf &newline=$newline $template $@values
      }
    }

    &pprint={ |@values|
      if ($is-enabled-retriever) {
        console:pprint $@values
      }
    }

    &inspect={ |&emoji=🔎 description value|
      if ($is-enabled-retriever) {
        console:inspect &emoji=$emoji $description $value
      }
    }
  ]
}

fn based-on-env-var { |env-var-name|
  create {
    if (has-env $env-var-name) {
      ==s (get-env $env-var-name) true
    } else {
      put $false
    }
  }
}

fn controllable {
  var enabled = $false

  var tracer = (create { put $enabled })

  var controls = [
    &set-enabled={ |value| set enabled = $value }

    &enable={ set enabled = $true }

    &disable={ set enabled = $false }
  ]

  map:merge $tracer $controls
}