use os
use path
use ./console
use ./map

var -shells-by-extension = [
  &.elv='elvish'
  &.sh='bash'
]

var -prioritized-script-extensions = [.elv .sh]

fn get-actual-path { |base-path|
  if (os:is-regular $base-path) {
    console:inspect &emoji=📃 'Script found at base path' $base-path
    put $base-path
    return
  }

  for extension $-prioritized-script-extensions {
    var extended-path = $base-path''$extension
    console:inspect 'Looking for script at extended path' $extended-path

    if (os:is-regular $extended-path) {
      console:inspect &emoji=📃 'Script found at extended path' $extended-path
      put $extended-path
      return
    }
  }

  console:echo 💭 No script found, even after adding extensions...
  put $nil
}

fn -detect-shell { |script-path|
  var script-extension = (path:ext $script-path)

  map:get-value $-shells-by-extension $script-extension
}

fn run { |&working-directory=$nil &optional=$false &shell=$nil script-path @script-args|
  tmp pwd = (coalesce $working-directory $pwd)

  console:inspect &emoji=📁 'Current directory for scripting' $pwd

  var actual-script-path = (get-actual-path $script-path)

  if (not $actual-script-path) {
    var error-message = "Cannot find a script associated with '"$script-path"'"

    if $optional {
      console:echo 💭 $error-message...
      return
    } else {
      fail $error-message
    }
  }

  console:inspect &emoji=🐚 'Requested shell' $shell

  var actual-shell = (coalesce $shell (-detect-shell $actual-script-path))
  console:inspect &emoji=🐚 'Actual shell' $actual-shell

  if (not $actual-shell) {
    var error-message = "Cannot detect a shell for script path: '"$actual-script-path"'"

    if $optional {
      console:echo 💭 $error-message...
      return
    } else {
      fail $error-message
    }
  }

  console:inspect &emoji=📎 'Script args' $script-args

  (external $actual-shell) $actual-script-path $@script-args
}