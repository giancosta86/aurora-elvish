use ./resources #TODO! change this!

describe 'Loading resources from a nested script'  {
  var resources = (resources:for-script (src))

  var alpha-path = ($resources[get-path] alpha.txt)

  if 'should return the correct path' {
    put $alpha-path |
      should-be 'testing/resources/alpha.txt'
  }

  it 'should return the content' {
    var alpha-content = (slurp < $alpha-path)

    put $alpha-content |
      should-be "Hello!\n"
  }
}
