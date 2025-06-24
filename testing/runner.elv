use ../console
use ../lang
use ./namespace

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

fn run-file { |&allow-crash=$false path test-namespace|
  var source-string = (slurp < $path)

  eval &ns=$test-namespace $source-string
}

fn run { |&allow-crash=$false &file-selector=$-default-file-selector|
  var namespace-controller = (namespace:create &allow-crash=$allow-crash)
  var test-namespace = $namespace-controller[namespace]

  -get-test-files $file-selector |
    each { |test-file-path|
      run-file &allow-crash=$allow-crash $test-file-path $test-namespace
    }

  put $namespace-controller
}

fn test { |&file-selector=$-default-file-selector &display-tree=$false &allow-crash=$false|
  clear

  var namespace-controller = (run &allow-crash=$allow-crash &file-selector=$file-selector)
  var results = ($namespace-controller[get-results])

  if $display-tree {
    console:echo

    console:section &emoji=📋 (styled 'Test outcomes' blue bold) {
      $namespace-controller[display-tree]
    }
  }

  console:echo

  if $results[is-ok] {
    var message = 'All the '$results[total-tests]' tests passed.'
    console:echo (styled $message green bold)
  } else {
    var message = 'Failed tests: '$results[total-failed]' out of '$results[total-tests]'.'
    console:echo (styled $message red bold)
  }
}