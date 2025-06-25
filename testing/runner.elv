use ../console
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

fn -run-file { |&allow-crash=$false path test-namespace|
  var source-string = (slurp < $path)

  eval &ns=$test-namespace $source-string
}

fn run { |&file-selector=$-default-file-selector &reporters=[$cli:display~] &allow-crash=$false|
  var namespace-controller = (namespace:create &allow-crash=$allow-crash)

  -get-test-files $file-selector |
    each { |test-file-path|
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

fn test { |&file-selector=$-default-file-selector &reporters=[$cli:display~] &allow-crash=$false &clear=$true &output-failures=$false|
  if $clear {
    clear
  }

  var run-output = (run &file-selector=$file-selector &reporters=$reporters &allow-crash=$allow-crash)

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