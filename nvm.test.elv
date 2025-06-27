use os
use path
use str
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

    set paths = $paths-without-nvm

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