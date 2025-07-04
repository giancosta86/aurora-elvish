use ./use-checker/errors
use ./use-checker/display

fn find-errors { |
  &includes='**.elv'
  &excludes=$nil
  &display-results=$true
  &superfluous-uses=$true
  &dangling-namespaces=$true
  &inexistent-relative-uses=$true
|
  var errors = (
    errors:find &includes=$includes &excludes=$excludes &superfluous-uses=$superfluous-uses &dangling-namespaces=$dangling-namespaces &inexistent-relative-uses=$inexistent-relative-uses
  )

  if $display-results {
    display:display-errors $errors
  }

  put $errors
}