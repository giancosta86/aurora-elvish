use builtin
use str
use ./lang
use ./map

fn echo { |@rest|
  builtin:echo $@rest > &2
}

fn print { |@rest|
  builtin:print $@rest > &2
}

fn printf { |&newline=$false template @values|
  builtin:printf $template $@values > &2

  if $newline {
    echo
  }
}

fn pprint { |@values|
  builtin:pprint $@values > &2
}

var -inspect-formatters = [
  &string={ |source| echo "'"$source"'" }
  &list=$pprint~
  &map=$pprint~
]

fn inspect { |&emoji=🔎 description value|
  printf '%s %s: ' $emoji $description

  var value-kind = (kind-of $value)

  var formatter = (
    map:get-value &default=$echo~ $-inspect-formatters $value-kind
  )

  $formatter $value
}

fn inspect-inputs { |inputs|
  inspect &emoji=📥 Inputs $inputs
}

fn section { |&emoji=🔎 description string-or-block|
  echo $emoji''$description":"

  if (lang:is-function $string-or-block) {
    $string-or-block > &2
  } else {
    echo $string-or-block
  }

  echo (str:repeat $emoji 3)
}
