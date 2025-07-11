use os
use path
use str
use ./fs

fn -create-temp-tree { |temp-root|
  var alpha-file = (path:join $temp-root alpha)
  print Alpha > $alpha-file

  var beta-dir = (path:join $temp-root beta)
  var gamma-dir = (path:join $beta-dir gamma)
  os:mkdir-all $gamma-dir

  var delta-file = (path:join $gamma-dir delta)
  print Delta > $delta-file

  put [
    &alpha-file=$alpha-file
    &beta-dir=$beta-dir
    &gamma-dir=$gamma-dir
    &delta-file=$delta-file
  ]
}

describe 'The touch operation' {
  var temp-directory = (os:temp-dir)
  defer { fs:rimraf $temp-directory }

  var file-path = (path:join $temp-directory DODO)
  fs:touch $file-path

  it 'should create a file' {
    os:is-regular $file-path |
      should-be $true
  }

  it 'should create an empty file' {
    put (os:stat $file-path)[size] |
      should-be 0
  }
}

describe 'The rimraf operation' {
  describe 'when applied to a missing path' {
    it 'should just do nothing' {
      fs:rimraf '<SOME INEXISTENT MISSING FILE>'
    }
  }

  describe 'when applied to a file' {
    it 'should delete the file' {
      var temp-path = (fs:temp-file-path)

      os:is-regular $temp-path |
        should-be $true

      fs:rimraf $temp-path

      os:is-regular $temp-path |
        should-be $false
    }
  }

  describe 'when applied to a directory' {
    describe 'if the directory is empty' {
      it 'should delete it' {
        var temp-directory = (os:temp-dir)

        os:is-dir $temp-directory |
          should-be $true

        fs:rimraf $temp-directory

        os:is-dir $temp-directory |
          should-be $false
      }
    }

    describe 'if the directory contains files and directories' {
      it 'should delete the entire tree' {
        var temp-directory = (os:temp-dir)

        var temp-tree = (-create-temp-tree $temp-directory)

        os:is-regular $temp-tree[alpha-file] |
          should-be $true

        os:is-regular $temp-tree[delta-file] |
          should-be $true

        fs:rimraf $temp-directory

        os:is-dir $temp-directory |
          should-be $false
      }
    }
  }
}

describe 'The copy operation' {
  it 'should copy a file' {
    var sigma-path = (fs:temp-file-path)
    var tau-path = (fs:temp-file-path)

    print Sigma > $sigma-path

    fs:copy $sigma-path $tau-path

    os:is-regular $sigma-path |
      should-be $true

    slurp < $tau-path |
      should-be Sigma
  }

  it 'should copy a directory' {
    var temp-directory = (os:temp-dir)
    defer { fs:rimraf $temp-directory }

    var temp-tree = (-create-temp-tree $temp-directory)

    var omega-path = (path:join $temp-directory omega)

    fs:copy $temp-tree[beta-dir] $omega-path

    os:is-dir $temp-tree[beta-dir] |
      should-be $true

    os:is-dir $omega-path |
      should-be $true

    var omega-content-path = (path:join $omega-path gamma delta)

    slurp < $omega-content-path |
      should-be Delta
  }
}

describe 'The move operation' {
  it 'should move a file' {
    var sigma-path = (fs:temp-file-path)
    var tau-path = (fs:temp-file-path)

    print Sigma > $sigma-path

    fs:move $sigma-path $tau-path

    os:is-regular $sigma-path |
      should-be $false

    slurp < $tau-path |
      should-be Sigma
  }

  it 'should move a directory' {
    var temp-directory = (os:temp-dir)
    defer { fs:rimraf $temp-directory }

    var temp-tree = (-create-temp-tree $temp-directory)

    var omega-path = (path:join $temp-directory omega)

    fs:move $temp-tree[beta-dir] $omega-path

    os:is-dir $temp-tree[beta-dir] |
      should-be $false

    os:is-dir $omega-path |
      should-be $true

    var omega-content-path = (path:join $omega-path gamma delta)

    slurp < $omega-content-path |
      should-be Delta
  }
}

describe 'Requesting a temp file path' {
  describe 'when not passing a pattern' {
    it 'should use the default pattern' {
      var default-prefix = 'elvish-'

      var temp-path = (fs:temp-file-path)

      path:base $temp-path |
        str:has-prefix (all) $default-prefix |
        should-be $true
    }
  }

  describe 'when passing a custom pattern' {
    var custom-prefix = 'alpha-'
    var custom-suffix = '-omega'

    var temp-path = (fs:temp-file-path $custom-prefix'*'$custom-suffix)

    it 'should have the requested prefix' {
      path:base $temp-path |
        str:has-prefix (all) $custom-prefix |
        should-be $true
    }

    it 'should have the requested suffix' {
      path:base $temp-path |
        str:has-suffix (all) $custom-suffix |
        should-be $true
    }
  }
}

describe 'The mkcd command' {
  describe 'when the target directory does not exist' {
    var test-root = (os:temp-dir)
    defer { fs:rimraf $test-root }

    tmp pwd = $test-root

    var components = [alpha beta gamma delta]

    fs:mkcd $@components

    it 'should create that directory and its parents' {
      os:is-dir (path:join $test-root $@components) |
        should-be $true
    }

    it 'should move to that directory' {
      path:base $pwd |
        should-be $components[-1]
    }
  }

  describe 'when the target directory already exists' {
    it 'should just move to that directory' {
      var test-root = (os:temp-dir)
      defer { fs:rimraf $test-root }

      tmp pwd = $test-root

      var components = [ro sigma tau]

      os:mkdir-all (path:join $@components)

      fs:mkcd $@components

      path:base $pwd |
        should-be $components[-1]
    }
  }
}

describe 'Opening a file sandbox' {
  describe 'in the end' {
    describe 'if the path existed' {
      describe 'after modification' {
        it 'should restore the original file' {
          fs:with-temp-file { |test-file|
            var original-content = 'My sample text'
            print $original-content > $test-file

            fs:with-file-sandbox $test-file {
              print ASD > $test-file

              slurp < $test-file |
                should-be ASD
            }

            slurp < $test-file |
              should-be $original-content
          }
        }
      }

      describe 'after deletion' {
        it 'should restore the original file' {
          fs:with-temp-file { |test-file|
            fs:with-file-sandbox $test-file {
              fs:rimraf $test-file
            }

            os:is-regular $test-file |
              should-be $true
          }
        }
      }
    }

    describe 'if the path did not exist' {
      it 'should remove the file' {
        var test-file = SOME_INEXISTING_FILE

        fs:with-file-sandbox $test-file {
          echo Some text > $test-file
        }

        os:is-regular $test-file |
          should-be $false
      }
    }
  }
}

describe 'Opening a directory sandbox' {
  describe 'in the end' {
    describe 'if the path existed' {
      it 'should restore the tree as it was' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          var sigma = sigma.txt
          print Sigma > $sigma

          slurp < $sigma |
            should-be Sigma

          var a = A

          var b = (path:join $a B)

          fs:with-dir-sandbox . {
            print LOL > $sigma

            os:mkdir-all $b

            var c = (path:join $b C.txt)
            touch $c

            slurp < $sigma |
              should-be LOL

            os:is-regular $c |
              should-be $true
          }

          slurp < $sigma |
            should-be Sigma

          os:is-dir $a |
            should-be $false
        }
      }
    }

    describe 'if the path did not exist' {
      it 'should remove the entire tree' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          var a = A

          var b = (path:join $a B)

          os:is-dir $a |
            should-be $false

          fs:with-dir-sandbox $a {
            os:mkdir-all $b

            os:is-dir $a |
              should-be $true

            os:is-dir $b |
              should-be $true
          }

          os:is-dir $a |
            should-be $false
        }
      }
    }
  }
}

describe 'Consuming a temp file path' {
  it 'should make the temp path available' {
    fs:with-temp-file { |temp-path|
      os:is-regular $temp-path |
        should-be $true
    }
  }

  it 'should delete the temp path in the end' {
    var actual-path

    fs:with-temp-file { |temp-path|
      set actual-path = $temp-path
    }

    os:is-regular $actual-path |
      should-be $false
  }
}

describe 'Consuming a temp directory path' {
  it 'should make the temp path available' {
    fs:with-temp-dir { |temp-dir|
      os:is-dir $temp-dir |
        should-be $true
    }
  }

  it 'should delete the temp path in the end' {
    var actual-path

    fs:with-temp-dir { |temp-dir|
      set actual-path = $temp-dir
    }

    os:is-dir $actual-path |
      should-be $false
  }
}

describe 'Using a wildcard string to get a file list' {
  fn -with-test-tree { |block|
    fs:with-temp-dir { |temp-dir|
      tmp pwd = $temp-dir

      fs:touch A.elv
      fs:touch B.elv

      var q-dir = (path:join P Q)
      os:mkdir-all $q-dir

      fs:touch (path:join $q-dir R.elv)

      $block
    }
  }

  describe 'when only passing the includes wildcard' {
    it 'should display the matching paths' {
      -with-test-tree {
        put [(
          fs:wildcard '**.elv' |
            order
        )] |
          should-be [
            A.elv
            B.elv
            P/Q/R.elv
          ]
      }
    }
  }

  describe 'when passing an excluding wildcard' {
    it 'should return only the acceptable paths' {
      -with-test-tree {
        put [(
          fs:wildcard '**.elv' &excludes='**B.elv' |
            order
        )] |
          should-be [
            A.elv
            P/Q/R.elv
          ]
      }
    }
  }
}