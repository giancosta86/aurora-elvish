use path
use ../console
use ../fs
use ../seq
use ./namespace
use ./reporting/cli

var -default-includes = '**[type:regular][nomatch-ok].test.elv'

fn has-tests { |&includes=$-default-includes &excludes=$nil|
  fs:wildcard $includes &excludes=$excludes |
    take 1 |
    count |
    != (all) 0
}

fn -run-file { |&fail-fast=$false source-path test-namespace|
  var source-string = (slurp < $source-path)

  tmp pwd = (path:dir $source-path)

  eval &ns=$test-namespace $source-string
}

fn -run { |
  &includes=$-default-includes
  &excludes=$nil
  &reporters=[$cli:display~]
  &fail-fast=$false
|
  var namespace-controller = (namespace:create &fail-fast=$fail-fast)

  fs:wildcard $includes &excludes=$excludes |
    each { |wildcard-test-file-path|
      var test-file-path = (path:abs $wildcard-test-file-path)

      $namespace-controller[set-current-source-path] $test-file-path

      -run-file &fail-fast=$fail-fast $test-file-path $namespace-controller[namespace]
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
  &includes=$-default-includes
  &excludes=$nil
  &reporters=[$cli:display~]
  &fail-fast=$false
  &output-failures=$false
|
  var run-output = (-run &includes=$includes &excludes=$excludes &reporters=$reporters &fail-fast=$fail-fast | only-values)

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