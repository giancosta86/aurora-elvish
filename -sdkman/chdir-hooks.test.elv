use os
use path
use ./chdir-hooks
use ./paths
use ./test-shared
use ./wrapper

fn get-sdkman-runs { |block|
  var spy = (command:spy)

  tmp wrapper:sdk~ = $spy[command]

  $block

  $spy[get-runs]
}

>> 'SDKMAN' {
  >> 'hooks' {
    >> 'registration' {
      tmp chdir-hooks:-before-cd~ = { |_| }
      tmp chdir-hooks:-after-cd~ = { }

      tmp paths = [X]
      tmp E:JAVA_HOME = dodo

      test-shared:within-temp-sdkman-home {
        paths:get-candidate-dir java &version=23-open |
          path:join (all) bin |
          os:mkdir-all (all)

        test-shared:set-current java 23-open


        chdir-hooks:register

        >> 'should update PATH' {
          all $paths |
            should-emit &any-order [
              (path:join (test-shared:get-current-link java) bin)
              X
            ]
        }

        >> 'should update *_HOME vars' {
          get-env JAVA_HOME |
            should-be (test-shared:get-current-link java)
        }
      }
    }

    >> 'execution' {
      >> 'when source dir has no sdk file and dest dir has no sdk file' {
        get-sdkman-runs {
          fs:with-temp-dir { |source-dir|
            cd $source-dir

            fs:with-temp-dir { |dest-dir|
              chdir-hooks:-before-cd $dest-dir

              cd $dest-dir

              chdir-hooks:-after-cd
            }
          }
        } |
          should-be []
      }

      >> 'when source dir has its sdk file and dest dir has no sdk file' {
        get-sdkman-runs {
          fs:with-temp-dir { |source-dir|
            cd $source-dir

            {
              echo java=8.0.502.fx-zulu
              echo gradle=2.10
            } > $paths:sdk-file

            fs:with-temp-dir { |dest-dir|
              chdir-hooks:-before-cd $dest-dir

              cd $dest-dir

              chdir-hooks:-after-cd
            }
          }
        } |
          should-be [
            [env clear]
          ]
      }

      >> 'when source dir has no sdk file and dest dir has its sdk file' {
        get-sdkman-runs {
          fs:with-temp-dir { |source-dir|
            cd $source-dir

            fs:with-temp-dir { |dest-dir|
              {
                echo java=23-open
                echo maven=3.9.9
              } > (path:join $dest-dir $paths:sdk-file)

              chdir-hooks:-before-cd $dest-dir

              cd $dest-dir

              chdir-hooks:-after-cd
            }
          }
        } |
          should-be [
            [env install]
          ]
      }

      >> 'when source dir has its sdk file and dest dir has another sdk file' {
        get-sdkman-runs {
          fs:with-temp-dir { |source-dir|
            cd $source-dir

            {
              echo java=8.0.502.fx-zulu
              echo gradle=2.10
            } > $paths:sdk-file

            fs:with-temp-dir { |dest-dir|
              {
                echo java=23-open
                echo maven=3.9.9
              } > (path:join $dest-dir $paths:sdk-file)

              chdir-hooks:-before-cd $dest-dir

              cd $dest-dir

              chdir-hooks:-after-cd
            }
          }
        } |
          should-be [
            [env install]
          ]
      }
    }
  }
}