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

fn run-file { |&allow-crash=$false path|
  var test-namespace = (namespace:create &allow-crash=$allow-crash)

  var source-string = (slurp < $path)

  eval &ns=$test-namespace $source-string

  put [
    &path=$path
    &passed=($test-namespace[get-passed~])
    &failed=($test-namespace[get-failed~])
  ]
}

fn run { |&allow-crash=$false &file-selector=$-default-file-selector|
  var total-tests = 0
  var total-failed = 0

  var file-results = (
    -get-test-files $file-selector |
      each { |test-file-path|
        var file-result = (run-file &allow-crash=$allow-crash $test-file-path)

        set total-tests = (+ $total-tests $file-result[passed] $file-result[failed])
        set total-failed = (+ $total-failed $file-result[failed])

        put [
          $file-result[path]
          [
            &passed=$file-result[passed]
            &failed=$file-result[failed]
          ]
        ]
      } |
      make-map
    )

  put [
    &is-ok=(== $total-failed 0)
    &total-tests=$total-tests
    &total-failed=$total-failed
    &file-results=$file-results
  ]
}

fn test { |&file-selector=$-default-file-selector &display-list=$false &allow-crash=$false|
  clear

  pprint (run &allow-crash=$allow-crash &file-selector=$file-selector)
}