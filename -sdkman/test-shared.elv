use os
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