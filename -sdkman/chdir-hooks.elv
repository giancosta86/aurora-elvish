use os
use path
use ../elvish/chdir-hooks
use ./paths
use ./wrapper

pragma unknown-command = disallow

fn -before-cd { |next-dir|
  var current-dir-has-sdk-file = (
    path:join $pwd $paths:sdk-file |
      os:is-regular (all)
  )

  var next-dir-has-sdk-file = (
    path:join $next-dir $paths:sdk-file |
      os:is-regular (all)
  )

  if (
    and $current-dir-has-sdk-file (not $next-dir-has-sdk-file)
  ) {
    wrapper:sdk env clear
  }
}

fn -after-cd {
  var current-dir-has-sdk-file = (
    path:join $pwd $paths:sdk-file |
      os:is-regular (all)
  )

  if $current-dir-has-sdk-file {
    wrapper:sdk env install
    wrapper:sdk env use
  }

  paths:setup-sdk-homes
}

#
# Registers the chdir hooks for SDKMAN, after ensuring the related env variables;
# finally, runs the after-cd hook.
#
fn register {
  set paths = (paths:get-with-current-candidates)

  chdir-hooks:register [
    &debug-id='sdkman'

    &before=$-before-cd~

    &after=$-after-cd~
  ]
}

#
# Ensures that SDKMAN's environment variables are set in the current shell,
# then runs the post-cd hook without installing it.
#
fn setup-env {
  set paths = (paths:get-with-current-candidates)

  $-after-cd~
}