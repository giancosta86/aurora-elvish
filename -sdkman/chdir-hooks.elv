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
  }
}

#
# Registers the chdir hooks for SDKMAN, then runs the after-cd hook.
#
fn register {
  chdir-hooks:register [
    &before=$-before-cd~

    &after=$-after-cd~
  ]
}


#
# Invokes the after-cd hook without registering it; especially suitable for CI/CD contexts.
#
var setup-env~ = $-after-cd~