use os
use path
use re
use str

pragma unknown-command = disallow

var sdkman-home = (path:join ~ .sdkman)

var init-script = (path:join $sdkman-home bin sdkman-init.sh)

var sdk-file = .sdkmanrc

#
# Emits the absolute path of the directory containing the requested SDK:
#
# * if the &version flag is passed, the directory will be the one of that specific version;
#
# * otherwise, the root directory for the candidate will be emitted.
#
fn get-candidate-dir { |candidate &version=$nil|
  var candidate-home = (
    path:join $sdkman-home candidates $candidate
  )

  if $version {
    path:join $candidate-home $version
  } else {
    put $candidate-home
  }
}

#
# Iterates over the candidates in the "candidates" directory,
# passing each candidate name to the given block.
#
fn each-candidate { |candidate-consumer|
  put $sdkman-home/candidates/*[type:dir][nomatch-ok] |
    each $path:base~ |
    each $candidate-consumer
}

#
# Given a candidate, returns the name of the related *_HOME environment variable.
#
fn get-candidate-home-var { |candidate|
  put (str:to-upper $candidate)'_HOME'
}

fn -setup-candidate-home { |candidate|
  var home-var = (get-candidate-home-var $candidate)

  var candidate-root = (get-candidate-dir $candidate)

  all $paths | each { |current-path|
    if (str:has-prefix $current-path $candidate-root) {
      var home-path = (
        if (eq (path:base $current-path) bin) {
          path:dir $current-path
        } else {
          put $current-path
        }
      )

      set-env $home-var $home-path

      return
    }
  }

  unset-env $home-var
}

#
# Defines a *_HOME variable for each SDK candidate found in PATH.
#
# If a candidate has no related PATH entry, its *_HOME is unset.
#
fn setup-sdk-homes {
  each-candidate $-setup-candidate-home~
}

#
# Reads the SDK file from the current directory and outputs
# a map whose keys are the requested candidates and the values are their related versions.
#
# If there is no SDK file, just emits an empty map.
#
fn get-sdkfile-candidates {
  if (not (os:is-regular $sdk-file)) {
    put [&]
    return
  }

  from-lines < $sdk-file |
    each { |line|
      var sdk-line-regex = '\s*(\S+)\s*=\s*(\S+)\s*'

      re:find $sdk-line-regex $line | each { |matcher|
        var candidate = $matcher[groups][1][text]
        var version = $matcher[groups][2][text]

        put [$candidate $version]
      }
    } |
        make-map
}

#
# First removes from PATH every reference to SDKMAN candidates;
# then, for each candidate found, prepends to PATH:
#
# * the "current/bin" file system object, if existing
#
# * the "current" file system object, if existing.
#
# If no path representative can be found, the candidate in question won't be added to PATH.
#
fn get-with-current-candidates {
  var paths-without-candidates = [(
    all $paths |
      keep-if { |path|
        not (str:has-prefix $path (path:join $sdkman-home candidates))
      }
  )]

  var current-candidate-paths = [(
    each-candidate { |candidate|
      var candidate-root = (get-candidate-dir $candidate)

      var current-path = (path:join $candidate-root current)

      var bin-path = (path:join $current-path bin)

      if (os:exists $bin-path) {
        put $bin-path
      } elif (os:exists $current-path) {
        put $current-path
      }
    }
  )]

  put [(
    all $current-candidate-paths
    all $paths-without-candidates
  )]
}