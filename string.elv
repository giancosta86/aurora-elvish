use ./lang

fn empty-to-default { |&default=$nil source|
  lang:ternary (!=s $source '') $source $default
}