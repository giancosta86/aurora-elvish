use ../lang
use ./namespace

var -test-extension = .test.elv

fn -get-test-files {
  put **[type:regular]$-test-extension
}

fn has-tests {
  var first-file = (
    -get-test-files |
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

fn run { |&allow-crash=$false|
  var is-ok = $true
  var total-tests = 0

  var file-results = (
    -get-test-files |
      each { |test-file-path|
        var file-result = (run-file &allow-crash=$allow-crash $test-file-path)

        if (> $file-result[failed] 0) {
          set is-ok = $false
        }

        set total-tests = (+ $total-tests $file-result[passed] $file-result[failed])

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
    &is-ok=$is-ok
    &total-tests=$total-tests
    &file-results=$file-results
  ]
}

fn test { |&allow-crash=$false|
  clear

  pprint (run &allow-crash=$allow-crash)
}