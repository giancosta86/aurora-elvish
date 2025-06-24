use ../map

fn ensure { |map description factory|
  var existing-context = (map:get-value $map $description)

  if $existing-context {
    put [
      &context=$existing-context
      &updated-map=$map
    ]
  } else {
    var new-context = ($factory $description)

    var updated-map = (assoc $map $description $new-context)

    put [
      &context=$new-context
      &updated-map=$updated-map
    ]
  }
}

fn get-outcome-trees { |map|
  map:values $map |
    each { |context|
      $context[get-outcome-tree]
    } |
    put [(all)]
}