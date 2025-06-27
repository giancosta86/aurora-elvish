use path
use str
use ../fs
use ./node-version

var initial-version = v13.0.0

var nvmrc-version = v18.17.1

var package-json-version = v16.14.0

fn -write-nvmrc-file {
  echo $nvmrc-version > .nvmrc
}

fn -write-package-json-file {
  var version-for-json = $package-json-version[1..]

  echo '{ "engines": { "node": ">='$version-for-json' <90" }}' > package.json
}

describe 'Retrieving the requested NodeJS version' {
  describe 'from a directory containing only .nvmrc' {
    it 'should emit such version' {
      fs:with-temp-dir { |_|
        -write-nvmrc-file

        node-version:detect-in-pwd |
          should-be $nvmrc-version
      }
    }
  }

  describe 'from a directory containing only package.json field' {
    it 'should emit such version' {
      fs:with-temp-dir { |_|
        -write-package-json-file

        node-version:detect-in-pwd |
          should-be $package-json-version
      }
    }
  }

  describe 'from a directory containing both .nvmrc and package.json field' {
    it 'should emit the version in .nvmrc' {
      fs:with-temp-dir { |_|
        -write-nvmrc-file
        -write-package-json-file

        node-version:detect-in-pwd |
          should-be $nvmrc-version
      }
    }
  }

  describe 'from a directory not directly containing such information' {
    describe 'when an ancestor directory contains .nvmrc' {
      it 'should emit such version' {
        fs:with-temp-dir { |_|
          -write-nvmrc-file

          fs:mkcd (path:join A B C D)

          node-version:detect-in-pwd |
            should-be $nil

          fail-test
        }
      }
    }

    describe 'when an ancestor directory contains only package.json field' {
      it 'should emit such version' {
        fail-test
      }
    }

    describe 'when an ancestor directory contains both .nvmrc and package.json field' {
      it 'should emit the version in .nvmrc' {
        fail-test
      }
    }
  }
}