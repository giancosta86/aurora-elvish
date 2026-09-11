use os
use path
use ./paths
use ./test-shared
use ./wrapper

>> 'SDKMAN' {
  >> 'wrapper' {
    >> 'requesting the version' {
      capture {
        wrapper:sdk version
      } |
        should-contain SDKMAN
    }
  }

  >> 'PATH-altering commands' {
    tmp wrapper:-run-sdkman~ = { |@arguments| }

    >> 'use' {
      tmp paths = [X]
      tmp E:JAVA_HOME = DODO

      test-shared:within-temp-sdkman-home {
        var expected-path-entry = (
          paths:get-candidate-dir java &version=23-open |
            path:join (all) bin
        )
        os:mkdir-all $expected-path-entry

        wrapper:sdk use java 23-open

        all $paths |
          should-emit [
            $expected-path-entry
            X
          ]

        get-env JAVA_HOME |
          should-be (path:dir $expected-path-entry)
      }
    }

    fn test-env-loading { |sdk-invocation-block|
      tmp paths = [X]
      tmp E:JAVA_HOME = yogi
      tmp E:MAVEN_HOME = bubu

      test-shared:within-temp-sdkman-home {
        var expected-java-home = (paths:get-candidate-dir java &version=23-open)

        var expected-java-path-entry = (
          path:join $expected-java-home bin
        )
        os:mkdir-all $expected-java-path-entry

        var expected-maven-home = (paths:get-candidate-dir maven &version=3.9.9)

        var expected-maven-path-entry = (
          path:join $expected-maven-home bin
        )
        os:mkdir-all $expected-maven-path-entry

        fs:within-temp-dir {
          {
            echo java=23-open
            echo maven=3.9.9
          } > $paths:sdk-file

          $sdk-invocation-block

          all $paths |
            should-emit &any-order [
              $expected-java-path-entry
              $expected-maven-path-entry
              X
            ]

          get-env JAVA_HOME |
            should-be $expected-java-home

          get-env MAVEN_HOME |
            should-be $expected-maven-home
        }
      }
    }

    >> 'env' {
      test-env-loading {
        wrapper:sdk env
      }
    }

    >> 'env install' {
      test-env-loading {
        wrapper:sdk env install
      }
    }

    >> 'env clear' {
      test-shared:within-temp-sdkman-home &candidates=[java] {
        var legacy-java-home = (
          paths:get-candidate-dir java &version=8.0.502.fx-zulu
        )
        os:mkdir-all (path:join $legacy-java-home bin)

        test-shared:set-current java 8.0.502.fx-zulu

        var modern-java-home = (
          paths:get-candidate-dir java &version=23-open
        )
        os:mkdir-all $modern-java-home

        tmp paths = [
          (path:join $modern-java-home bin)
        ]

        tmp E:JAVA_HOME = $modern-java-home

        wrapper:sdk env clear

        var current-link = (test-shared:get-current-link java)

        all $paths |
          should-emit &any-order [
            (path:join $current-link bin)
          ]

        get-env JAVA_HOME |
          should-be $current-link
      }
    }
  }
}