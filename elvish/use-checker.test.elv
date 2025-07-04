use ../fs
use ./use-checker
use ./use-checker-test-sources

fn -run-test-check { |inputs|
  var superfluous-uses = $inputs[superfluous-uses]

  var dangling-namespaces = $inputs[dangling-namespaces]

  var inexistent-relative-uses = $inputs[inexistent-relative-uses]

  fs:with-temp-dir { |temp-dir|
    tmp pwd = $temp-dir

    echo $use-checker-test-sources:alpha-source > alpha.elv

    echo $use-checker-test-sources:beta-source > beta.elv

    echo $use-checker-test-sources:gamma-source > gamma.elv

    use-checker:find-errors &display-results=$false &superfluous-uses=$superfluous-uses &dangling-namespaces=$dangling-namespaces &inexistent-relative-uses=$inexistent-relative-uses
  }
}

describe 'Checking the use directives in a source file' {
  it 'should detect superfluous uses' {
    -run-test-check [
      &superfluous-uses=$true
      &dangling-namespaces=$false
      &inexistent-relative-uses=$false
    ] |
      should-be [
        &alpha.elv=[
          &superfluous-uses=$use-checker-test-sources:alpha-superfluous-uses
        ]
        &gamma.elv=[
          &superfluous-uses=$use-checker-test-sources:gamma-superfluous-uses
        ]
      ]
  }

  it 'should detect dangling namespaces' {
    -run-test-check [
      &superfluous-uses=$false
      &dangling-namespaces=$true
      &inexistent-relative-uses=$false
    ] |
      should-be [
        &alpha.elv=[
          &dangling-namespaces=$use-checker-test-sources:alpha-dangling-namespaces
        ]
      ]
  }

  it 'should detect inexistent relative uses' {
    -run-test-check [
      &superfluous-uses=$false
      &dangling-namespaces=$false
      &inexistent-relative-uses=$true
    ] |
      should-be [
        &alpha.elv=    [
          &inexistent-relative-uses=$use-checker-test-sources:alpha-inexistent-relative-uses
        ]
        &gamma.elv=[
          &inexistent-relative-uses=$use-checker-test-sources:gamma-inexistent-relative-uses
        ]
      ]
  }

  it 'should detect all the issues at once' {
    -run-test-check [
      &superfluous-uses=$true
      &dangling-namespaces=$true
      &inexistent-relative-uses=$true
    ] |
      should-be [
        &alpha.elv=[
          &dangling-namespaces=$use-checker-test-sources:alpha-dangling-namespaces
          &inexistent-relative-uses=$use-checker-test-sources:alpha-inexistent-relative-uses
          &superfluous-uses=$use-checker-test-sources:alpha-superfluous-uses
        ]
        &gamma.elv=    [
          &inexistent-relative-uses=$use-checker-test-sources:gamma-inexistent-relative-uses
          &superfluous-uses=$use-checker-test-sources:gamma-superfluous-uses
        ]
      ]
  }

  it 'should run interactively' {
    use-checker:find-errors &display-results &superfluous-uses &dangling-namespaces &inexistent-relative-uses
  }
}