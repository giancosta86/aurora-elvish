use path
use str
use ./nvm

describe 'Ensuring the current nvm node executable is in PATH' {
  it 'should work' {
    var paths-without-nvm = [(
      all $paths | each { |path|
        if (not (nvm:-is-nvm-related-path $path)) {
          put $path
        }
      }
    )]

    set paths = $paths-without-nvm

    nvm:ensure-path-entry

    all $paths | each { |path|
      if (nvm:-is-nvm-related-path $path) {
        return
      }
    }

    fail 'No NodeJS executable from nvm was added to PATH!'
  }
}