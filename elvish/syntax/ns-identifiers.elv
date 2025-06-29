use re

var -ns-identifier-regex = '(?m)\b(\S+?):((?:\S+)\b~?)'

fn parse { |source-code|
  re:find $-ns-identifier-regex $source-code | each { |match|
    var groups = $match[groups]

    var namespace = $groups[1][text]
    var identifier = $groups[2][text]

    put [
      &namespace=$namespace
      &identifier=$identifier
    ]
  }
}