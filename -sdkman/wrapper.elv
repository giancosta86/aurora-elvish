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
    put 'set OLD_PATH="$PATH" && '$paths:init-script' && export PATH="$OLD_PATH" && sdk '(all) |
    command:update-env-via-bash [PATH SDKMAN_ENV]
}

#
# Runs SDKMAN's Bash script, forwarding the arguments.
#
# If SDKMAN is not already on the system, it will be automatically installed.
#
fn sdk { |@arguments|
  curl:with-silence {
    -run-sdkman $@arguments
  }
}