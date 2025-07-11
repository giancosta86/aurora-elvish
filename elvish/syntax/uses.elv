use re
use str
use ../../string
use ./analysis

var -use-regex = '(?m)^\s*use\s+(\S+)(?:\s+(\S+))?\s*(?:#.*)?$'

var standard = 'Standard'
var absolute = 'Absolute'
var relative = 'Relative'

#TODO! Test that you can filter out use kinds!
fn parse { |&include-standard=$true &include-absolute=$true &include-relative=$true source-code|
  analysis:analyze-lines $source-code { |line-number line|
    re:find $-use-regex $line | each { |match|
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

      if (or ^
        (and (==s $kind $standard) (not $include-standard)) ^
        (and (==s $kind $absolute) (not $include-absolute)) ^
        (and (==s $kind $relative) (not $include-relative)) ^
      ) {
        continue
      }

      var namespace = (coalesce $alias $reference-components[-1])

      put [
        &line-number=$line-number
        &reference=$reference
        &alias=$alias
        &namespace=$namespace
        &kind=$kind
      ]
    }
  }
}
