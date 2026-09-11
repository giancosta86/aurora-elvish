use os
use path
use ../fs
use ./paths

fn within-temp-sdkman-home { |&candidates=[] block|
  fs:within-temp-dir {
    tmp paths:sdkman-home = $pwd

    all $candidates | each { |candidate|
      paths:get-candidate-dir $candidate |
        os:mkdir-all (all)
    }

    $block
  }
}

fn get-current-link { |candidate|
  paths:get-candidate-dir $candidate |
    path:join (all) current
}

fn set-current { |candidate version|
  var current-link = (get-current-link $candidate)

  os:remove-all $current-link

  paths:get-candidate-dir $candidate &version=$version |
    os:symlink (all) $current-link
}