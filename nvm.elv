use str
use path
use ./files

fn -set-path-entry {|current-node-executable-path|
  var current-path = (path:dir $current-node-executable-path)

  var paths-without-nvm = [(put $@paths | each { |path|
      if (not (str:has-prefix $path ~/.nvm/)) {
        put $path
      }
    })]

  set paths = [$current-path $@paths-without-nvm]
}

fn nvm {|params|
  var temp-path = (files:temp-path)
  defer { rm -f $temp-path }

  bash -c 'source ~/.nvm/nvm.sh; nvm '(str:join " " [$@params])'; nvm which current > '$temp-path

  var nvm-path-entry = (slurp < $temp-path)

  -set-path-entry $nvm-path-entry
}

fn ensure-path-entry {
  -set-path-entry (bash -c 'source ~/.nvm/nvm.sh; nvm which current')
}