use str
use ../../console
use ../../lang
use ../../map
use ../../seq

fn -print-indentation { |level|
  console:print (str:repeat ' ' (* $level 4))
}

fn -display-outcome { |description outcome describe-context-level|
  var is-ok = (eq $outcome $ok)
  var color = (lang:ternary $is-ok green red)
  var emoji = (lang:ternary $is-ok ✅ ❌)

  -print-indentation (+ $describe-context-level 1)
  console:echo (styled $description $color bold) $emoji
}

fn -display-outcome-map { |outcome-map level|
  keys  $outcome-map |
    order &key={ |description| str:to-lower $description } |
    each { |description|
      var context = $outcome-map[$description]

      -print-indentation $level
      console:echo $description

      var outcomes = $context[outcomes]

      keys $outcomes |
        order &key={ |description| str:to-lower $description } |
        each { |description|
          var outcome = $outcomes[$description]

          -display-outcome $description $outcome $level
        }

      -display-outcome-map $context[sub-contexts] (+ $level 1)
    }
}

fn display { |outcome-map|
  console:section &emoji=📋 (styled 'Test outcomes' blue bold) {
    -display-outcome-map $outcome-map 0
  }
}