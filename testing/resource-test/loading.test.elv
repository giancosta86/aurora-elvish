echo '☢☢☢ PWD HERE IS: '$pwd >&2

describe 'Loading resources from a nested script'  {
  it 'should return the content' {
    use ../../resources

    var resources = (resources:for-script (src))

    var alpha-path = ($resources[get-path] alpha.txt)

    var alpha-content = (slurp < $alpha-path)

    put $alpha-content |
      should-be "Hello!\n"
  }
}
