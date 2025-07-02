use os
use path
use ../console
use ../hash-set
use ../map
use ../seq
use ./syntax/analysis
use ./syntax/ns-identifiers
use ./syntax/uses

fn -find-superfluous-uses { |uses use-namespaces accessed-namespaces|
  var unused-namespaces = (hash-set:difference $use-namespaces $accessed-namespaces)

  all $uses |
    keep-if { |use-info| hash-set:contains $unused-namespaces $use-info[namespace] } |
    each { |use-info| put $use-info[reference] }
}

fn -find-dangling-namespaces { |ns-identifiers use-namespaces accessed-namespaces|
  var dangling-namespaces = (hash-set:difference $accessed-namespaces $use-namespaces)

  console:inspect &emoji=💣 'Dangling namespaces' $dangling-namespaces

  console:inspect &emoji=📃 'NS-IDENTIFIERS' $ns-identifiers

  console:inspect &emoji=🕵 'SET CHECK' [(
    all $ns-identifiers |
    each { |ns-identifier|
      put [$ns-identifier[namespace] (hash-set:contains $dangling-namespaces $ns-identifier[namespace])]
    }
  )]

  all $ns-identifiers |
    keep-if { |ns-identifier|
      hash-set:contains $dangling-namespaces $ns-identifier[namespace]
    }
}

fn -find-inexistent-relative-uses { |path uses|
  all $uses |
    keep-if { |use-info| ==s $use-info[kind] $uses:relative } |
    keep-if { |use-info|
      not (os:is-regular (path:join (path:dir $path) $use-info[reference]'.elv'))
    }
}

fn check-uses { |
  &interactive=$true
  &superfluous-uses=$true
  &dangling-namespaces=$true
  &inexistent-relative-uses=$true
|
  var errors = (
    analysis:analyze-tree [{ |path content|
      var uses = [(uses:parse $content)]

      var use-namespaces
      var ns-identifiers
      var accessed-namespaces

      if (or $superfluous-uses $dangling-namespaces) {
        set use-namespaces = (
          all $uses |
            each { |use-info| put $use-info[namespace] } |
            hash-set:from
        )

        set ns-identifiers = [(ns-identifiers:parse $content)]

        set accessed-namespaces = (
          all $ns-identifiers |
            each { |ns-identifier| put $ns-identifier[namespace] } |
            hash-set:from
        )
      }

      var file-result = [&]

      if $superfluous-uses {
        set file-result = (
          -find-superfluous-uses $uses $use-namespaces $accessed-namespaces |
            seq:empty-to-default [(all)] |
            map:assoc-non-nil $file-result superfluous-uses (all)
        )
      }

      if $dangling-namespaces {
        set file-result = (
          -find-dangling-namespaces $ns-identifiers $use-namespaces $accessed-namespaces |
            seq:empty-to-default [(all)] |
            map:assoc-non-nil $file-result dangling-namespaces (all)
        )

        console:inspect &emoji=📁 'FILE RESULT AFTER DANGLING - '$path $file-result
      }

      if $inexistent-relative-uses {
        set file-result = (
          -find-inexistent-relative-uses $path $uses |
            seq:empty-to-default [(all)] |
            map:assoc-non-nil $file-result inexistent-relative-uses (all)
        )
      }

      seq:empty-to-default $file-result
    }]
  )

  if $interactive {
    if seq:is-empty {
      console:echo ✅ (styled 'No errors found in Elvish uses declarations!' bold green)
    } else {
      console:section &emoji=❌ (styled 'Errors found in Elvish uses declarations!' bold red) {
        console:pprint $errors
      }
    }
  } else {
    put $errors
  }
}