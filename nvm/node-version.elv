use os
use path
use re
use str
use ../console
use ../lang
use ../seq
use ../string

fn -detect-from-package-json {
  if (not (os:is-regular package.json)) {
    put $nil
    return
  }

  var version-field = (
    jq -r '.engines.node // ""' package.json |
      string:empty-to-default (all)
  )

  if $version {
    console:inspect 'NodeJS version requested in package.json field' $version-field
  } else {
    console:echo 💭 No 'engines/node' field in package.json...
  }

  re:find '.*?(\d+(?:\.\d+)*).*' $version-field | each { |match|
    put 'v'$match[groups][1][text]
  }
}

fn -detect-from-nvmrc {
  if (os:is-regular .nvmrc) {
    var version = (
      slurp < .nvmrc |
        string:empty-to-default (all)
      )

    console:inspect 'Requested version in the .nvmrc file' $version

    lang:ternary (seq:is-non-empty $version) $version $nil
  } else {
    console:echo 💭 No .nvmrc file...
    put $nil
  }
}

fn detect-in-pwd {
  coalesce (
    -detect-from-nvmrc
  ) (
    -detect-from-package-json
  )
}

fn detect-recursively {
  var original-pwd = $pwd

  try {
    while $true {
      var version = (detect-in-pwd)

      if $version {
        put $version
        return
      }

      var parent-dir = (path:dir $pwd)
      if (==s $parent-dir $pwd) {
        put $nil
        return
      }

      set pwd = $parent-dir
    }
  } finally {
    set pwd = $original-pwd
  }
}