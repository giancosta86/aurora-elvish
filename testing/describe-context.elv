use str
use ../command
use ../console
use ../lang
use ../map
use ../seq

fn ensure-in-map { |map description factory|
  var existing-context = (map:get-value $map $description)

  if $existing-context {
    put [
      &context=$existing-context
      &updated-map=$map
    ]
  } else {
    var new-context = ($factory $description)

    var updated-map = (assoc $map $description $new-context)

    put [
      &context=$new-context
      &updated-map=$updated-map
    ]
  }
}

fn get-outcome-map { |context-map|
  map:entries $context-map |
    seq:each-spread { |description context|
      put [$description ($context[get-outcome-map])]
    } |
    make-map
}

fn -create { |path|
  var description = $path[-1]
  var outcomes = [&]
  var sub-contexts = [&]

  fn format-path { |description|
    str:join ' -> ' [$@path $description]
  }

  put [
    &ensure-sub-context={ |description|
      var ensure-result = (
        ensure-in-map $sub-contexts $description { |description| -create [$@path $description] }
      )

      set sub-contexts = $ensure-result[updated-map]
      put $ensure-result[context]
    }

    &run-test={ |description block|
      if (has-key $outcomes $description) {
        fail 'Duplicated test: '(format-path $description)
      }

      var outcome = ?(
        command:silence-until-error &description=(styled (format-path $description) red bold) {
          try {
            $block
          } catch e {
            console:pprint $e
            fail $e
          }
        }
      )

      set outcomes = (assoc $outcomes $description $outcome)

      put $outcome
    }

    &get-outcome-map={
      put [
        &outcomes=$outcomes
        &sub-contexts=(get-outcome-map $sub-contexts)
      ]
    }
  ]
}

fn create-root { |description|
  -create [$description]
}