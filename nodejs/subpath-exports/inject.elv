use os
use path
use str
use ../../console
use ../../edit

var -index-names = [index.ts index.js]

fn -print-exports { |context-description|
  console:section &emoji=📦 'package.json exports '$context-description {
    jq -C .exports package.json
  }
}

fn -write-export { |relative-index-directory|
  if (not (
    or (==s $relative-index-directory '') (str:has-prefix $relative-index-directory '/')
  )) {
    fail 'The relative index directory must be empty or have a leading /'
  }

  var export-key = '.'$relative-index-directory

  var dist-index-directory = './dist'$relative-index-directory

  console:echo "🔑 Export '"$export-key"' provided by dist directory: '"$dist-index-directory"'"

  edit:json package.json '
      .exports += {
        "'$export-key'": {
          types: "'$dist-index-directory'/index.d.ts",
          import: "'$dist-index-directory'/index.js"
        }
      }'

  console:echo ✅ Export $export-key injected!
}

fn -inject-root-index { |source-directory|
  put $source-directory/{$@-index-names} | each { |potential-root-index|
    console:inspect 'Looking for potential root index' $potential-root-index

    if (os:is-regular $potential-root-index) {
      console:inspect &emoji=✅ 'Root index file found' $potential-root-index

      -write-export ''

      put $true
      return
    }
  }

  console:echo 💭 No root index file found...
  put $false
}

fn -inject-subdirectory-indexes { |source-directory|
  console:echo 🔽 Looking for potential subdirectory indexes...

  put $source-directory/*[type:regular][nomatch-ok]/{$@-index-names} |
    each { |index-path|
      console:inspect &emoji=💡 'Index file found in subdirectory, at path' $index-path

      var export-name = (str:trim-prefix (path:dir $index-path) $source-directory/)

      -write-export '/'$export-name
  }
}

fn -do-inject { |source-directory mode|
  var root-index-injected = (-inject-root-index $source-directory)

  if (and $root-index-injected (==s $mode prefer-index)) {
    console:echo 🐹 In this mode, since the root index has been found, no more subpath exports will be injected
    return
  }

  -inject-subdirectory-indexes $source-directory
}

fn inject { | mode |
  -print-exports 'before the injection'

  -do-inject $source-directory $mode

  -print-exports 'after the injection'
}