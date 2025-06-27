echo '☢☢☢ PWD HERE IS: '$pwd >&2
echo '🤔🤔🤔 SRC HERE IS: '(src)[name] >&2
echo '🔮🔮🔮 MAGICSRC HERE IS: '(magic-src)[name] >&2

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
