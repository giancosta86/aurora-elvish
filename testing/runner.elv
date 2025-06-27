use path
use re
use str
use ../console
use ../fs
use ../lang
use ../seq
use ./namespace
use ./reporting/cli

var -default-file-selector = '**[type:regular][nomatch-ok].test.elv'

fn -get-test-files { |file-selector|
  eval 'put '$file-selector
}

fn has-tests { |&file-selector=$-default-file-selector|
  var first-file = (
    -get-test-files $file-selector |
      take 1 |
      lang:ensure-put
  )

  not-eq $first-file $nil
}

fn -get-use-directive { |module alias|
  if (seq:is-empty $alias) {
    put 'use '$module
  } else {
    put 'use '$module' as '$alias
  }
}


fn -redirect-uses { |source-path|
  var text-content = (all)

  var use-regex = '(?m)^\s*use\s+(\S+)(?:\s+as(\s+)\S+)?\s*(?:#.*)?$'

  re:replace $use-regex { |matching-line|
    var match = (re:find $use-regex $matching-line)
    var groups = $match[groups]

    var requested-module = $groups[1][text]
    var alias = $groups[2][text]

    var is-relative = (str:has-prefix $requested-module '.')

    if $is-relative {
      var runner-directory = $pwd

      var source-directory = (path:dir $source-path)
      var requested-path = (path:join $source-directory $requested-module)

      console:inspect &emoji=📄 'SOURCE PATH' $source-path
      console:inspect &emoji=📁 'SOURCE DIRECTORY' $source-directory

      console:inspect &emoji=💬 'REQUESTED PATH' $requested-path

      var updated-module = './'(fs:relativize $runner-directory $requested-path)

      -get-use-directive $updated-module $alias
    } else {
      -get-use-directive $requested-module $alias
    }
  } $text-content
}

fn -run-file { |&allow-crash=$false source-path test-namespace|
  var source-string = (
    slurp < $source-path |
      -redirect-uses $source-path
  )

  eval &ns=$test-namespace $source-string
}

fn run { |
  &file-selector=$-default-file-selector
  &reporters=[$cli:display~]
  &allow-crash=$false
|
  var namespace-controller = (namespace:create &allow-crash=$allow-crash)

  -get-test-files $file-selector |
    each { |wildcard-test-file-path|
      var test-file-path = (path:abs $wildcard-test-file-path)

      $namespace-controller[set-current-source-path] $test-file-path

      -run-file &allow-crash=$allow-crash $test-file-path $namespace-controller[namespace]
    }

  if (seq:is-non-empty $reporters) {
    var outcome-map = ($namespace-controller[get-outcome-map])

    all $reporters | each { |reporter|
      console:echo
      $reporter $outcome-map
    }
  }

  console:echo

  put [
    &get-stats=$namespace-controller[get-stats]
    &get-outcome-map=$namespace-controller[get-outcome-map]
  ]
}

fn test { |
  &file-selector=$-default-file-selector
  &reporters=[$cli:display~]
  &allow-crash=$false
  &clear=$true
  &output-failures=$false
|
  if $clear {
    clear
  }

  var run-output = (run &file-selector=$file-selector &reporters=$reporters &allow-crash=$allow-crash | only-values)

  var stats = ($run-output[get-stats])

  if $stats[is-ok] {
    var message = 'All the '$stats[total-tests]' tests passed.'
    console:echo (styled $message green bold)
  } else {
    var message = 'Failed tests: '$stats[total-failed]' out of '$stats[total-tests]'.'
    console:echo (styled $message red bold)
  }

  if $output-failures {
    put $stats[total-failed]
  }
}