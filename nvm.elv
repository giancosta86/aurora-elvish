use str
use path
use ./fs

var -nvm-boot-script = '~/.nvm/nvm.sh'

fn -is-nvm-related-path { |path|
  str:has-prefix $path (path:join ~ .nvm)$path:separator
}

fn -add-nvm-node-to-paths { |current-node-executable|
  var paths-without-nvm = [(
    all $paths | each { |path|
      if (not (-is-nvm-related-path $path)) {
        put $path
      }
    }
  )]

  set paths = [
    (path:dir $current-node-executable)

    $@paths-without-nvm
  ]
}

fn nvm { |params|
  fs:with-temp-file { |output-path|
    bash -c 'source '$-nvm-boot-script'; nvm '(str:join " " [$@params])'; nvm which current > '$output-path

    var nvm-path-entry = (slurp < $output-path)

    -add-nvm-node-to-paths $nvm-path-entry
  }
}

fn ensure-path-entry {
  -add-nvm-node-to-paths (bash -c 'source '$-nvm-boot-script'; nvm which current')
}