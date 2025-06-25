use str
use ../../console
use ../../lang
use ../../map
use ../../seq
use ./cli/indentation

var -display-outcome-trees~

fn -print-indentation { |level|
  console:print (str:repeat ' ' (* $level 4))
}

fn -display-node { |node level|
  -print-indentation $level
  console:echo (styled $node[description] white bold)

  all $node[tests] |
    order &key={ |test| str:to-lower $test[description] } |
    each { |test|
      var is-ok = (eq $test[outcome] $ok)
      var color = (lang:ternary $is-ok green red)
      var emoji = (lang:ternary $is-ok ✅ ❌)

      -print-indentation (+ $level 1)
      console:echo (styled $test[description] $color bold) $emoji
    }

  -display-outcome-trees $node[sub-contexts] (+ $level 1)
}

set -display-outcome-trees~ = { |outcome-trees level|
  all $outcome-trees |
    order &key={ |context| str:to-lower $context[description] } |
    each { |outcome-tree|
      -display-node $outcome-tree $level
    }
}

fn display { |outcome-trees|
  console:echo

  console:section &emoji=📋 (styled 'Test outcomes' blue bold) {
    -display-outcome-trees $outcome-trees 0
  }
}