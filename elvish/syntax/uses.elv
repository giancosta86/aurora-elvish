use epm #TODO! Detect this!
use path
use re
use str
use ../../string

var -use-regex = '(?m)^\s*use\s+(\S+)(?:\s+(\S+))?\s*(?:#.*)?$'

var standard = 'Standard'
var absolute = 'Absolute'
var relative = 'Relative'

fn parse { |source-code|
  re:find $-use-regex $source-code | each { |match|
    var groups = $match[groups]

    var reference = $groups[1][text]
    var alias = (string:empty-to-default $groups[2][text])

    var reference-components = [(str:split / $reference)]

    var kind = (
      if (str:has-prefix $reference '.') {
        put $relative
      } elif (== 1 (count $reference-components)) {
        put $standard
      } else {
        put $absolute
      }
    )

    var namespace = (coalesce $alias $reference-components[-1])

    put [
      &reference=$reference
      &alias=$alias
      &namespace=$namespace
      &kind=$kind
    ]
  }
}
