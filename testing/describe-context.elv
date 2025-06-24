use str
use ../command
use ../console
use ../lang
use ../map
use ../seq
use ./describe-context-map dcm

fn -create { |path|
  var description = $path[-1]
  var outcomes = [&]
  var sub-contexts = [&]

  fn format-path { |description|
    str:join ' -> ' [$@path $description]
  }

  fn get-outcome-tree {


    put [
      &description=$description

      &tests=(
        map:entries $outcomes |
        seq:each-spread { |test-description outcome|
          put [
            &description=$test-description
            &outcome=$outcome
          ]
        } |
        put [(all)]
      )

      &sub-contexts=(dcm:get-outcome-trees $sub-contexts)
    ]
  }

  put [
    &ensure-sub-context={ |description|
      var ensure-result = (
        dcm:ensure $sub-contexts $description { |description| -create [$@path $description] }
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

    &get-outcome-tree=$get-outcome-tree~
  ]
}

fn create-root { |description|
  -create [$description]
}