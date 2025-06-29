use ./tracer

var debug = 0
var info = 1
var warning = 2
var error = 3
var severe = 4

fn create { |&initial-level=warning|
  var level = $initial-level

  fn set-level { |new-level|
    if (
      or (< $new-level $debug) (> $new-level $severe)
    ) {
      fail 'Invalid logging level: '$new-level
    }

    $level = $new-level
  }

  fn create-tracer-for { |minimum-level|
    tracer:create {
      >= $level $minimum-level
    }
  }

  put [
    &set-level=$set-level~
    &debug=(create-tracer-for $debug)
    &info=(create-tracer-for $info)
    &warning=(create-tracer-for $warning)
    &error=(create-tracer-for $error)
    &severe=(create-tracer-for $severe)
  ]
}