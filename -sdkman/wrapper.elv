use os
use str
use ../command
use ../curl
use ./paths

pragma unknown-command = disallow

var -bash~ = (external bash)

var -curl~ = (external curl)

fn -ensure-installed {
  if (os:is-dir $paths:sdkman-home) {
    return
  }

  echo 📥 Installing SDKMAN...

  -curl -s 'https://get.sdkman.io' |
    -bash

  echo ✅ SDKMAN installed!
}

fn -run-sdkman { |@arguments|
  -ensure-installed

  str:join ' ' $arguments |
    put 'OLD_PATH="$PATH" && source '$paths:init-script' && export PATH="$OLD_PATH" && sdk '(all) |
    command:update-env-via-bash [PATH SDKMAN_ENV]
}

#
# Runs SDKMAN's Bash script, forwarding the arguments.
#
# If SDKMAN is not already on the system, it will be automatically installed.
#
# As a plus, this command handles PATH and *_HOME variables in a robust and consistent way.
#
var sdk~ = (
  var used-versions = [&]

  var env-versions = [&]

  fn handle-path-altering-command { |block|
    $block

    paths:init-vars &overriding-maps=[
      $env-versions

      $used-versions
    ]
  }

  fn handle-use { |candidate version|
    handle-path-altering-command {
      set used-versions = (
        assoc $used-versions $candidate $version
      )
    }
  }

  fn handle-env-switch {
    handle-path-altering-command {
      set env-versions = (paths:get-sdkfile-candidates)
    }
  }

  fn handle-env-clear {
    handle-path-altering-command {
      set env-versions = [&]
    }
  }

  fn handle-uninstall {
    handle-path-altering-command { }
  }

  fn process-successful-run { |@arguments|
    var argument-count = (count $arguments)

    if (== $argument-count 0) {
      return
    }

    var command = $arguments[0]

    if (has-value [use u] $command) {
      handle-use $arguments[1] $arguments[2]
    } elif (eq $command env) {
      if (== $argument-count 1) {
        handle-env-switch
      } else {
        var sub-command = $arguments[1]

        if (eq $sub-command install) {
          handle-env-switch
        } elif (eq $sub-command clear) {
          handle-env-clear
        }
      } elif (has-value [uninstall rm] $command) {
        handle-uninstall
      }
    }
  }

  put { |@arguments|
    try {
      curl:with-silence {
        -run-sdkman $@arguments
      }
    } catch {
      # Just do nothing
    } else {
      process-successful-run $@arguments
    }
  }
)