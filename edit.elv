fn file { |path transformer|
  var updated-content = (slurp < $path | $transformer (all))

  if $updated-content {
    print $updated-content > $path
  }
}

fn json { |path jq-operation|
  var updated-json = (jq $jq-operation $path | slurp)

  echo $updated-json > $path
}