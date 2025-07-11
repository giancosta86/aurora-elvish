use ./syntax/analysis
use ./syntax/uses

fn get-mermaid-source { |
  &includes='**.elv' #TODO! No match must be ok!
  &excludes=$nil
  &include-standard=$true
  &include-absolute=$true
  &include-relative=$true
|
  analysis:analyze-tree &includes=$includes &excludes=$excludes [
    { |path content|
      var uses = (
        uses:parse $content &include-standard=$include-standard &include-absolute=$include-absolute &include-relative=$include-relative
      )

      fail (pprint $uses)
    }
  ]
}