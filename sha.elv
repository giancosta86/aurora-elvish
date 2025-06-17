use str

fn compute256 { |value|
  to-string $value |
    sha256sum |
    str:split ' ' (all) |
    take 1
}