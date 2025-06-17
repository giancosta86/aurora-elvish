fn file { |path text-transformer|
  var updated-content = (slurp < $path | $text-transformer (all))

  if $updated-content {
    print $updated-content > $path
  }
}

fn json { |path jq-operation|
  var updated-json = (jq $jq-operation $path | slurp)

  echo $updated-json > $path
}