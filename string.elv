use str
use ./lang
use ./seq

fn empty-to-default { |&default=$nil &trim=$true source|
  var actual-source = (
    if $trim {
      str:trim-space $source
    } else {
      put $source
    }
  )

  seq:empty-to-default &default=$default $actual-source
}