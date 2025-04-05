use os
use file
use str
use path

fn -set-path-entry {|current-node-executable-path|
  var current-path = (path:dir $current-node-executable-path)

  var paths-without-nvm = [(put $@paths | each { |path|
      if (not (str:has-prefix $path ~/.nvm/)) {
        put $path
      }
    })]

  set paths = [$current-path $@paths-without-nvm]
}

fn nvm {|@a|
  var temp-file = (os:temp-file)

  try {
    bash -c 'source ~/.nvm/nvm.sh; nvm '(str:join " " [$@a])'; nvm which current > '$temp-file[name]

    var nvm-path-entry = (slurp < $temp-file)

    -set-path-entry $nvm-path-entry
  } finally {
    file:close $temp-file
    os:remove $temp-file[name]
  }
}

fn ensure-path-entry {
  -set-path-entry (bash -c 'source ~/.nvm/nvm.sh; nvm which current')
}