use os
use path
use ./paths
use ./test-shared

>> 'SDKMAN' {
  >> 'paths' {
    >> 'getting a specific candidate directory' {
      >> 'when the version is not passed' {
        paths:get-candidate-dir java |
          should-be (path:join $paths:sdkman-home candidates java)
      }

      >> 'when the version is passed' {
        paths:get-candidate-dir java &version=25.0.4-tem |
          should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
      }
    }

    >> 'iterating over the candidates' {
      >> 'when there is not even a candidate hub directory' {
        test-shared:within-temp-sdkman-home {
          paths:each-candidate $put~ |
            should-emit []
        }
      }

      >> 'when there are candidates' {
        test-shared:within-temp-sdkman-home &candidates=[alpha beta gamma] {
          paths:each-candidate { |candidate|
            echo 📁 $candidate
          } |
          should-emit &any-order [
            '📁 alpha'
            '📁 beta'
            '📁 gamma'
          ]
        }
      }
    }

    >> 'getting a *_HOME environment variable name' {
      paths:get-candidate-home-var java |
        should-be JAVA_HOME
    }

    >> 'setting up the *_HOME environment variable for a candidate' {
      >> 'when the candidate is not in PATH' {
        tmp paths = []
        tmp E:JAVA_HOME = DODO

        test-shared:within-temp-sdkman-home &candidates=[java] {
          paths:-setup-candidate-home java

          has-env JAVA_HOME |
            should-be $false
        }
      }
      >> 'when the candidate is in PATH' {
        >> 'when the PATH entry ends with "bin"' {
          tmp E:JAVA_HOME = DODO

          test-shared:within-temp-sdkman-home &candidates=[java] {
            var expected-home = (paths:get-candidate-dir java &version=23-open)

            tmp paths = [
              A
              B
              (path:join $expected-home bin)
              C
            ]

            paths:-setup-candidate-home java

            get-env JAVA_HOME |
              should-be $expected-home
          }
        }

        >> 'when the PATH entry does not end with "bin"' {
          tmp E:JAVA_HOME = YOGI

          test-shared:within-temp-sdkman-home &candidates=[java] {
            var expected-home = (paths:get-candidate-dir java &version=23-open)

            tmp paths = [
              X
              Y
              $expected-home
              Z
            ]

            paths:-setup-candidate-home java

            get-env JAVA_HOME |
              should-be $expected-home
          }
        }
      }
    }

    >> 'setting up all the *_HOME environment variables' {
      >> 'when the binaries are in PATH' {
        tmp E:JAVA_HOME = YOGI
        tmp E:MAVEN_HOME = BUBU

        test-shared:within-temp-sdkman-home &candidates=[java maven] {
          var expected-java-home = (paths:get-candidate-dir java &version=23-open)
          var expected-maven-home = (paths:get-candidate-dir maven &version=3.9.9)

          tmp paths = [
            A
            B
            (path:join $expected-maven-home bin)
            C
            (path:join $expected-java-home)
            D
            E
          ]

          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be $expected-java-home

          get-env MAVEN_HOME |
            should-be $expected-maven-home
        }
      }

      >> 'when the binaries are not in PATH' {
        tmp E:JAVA_HOME = YOGI
        tmp E:MAVEN_HOME = BUBU

        tmp paths = []

        test-shared:within-temp-sdkman-home &candidates=[java maven] {
          paths:setup-sdk-homes

          has-env JAVA_HOME |
            should-be $false

          has-env MAVEN_HOME |
            should-be $false
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
        test-shared:within-temp-sdkman-home &candidates=[] {
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

      >> 'when there are candidates with existing dirs' {
        test-shared:within-temp-sdkman-home &candidates=[java maven] {
          tmp paths = [
            X
            (paths:get-candidate-dir yogi)
            Y
            Z
          ]

          var expected-java-path = (path:join (paths:get-candidate-dir java) current)

          os:mkdir-all $expected-java-path

          var expected-maven-path = (path:join (paths:get-candidate-dir maven) current bin)

          os:mkdir-all $expected-maven-path

          paths:get-with-current-candidates |
            all (all) |
            should-emit &any-order [
              $expected-java-path
              $expected-maven-path
              X
              Y
              Z
            ]
        }
      }
    }
  }
}