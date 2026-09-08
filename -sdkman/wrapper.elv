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
    put "show_path() { echo $PATH | tr ':' '\n'; } && OLD_PATH=""$PATH"" && echo 🐼 BEFORE INIT: && show_path && source '"$paths:sdkman-script"' && export PATH=""$OLD_PATH"" && echo 🦫 AFTER RESTORE: && show_path && sdk "(all)" && echo 🦋 AFTER SDK: && show_path" |
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