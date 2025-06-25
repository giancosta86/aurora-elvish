use file
use os

fn temp-path { |&dir='' @pattern|
  var temp-file = (os:temp-file &dir=$dir $@pattern)
  file:close $temp-file

  put $temp-file[name]
}

fn preserve-state { |&suffix='.orig' path block|
  var backup-path

  if (os:is-regular $path) {
    set backup-path = $path$suffix

    cp $path $backup-path
  } else {
    set backup-path = $nil
  }

  try {
    $block
  } finally {
    if $backup-path {
      mv $backup-path $path
    } else {
      os:remove $path
    }
  }
}