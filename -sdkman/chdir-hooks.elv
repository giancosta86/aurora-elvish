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
  chdir-hooks:register [
    &debug-id='sdkman'

    &before=$-before-cd~

    &after=$-after-cd~
  ]
}

fn setup-env {
  fail 'WHAT SHOULD I DO HERE?'
}