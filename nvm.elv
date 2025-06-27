use str
use path
use ./fs

var -nvm-boot-script = '~/.nvm/nvm.sh'

fn -is-nvm-subpath { |path|
  str:has-prefix $path (path:join ~ .nvm versions)$path:separator
}

fn -ensure-nvm-node-executable-in-paths { |node-executable|
  var paths-without-nvm = [(
    all $paths | each { |path|
      if (not (-is-nvm-subpath $path)) {
        put $path
      }
    }
  )]

  set paths = [
    (path:dir $node-executable)

    $@paths-without-nvm
  ]
}

fn nvm { |@params|
  fs:with-temp-file { |output-path|
    bash -c 'source '$-nvm-boot-script'; nvm '(str:join " " [$@params])'; nvm which current > '$output-path

    var current-node-executable = (slurp < $output-path)

    -ensure-nvm-node-executable-in-paths $current-node-executable
  }
}

fn ensure-path-entry {
  -ensure-nvm-node-executable-in-paths (bash -c 'source '$-nvm-boot-script'; nvm which current')
}