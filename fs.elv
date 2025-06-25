use file
use os
use path

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

fn preserve-file-state { |&suffix='.orig' path block|
  var backup-path

  if (os:is-regular $path) {
    set backup-path = $path$suffix

    copy $path $backup-path
  } else {
    set backup-path = $nil
  }

  try {
    $block
  } finally {
    if $backup-path {
      move $backup-path $path
    } else {
      rimraf $path
    }
  }
}

fn mkcd { |&perm=0o755 @components|
  var actual-path = (path:join $@components)

  os:mkdir-all &perm=$perm $actual-path

  cd $actual-path
}

fn -with-temp-object { |temp-path-factory|
  put { |consumer|
    var temp-path = ($temp-path-factory)

    try {
      $consumer $temp-path
    } finally {
      rimraf $temp-path
    }
  }
}

var with-temp-file~ = (-with-temp-object $temp-file-path~)

var with-temp-dir~ = (-with-temp-object $os:temp-dir~)