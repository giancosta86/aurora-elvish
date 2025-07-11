use os
use path
use ./console
use ./fs
use ./nvm

describe 'In nvm' {
  describe 'retrieving the current NodeJS executable' {
    it 'should output an existing file' {
      nvm:nvm which current |
        os:is-regular (all) |
        should-be $true
    }
  }

  describe 'ensuring the current NodeJS executable is in PATH' {
    it 'should work' {
      fs:with-file-sandbox $nvm:-boot-script {
        echo '
        nvm() {
          echo ~/.nvm/versions/node/v20.15.1/bin/node
        }
        ' > $nvm:-boot-script

        var current-node-executable = (nvm:nvm which current)

        var current-node-directory = (path:dir $current-node-executable)

        var paths-without-nvm = [(
          all $paths | each { |path|
            if (!=s $path $current-node-directory) {
              put $path
            }
          }
        )]

        set paths = $paths-without-nvm

        console:inspect &emoji=◀️ 'PATH before ensuring nvm' $paths

        console:inspect &emoji=📦 'NodeJS executable' (nvm:nvm which current)

        console:inspect &emoji=▶️ 'PATH after ensuring nvm' $paths

        nvm:ensure-path-entry

        all $paths | each { |path|
          if (==s $path $current-node-directory) {
            return
          }
        }

        fail 'No NodeJS executable from nvm was added to PATH!'
      }
    }
  }
}
