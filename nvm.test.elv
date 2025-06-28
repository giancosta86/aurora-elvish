use os
use path
use str
use ./console
use ./nvm

describe 'Ensuring the current nvm NodeJS executable is in PATH' {
  it 'should work' {
    var paths-without-nvm = [(
      all $paths | each { |path|
        if (not (nvm:-is-nvm-subpath $path)) {
          put $path
        }
      }
    )]

    console:inspect &emoji=◀️ 'PATH before ensuring nvm' $paths

    set paths = $paths-without-nvm

    console:inspect &emoji=▶️ 'PATH after ensuring nvm' $paths

    nvm:ensure-path-entry

    all $paths | each { |path|
      if (nvm:-is-nvm-subpath $path) {
        return
      }
    }

    fail 'No NodeJS executable from nvm was added to PATH!'
  }
}

describe 'Retrieving the current NodeJS executable via nvm' {
  it 'should return an existing file' {
    nvm:nvm which current |
      os:is-regular (all) |
      should-be $true
  }
}