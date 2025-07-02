use ../fs
use ./use-checker

fn -run-test-check { |inputs|
  var superfluous-uses = $inputs[superfluous-uses]

  var dangling-namespaces = $inputs[dangling-namespaces]

  var inexistent-relative-uses = $inputs[inexistent-relative-uses]

  fs:with-temp-dir { |temp-dir|
    tmp pwd = $temp-dir

    echo '
    use str
    use re

    use github.com/giancosta86/aurora-elvish/console
    use github.com/giancosta86/aurora-elvish/curl

    use ./beta
    use ./gamma

    str:has-prefix -cip-ciop -cip

    console:echo Test!

    beta:add 90 2

    path:join X Y Z
    ' > alpha.elv

    echo '
    fn add { |x y| + $x $y }
    ' > beta.elv

    echo '
    use os

    use ./beta
    use ./delta
    use ../dodo
    ' > gamma.elv

    use-checker:check-uses &interactive=$false &superfluous-uses=$superfluous-uses &dangling-namespaces=$dangling-namespaces &inexistent-relative-uses=$inexistent-relative-uses
  }
}

describe 'Checking the use directives in a source file' {
  it 'should detect superfluous uses' {
    -run-test-check [
      &superfluous-uses=$true
      &dangling-namespaces=$false
      &inexistent-relative-uses=$false
    ] |
      should-be [
        &alpha.elv=    [
          &superfluous-uses=   [
            re
            github.com/giancosta86/aurora-elvish/curl
            ./gamma
            ]
          ]
        &gamma.elv=    [
          &superfluous-uses=   [
            os
            ./beta
            ./delta
            ../dodo
            ]
          ]
      ]
  }

  it 'should detect dangling references' {
    fail-test
  }

  it 'should detect inexistent relative uses' {
    fail-test
  }

  it 'should detect all the issues at once' {
    fail-test
  }
}