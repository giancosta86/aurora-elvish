use re
use ./lang
use ./seq
use ./string

var -pattern = '^v?(?P<major>0|[1-9]\d*)(?:\.(?P<minor>0|[1-9]\d*)(?:\.(?P<patch>0|[1-9]\d*))?)?(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<build>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'

fn parse { |source|
  var match = (
    re:find $-pattern $source |
      lang:ensure-put
  )

  if (not $match) {
    fail 'Invalid semver value: '''$source'''!'
  }

  var groups = $match[groups]

  put [
    &major=(put $groups[1][text] | num (all))

    &minor=(string:empty-to-default $groups[2][text] &default=0 | num (all))

    &patch=(string:empty-to-default $groups[3][text] &default=0 | num (all))

    &pre-release=(string:empty-to-default $groups[4][text])

    &build=(string:empty-to-default $groups[5][text])
  ]
}

fn to-string { |version|
  var result = $version[major]'.'$version[minor]'.'$version[patch]

  if $version[pre-release] {
    set result = $result'-'$version[pre-release]
  }

  if $version[build] {
    set result = $result'+'$version[build]
  }

  put $result
}

fn is-stable { |version|
  not (or $version[pre-release] $version[build])
}

fn stable-less-than { |left right|
  if (not (is-stable $left)) {
    fail 'Non-stable left operand: '(to-string $left)
  }

  if (not (is-stable $right)) {
    fail 'Non-stable right operand: '(to-string $right)
  }

  if (< $left[major] $right[major]) {
    put $true
    return
  }

  if (> $left[major] $right[major]) {
    put $false
    return
  }

  if (< $left[minor] $right[minor]) {
    put $true
    return
  }

  if (> $left[minor] $right[minor]) {
    put $false
    return
  }

  < $left[patch] $right[patch]
}

fn is-new-major { |version|
  and (== $version[minor] 0) (== $version[patch] 0) (is-stable $version)
}