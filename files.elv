use os

fn backup { |&suffix='.orig' path block|
  if (not (os:is-regular $path)) {
    return
  }

  var backup-path = $path$suffix

  cp $path $backup-path

  try {
    $block
  } finally {
    mv $backup-path $path
  }
}