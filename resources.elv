use path

fn for-script { |caller-src-result|
  var caller-path = $caller-src-result[name]
  var caller-directory = (path:dir $caller-path)

  put [
    &get-path={ |relative-path|
      path:join $caller-directory $relative-path
    }
  ]
}