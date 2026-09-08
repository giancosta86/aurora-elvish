use os
use path
use ./paths
use ./test-shared

>> 'SDKMAN' {
  >> 'paths' {
    >> 'getting a specific SDK path' {
      paths:get-sdk-directory java 25.0.4-tem |
        should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
    }

    >> 'getting a *_HOME environment variable name' {
      paths:get-candidate-home-var java |
        should-be JAVA_HOME
    }

    >> 'setting up the *_HOME environment variables' {
      >> 'when the binaries are in PATH' {
        tmp E:JAVA_HOME = ''

        test-shared:with-temp-candidate java { |candidate-root|
          var expected-home = (path:join $candidate-root 23-open)

          tmp paths = [
            (path:join $expected-home bin)
          ]

          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be $expected-home
        }
      }

      >> 'when the binaries are not in PATH' {
        tmp E:JAVA_HOME = ''
        tmp paths = []

        test-shared:with-temp-candidate java { |candidate-root|
          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be ''
        }
      }
    }

    >> 'getting candidates from SDK file' {
      >> 'when no SDK file exists' {
        fs:within-temp-dir {
          paths:get-sdkfile-candidates |
            should-be [&]
        }
      }

      >> 'when the SDK file is empty' {
        fs:within-temp-dir {
          fs:touch $paths:sdk-file

          paths:get-sdkfile-candidates |
            should-be [&]
        }
      }

      >> 'when the SDK file contains SDKs as well as comments' {
        fs:within-temp-dir {
          {
            echo '# This is a temp SDK file'
            echo
            echo 'java=ALPHA'
            echo '    maven =  BETA  '
            echo
            echo "gradle\t=\tGAMMA"
          } > $paths:sdk-file

          paths:get-sdkfile-candidates |
            should-be [
              &java=ALPHA
              &maven=BETA
              &gradle=GAMMA
            ]
        }
      }
    }

    >> 'getting with current candidates' {
      >> 'when there are no candidates' {
        fs:within-temp-dir {
          tmp paths:sdkman-home = $pwd

          tmp paths = [
            X
            (path:join $pwd candidates dodo)
            Y
            (path:join $pwd candidates yogi)
            Z
          ]

          paths:get-with-current-candidates |
            should-be [
              X
              Y
              Z
            ]
        }
      }

      >> 'when there are candidates' {
        fs:within-temp-dir {
          tmp paths:sdkman-home = $pwd

          tmp paths = [
            X
            (path:join $pwd candidates dodo)
            Y
            (path:join $pwd candidates yogi)
            Z
          ]

          path:join candidates alpha current |
            os:mkdir-all (all)

          path:join candidates beta current bin |
            os:mkdir-all (all)

          path:join candidates gamma current |
            os:mkdir-all (all)

          paths:get-with-current-candidates |
            all (all) |
            should-emit &any-order [
              (path:join $pwd candidates alpha current)
              (path:join $pwd candidates beta current bin)
              (path:join $pwd candidates gamma current)
              X
              Y
              Z
            ]
        }
      }
    }
  }
}