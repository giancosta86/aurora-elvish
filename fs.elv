use file
use os
use path
use str
use ./lang
use ./seq

fn touch { |path|
  print > $path
}

fn rimraf { |path|
  rm -rf $path
}

fn copy { |from to|
  cp -r $from $to
}

fn move { |from to|
  mv $from $to
}

fn temp-file-path { |&dir='' @pattern|
  var temp-file = (os:temp-file &dir=$dir $@pattern)
  file:close $temp-file

  put $temp-file[name]
}

fn mkcd { |&perm=0o755 @components|
  var actual-path = (path:join $@components)

  os:mkdir-all &perm=$perm $actual-path

  cd $actual-path
}

fn -with-path-sandbox { |inputs|
  var path = (path:abs $inputs[path])
  var backup-suffix = $inputs[backup-suffix]
  var test-path-is-ok = $inputs[test-path-is-ok]
  var test-path-is-wrong = $inputs[test-path-is-wrong]
  var error-message = $inputs[error-message]
  var block = $inputs[block]

  var backup-path

  if ($test-path-is-ok $path) {
    set backup-path = $path''$backup-suffix

    copy $path $backup-path
  } elif ($test-path-is-wrong $path) {
    fail $error-message
  } else {
    set backup-path = $nil
  }

  try {
    $block
  } finally {
    tmp pwd = (path:dir $path)
    rimraf $path

    if $backup-path {
      move $backup-path $path
    }
  }
}

fn with-file-sandbox { |&backup-suffix='.orig' path block|
  -with-path-sandbox [
    &path=$path
    &backup-suffix=$backup-suffix
    &test-path-is-ok=$os:is-regular~
    &test-path-is-wrong=$os:is-dir~
    &error-message='The path must be a regular file!'
    &block=$block
  ]
}

fn with-dir-sandbox { |&backup-suffix='.orig' path block|
  -with-path-sandbox [
    &path=$path
    &backup-suffix=$backup-suffix
    &test-path-is-ok=$os:is-dir~
    &test-path-is-wrong=$os:is-regular~
    &error-message='The path must be a directory!'
    &block=$block
  ]
}

fn -with-temp-object { |temp-path consumer|
  try {
    {
      var temp-pwd = (lang:ternary (os:is-dir $temp-path) $temp-path (path:dir $temp-path))

      tmp pwd = $temp-pwd

      $consumer $temp-path
    }
  } finally {
    rimraf $temp-path
  }
}

fn with-temp-file { |&dir='' consumer|
  -with-temp-object (temp-file-path &dir=$dir) $consumer
}

fn with-temp-dir { |&dir='' consumer|
  -with-temp-object (os:temp-dir &dir=$dir) $consumer
}
