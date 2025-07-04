use re
use ./analysis

var -ns-identifier-regex = '(?m)\b(\S+?):((?:\S+)\b~?)'

fn parse { |source-code|
  analysis:analyze-lines $source-code { |line-number line|
    re:find $-ns-identifier-regex $line | each { |match|
      var groups = $match[groups]

      var namespace = $groups[1][text]
      var identifier = $groups[2][text]

      put [
        &line-number=$line-number
        &namespace=$namespace
        &identifier=$identifier
      ]
    }
  }
}