use file
use os
use ./console

fn exists-in-bash { |command|
  eq $ok ?(bash -c 'type '$command > $os:dev-null 2>&1)
}

fn silent-until-error { |block|
  var log-file = (os:temp-file)
  file:close $log-file

  var log-file-path = $log-file[name]

  try {
    var outcome = ?($block > $log-file-path 2>&1)

    if (not $outcome) {
      var log-file-size = (os:stat $log-file-path)[size]

      if (> $log-file-size 0) {
        console:section &emoji=❌ 'Error while running command block! Log' {
          cat $log-file-path
        }
      } else {
        console:echo ❌ The command block failed, but no log is available...
      }

      fail $outcome
    }
  } finally {
    rm -f $log-file-path
  }
}