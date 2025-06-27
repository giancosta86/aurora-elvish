use ../../resources

describe 'Loading resources from a nested script'  {
  var resources = (resources:for-script (src))

  var alpha-path = ($resources[get-path] alpha.txt)

  it 'should return the content' {
    var alpha-content = (slurp < $alpha-path)

    put $alpha-content |
      should-be "Hello!\n"
  }
}
