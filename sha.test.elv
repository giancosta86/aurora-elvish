use ./sha

describe 'SHA256' {
  it 'should be computed' {
    var computed-sha = (sha:compute256 'Hello, world!')

    (expect $computed-sha)[to-equal] d9014c4624844aa5bac314773d6b689ad467fa4e1d1a50a1b8a99d5a95f72ff5
  }
}