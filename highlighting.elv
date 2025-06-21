fn -run-or-cat { |@command-line|
  var command = $command-line[0]

  if (has-external $command) {
    var args = $command-line[1..]

    (external $command) $@args
  } else {
    cat
  }
}

fn highlight { |format|
  if (==s $format json) {
    -run-or-cat jq -C
  } else {
    -run-or-cat pygmentize -l $format
  }
}