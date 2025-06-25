use os
use ./console
use ./files
use ./map

fn exists-in-bash { |command|
  eq $ok ?(bash -c 'type '$command > $os:dev-null 2>&1)
}

fn capture-bytes { |&stream=both block|
  var log-path = (files:temp-path)

  var filtered-block = { $block | only-bytes }

  var redirected-block = (map:get-value [
    &both={ put ?({ $filtered-block > $log-path 2>&1 }) }

    &out={ put ?({ $filtered-block > $log-path 2>$os:dev-null }) }

    &err={ put ?({ $filtered-block > $os:dev-null 2>$log-path }) }
  ] $stream &default={ fail 'Invalid stream value: '$stream  })

  var outcome = ($redirected-block)

  put [
    &outcome=$outcome
    &log-path=$log-path
    &get-log={ slurp < $log-path }
    &clean={
      if (os:is-regular $log-path) {
        os:remove $log-path
      }
    }
  ]
}

fn silence { |block|
  { $block | only-bytes } > $os:dev-null 2>&1
}

fn silence-until-error { |&description=$nil block|
  var capture-result = (capture-bytes &stream=both $block)
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