use str
use ../command
use ../console
use ../lang
use ../map
use ../seq

fn create { |path|
  var test-outcomes = [&]
  var sub-contexts = [&]

  fn format-path { |description|
    str:join ' -> ' [$@path $description]
  }

  fn get-indentation { |steps|
    str:repeat ' ' (* 2 $steps)
  }

  fn display-tree {
    var level = (count $path)

    if (> $level 0) {
      var indentation = (get-indentation (- $level 1))

      var description = $path[-1]

      console:echo (styled $indentation''$description white bold)
    }

    map:entries &ordered $test-outcomes |
      seq:each-spread { |description outcome|
        var is-test-ok = (eq $outcome $ok)

        var indentation = (get-indentation $level)
        var color = (lang:ternary $is-test-ok green red)
        var emoji = (lang:ternary $is-test-ok ✅ ❌)

        console:echo (styled $indentation''$description $color bold) $emoji
      }

    map:entries &ordered $sub-contexts |
      seq:each-spread { |_ sub-context|
        $sub-context[display-tree]
      }
  }

  put [
    &ensure-describe={ |description|
      if (not (has-key $sub-contexts $description)) {
        var new-context = (create [$@path $description])

        set sub-contexts = (assoc $sub-contexts $description $new-context)
      }

      put $sub-contexts[$description]
    }

    &run-test={ |description block|
      if (seq:is-empty $path) {
        fail 'Tests can only be run within describe {} blocks!'
      }

      if (has-key $test-outcomes $description) {
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

      set test-outcomes = (assoc $test-outcomes $description $outcome)

      put $outcome
    }

    &display-tree=$display-tree~
  ]
}
