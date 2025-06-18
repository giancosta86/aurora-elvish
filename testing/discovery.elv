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

fn run-file { |path|
  var test-namespace = (namespace:create)

  var source-string = (slurp < $path)

  eval &ns=$test-namespace $source-string

  put [
    &path=$path
    &passed=($test-namespace[get-passed~])
    &failed=($test-namespace[get-failed~])
  ]
}

fn run {
  -get-test-files | each { |test-file-path|
    run-file $test-file-path
  }
}