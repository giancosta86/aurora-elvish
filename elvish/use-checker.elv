use ../hash-set
use ./syntax/analysis
use ./syntax/ns-identifiers
use ./syntax/uses

fn -find-unreferenced-uses { |uses use-namespaces accessed-namespaces|

}

fn -find-dangling-namespaces { |uses use-namespaces accessed-namespaces|

}

fn -find-missing-relative-uses { |path uses|
  put [(
    all $uses |
      keep-if { |use-info| ==s $use-info[kind] $uses:relative } |
      keep-if { |use-info|
        not (os:is-regular (path:join (path:dir $path) $use-info[reference]))
      }
  )]
}

fn check { |
  &interactive=$true
  &unreferenced-uses=$true
  &dangling-namespaces=$true
  &missing-relative-uses=$true
|
  var errors = (
    analysis:analyze-tree { |path content|
      var uses = (uses:parse $content)

      var use-namespaces
      var accessed-namespaces

      if (or $unreferenced-uses $dangling-namespaces) {
        set use-namespaces =
          all $uses |
            each { |use-info| put $use-info[namespace] } |
            hash-set:from (all)

        set accessed-namespaces = (
          ns-identifiers:parse $content |
            each { |ns-identifier|
              put $ns-identifier[namespace]
            } |
            hash-set:from (all)
        )
      }

      var file-result = [&]

      if $unreferenced-uses {
        set file-result = (
          assoc $file-result unreferenced-uses (-find-unreferenced-uses $uses $use-namespaces $accessed-namespaces)
        )
      }

      if $dangling-namespaces {
        set file-result = (
          assoc $file-result dangling-namespaces (-find-dangling-namespaces $uses $use-namespaces $accessed-namespaces)
        )
      }

      if $missing-relative-uses {
        set file-result = (
          assoc $file-result missing-relative-uses (-find-missing-relative-uses $path $uses)
        )
      }

      put $file-result
    }
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