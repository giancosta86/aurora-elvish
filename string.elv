use str
use ./lang

fn empty-to-default { |&default=$nil &trim=$true source|
  var actual-source = (
    if $trim {
      str:trim-space $source
    } else {
      put $source
    }
  )

  lang:ternary (!=s $actual-source '') $actual-source $default
}