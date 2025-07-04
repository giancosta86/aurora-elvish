var alpha-source = ^
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

var alpha-superfluous-uses = [
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

var alpha-dangling-namespaces = [
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

var alpha-inexistent-relative-uses = [
  [
    &line-number=9
    &alias=   $nil
    &kind=    Relative
    &namespace=       omega
    &reference=       ./omega
  ]
]

var beta-source = ^
  'fn add { |x y| + $x $y }'

var gamma-source = ^
  'use os
  use ./beta
  use ./delta

  use ../dodo'

var gamma-superfluous-uses = [
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

var gamma-inexistent-relative-uses = [
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