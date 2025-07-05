use ../fs
use ./use-checker

var -alpha-source = ^
  'use str
  use re

  use github.com/giancosta86/aurora-elvish/console
  use github.com/giancosta86/aurora-elvish/curl

  use ./beta
  use ./gamma
  use ./omega

  str:has-prefix -cip-ciop -cip

  console:echo Test!

  beta:add 90 2

  path:join X Y Z

  ro:sigma 95'

var -alpha-superfluous-uses = [
  [
    &line-number=2
    &reference=re
  ]
  [
    &line-number=5
    &reference=github.com/giancosta86/aurora-elvish/curl
  ]
  [
    &line-number=8
    &reference=./gamma
  ]
  [
    &line-number=9
    &reference=./omega
  ]
]

var -alpha-dangling-namespaces = [
  [
    &line-number=17
    &identifier=join
    &namespace=path
  ]
  [
    &line-number=19
    &identifier=sigma
    &namespace=ro
  ]
]

var -alpha-inexistent-relative-uses = [
  [
    &line-number=9
    &alias=   $nil
    &kind=    Relative
    &namespace=       omega
    &reference=       ./omega
  ]
]

var -beta-source = ^
  'fn add { |x y| + $x $y }'

var -gamma-source = ^
  'use os
  use ./beta
  use ./delta

  use ../dodo'

var -gamma-superfluous-uses = [
  [
    &line-number=1
    &reference=os
  ]
  [
    &line-number=2
    &reference=./beta
  ]
  [
    &line-number=3
    &reference=./delta
  ]
  [
    &line-number=5
    &reference=../dodo
  ]
]

var -gamma-inexistent-relative-uses = [
  [
    &line-number=3
    &alias=$nil
    &kind=Relative
    &namespace=delta
    &reference=./delta
  ]
  [
    &line-number=5
    &alias=$nil
    &kind=Relative
    &namespace=dodo
    &reference=../dodo
  ]
]

fn -run-test-check { |inputs|
  var superfluous-uses = $inputs[superfluous-uses]

  var dangling-namespaces = $inputs[dangling-namespaces]

  var inexistent-relative-uses = $inputs[inexistent-relative-uses]

  var display-results = $inputs[display-results]

  fs:with-temp-dir { |temp-dir|
    tmp pwd = $temp-dir

    echo $-alpha-source > alpha.elv

    echo $-beta-source > beta.elv

    echo $-gamma-source > gamma.elv

    use-checker:find-errors &display-results=$false &superfluous-uses=$superfluous-uses &dangling-namespaces=$dangling-namespaces &inexistent-relative-uses=$inexistent-relative-uses
  }
}

describe 'Checking the use directives in a source file' {
  it 'should detect superfluous uses' {
    -run-test-check [
      &superfluous-uses=$true
      &dangling-namespaces=$false
      &inexistent-relative-uses=$false
      &display-results=$false
    ] |
      should-be [
        &alpha.elv=[
          &superfluous-uses=$-alpha-superfluous-uses
        ]
        &gamma.elv=[
          &superfluous-uses=$-gamma-superfluous-uses
        ]
      ]
  }

  it 'should detect dangling namespaces' {
    -run-test-check [
      &superfluous-uses=$false
      &dangling-namespaces=$true
      &inexistent-relative-uses=$false
      &display-results=$false
    ] |
      should-be [
        &alpha.elv=[
          &dangling-namespaces=$-alpha-dangling-namespaces
        ]
      ]
  }

  it 'should detect inexistent relative uses' {
    -run-test-check [
      &superfluous-uses=$false
      &dangling-namespaces=$false
      &inexistent-relative-uses=$true
      &display-results=$false
    ] |
      should-be [
        &alpha.elv=    [
          &inexistent-relative-uses=$-alpha-inexistent-relative-uses
        ]
        &gamma.elv=[
          &inexistent-relative-uses=$-gamma-inexistent-relative-uses
        ]
      ]
  }

  it 'should detect all the issues at once' {
    -run-test-check [
      &superfluous-uses=$true
      &dangling-namespaces=$true
      &inexistent-relative-uses=$true
      &display-results=$false
    ] |
      should-be [
        &alpha.elv=[
          &dangling-namespaces=$-alpha-dangling-namespaces
          &inexistent-relative-uses=$-alpha-inexistent-relative-uses
          &superfluous-uses=$-alpha-superfluous-uses
        ]
        &gamma.elv=    [
          &inexistent-relative-uses=$-gamma-inexistent-relative-uses
          &superfluous-uses=$-gamma-superfluous-uses
        ]
      ]
  }

  it 'should run interactively' {
    -run-test-check [
      &superfluous-uses=$true
      &dangling-namespaces=$true
      &inexistent-relative-uses=$true
      &display-results=$true
    ]
  }
}