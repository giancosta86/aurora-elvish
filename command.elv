use os
use ./console
use ./files

fn exists-in-bash { |command|
  eq $ok ?(bash -c 'type '$command > $os:dev-null 2>&1)
}

fn capture-to-log { |&stderr=$true block|
  var log-path = (files:temp-path)

  var outcome

  if $stderr {
    set outcome = ?({ { $block | only-bytes } > $log-path 2>&1 })
  } else {
    set outcome = ?({ { $block | only-bytes } > $log-path })
  }

  put [
    &outcome=$outcome
    &log-path=$log-path
    &get-log={ slurp < $log-path }
    &clean={ rm -f $log-path }
  ]
}

fn silence { |block|
  { $block | only-bytes } > $os:dev-null 2>&1
}

fn silence-until-error { |&description=$nil block|
  var capture-result = (capture-to-log $block)
  defer $capture-result[clean]

  if (not $capture-result[outcome]) {
    var actual-description = (coalesce $description 'Error while running command block!')

    var log-path = $capture-result[log-path]
    var log-size = (os:stat $log-path)[size]

    if (> $log-size 0) {
      console:section &emoji=❌ $actual-description {
        cat $log-path
      }
    } else {
      console:echo ❌ $actual-description
    }

    fail $capture-result[outcome]
  }
}