use os
use str
use ./command

describe 'Testing whether a command exists in Bash' {
  describe 'if the command is a program in the path' {
    it 'should put $true' {
      command:exists-in-bash cat |
        should-be $true
    }
  }

  describe 'if the command is an alias' {
    it 'should put $true' {
      var test-alias = myTestAlias

      echo 'alias '$test-alias'=''ls -l''' >> ~/.bashrc

      command:exists-in-bash cat |
        should-be $true
    }
  }

  describe 'if the command does not exist' {
    it 'should put $false' {
      command:exists-in-bash INEXISTENT |
        should-be $false
    }
  }
}

describe 'Capturing a block of commands to log' {
  it 'should actually create the log file on output' {
    var capture-result = (command:capture-to-log {
      echo Hello, world!
    })

    os:is-regular $capture-result[log-path] |
      should-be $true
  }

  it 'should have a cleaning method' {
    var capture-result = (command:capture-to-log {
      echo Hello, world!
    })

    $capture-result[clean]

    os:is-regular $capture-result[log-path] |
      should-be $false
  }

  it 'should detect successful outcome' {
    var capture-result = (command:capture-to-log {
      echo Hello, world!
    })
    defer $capture-result[clean]

    put $capture-result[outcome] |
      should-be $ok
  }

  it 'should detect failed outcome' {
    var exception-message = 'This is an exception!'

    var capture-result = (command:capture-to-log {
      fail $exception-message
    })
    defer $capture-result[clean]

    put $capture-result[outcome][reason][content] |
      should-be $exception-message
  }

  it 'should create a readable log file' {
    var capture-result = (command:capture-to-log {
      print Greetings!
    })
    defer $capture-result[clean]

    slurp < $capture-result[log-path] |
      should-equal Greetings!
  }

  describe 'when capturing both stdout and stderr' {
    it 'should capture stdout' {
      var capture-result = (command:capture-to-log {
        print TEST-OUT
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal TEST-OUT
    }

    it 'should capture stderr' {
      var capture-result = (command:capture-to-log {
        print TEST-ERR >&2
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal TEST-ERR
    }
  }

  describe 'when capturing just stdout' {
    it 'should capture stdout' {
      var capture-result = (command:capture-to-log &stderr=$false {
        print TEST-OUT
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal TEST-OUT
    }

    it 'should not capture stderr' {
      var capture-result = (command:capture-to-log &stderr=$false {
        echo TEST-ERR >&2
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal ''
    }
  }
}

describe 'Silencing a block' {
  it 'should produce no stdout' {
    var capture-result = (command:capture-to-log {
      command:silence {
        print TEST-OUT
      }
    })
    defer $capture-result[clean]

    $capture-result[get-log] |
      should-equal ''
  }

  it 'should produce no stderr' {
    var capture-result = (command:capture-to-log {
      command:silence {
        print TEST-ERR >&2
      }
    })
    defer $capture-result[clean]

    $capture-result[get-log] |
      should-equal ''
  }

  describe 'when the block fails' {
    it 'should fail as well' {
      fail-test
    }
  }
}

describe 'Silencing a block until error' {
  describe 'when the block is successful' {
    it 'should print no stdout' {
      var capture-result = (command:capture-to-log {
        command:silence-until-error {
          print TEST-OUT
        }
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal ''
    }

    it 'should print no stderr' {
      var capture-result = (command:capture-to-log {
        command:silence-until-error {
          print TEST-ERR >&2
        }
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal ''
    }
  }

  describe 'when the block fails' {
    it 'should print stdout' {
      var capture-result = (command:capture-to-log {
        command:silence-until-error {
          print TEST-OUT
          fail 'KABOOOOM!'
        }
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        str:contains (all) '❌❌❌' |
        should-be $true
    }

    it 'should print stderr' {
      var capture-result = (command:capture-to-log {
        command:silence-until-error {
          print TEST-ERR >&2
          fail 'KABOOOOM!'
        }
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-equal ''
    }
  }
}