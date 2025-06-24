use str
use ../console

var -level-chars = 4

var -leading-spaces-per-level = '│'(str:repeat ' ' (- $-level-chars 1))

var -level-joint = '└'(str:repeat '─' (- $-level-chars 1))

fn print { |level|
    if (< $level 0) {
      fail 'Invalid level'
    } elif (== $level 0) {
      return
    }

    var level-chars = 4

    range 0 (- $level 1) | each { |_|
      console:print $-leading-spaces-per-level
    }

    console:print $-level-joint
  }