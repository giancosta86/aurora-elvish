use str

fn compute256 { |value|
  echo $value |
    sha256sum |
    str:split ' ' (all) |
    take 1
}