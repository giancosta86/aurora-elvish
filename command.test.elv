use os
use str
use ./command

describe 'Testing whether a command exists in Bash' {
  describe 'if the command is a program in the path' {
    it 'should put $true' {
      command:exists-in-bash cat |
        should-be &strictly $true
    }
  }

  describe 'if the command is an alias' {
    it 'should put $true' {
      var test-alias = myTestAlias

      echo 'alias '$test-alias'=''ls -l''' >> ~/.bashrc

      command:exists-in-bash cat |
        should-be &strictly $true
    }
  }

  describe 'if the command does not exist' {
    it 'should put $false' {
      command:exists-in-bash INEXISTENT |
        should-be &strictly $false
    }
  }
}

describe 'Capturing the bytes from a block of commands' {
  it 'should actually create the log file for stdout' {
    var capture-result = (command:capture-bytes {
      echo Hello, world!
    })
    defer $capture-result[clean]

    os:is-regular $capture-result[log-path] |
      should-be &strictly $true
  }

  it 'should actually create the log file for stderr' {
    var capture-result = (command:capture-bytes {
      echo Hello, world! >&2
    })
    defer $capture-result[clean]

    os:is-regular $capture-result[log-path] |
      should-be &strictly $true
  }

  it 'should have a working cleaning method' {
    var capture-result = (command:capture-bytes {
      echo Hello, world!
    })

    $capture-result[clean]

    os:is-regular $capture-result[log-path] |
      should-be &strictly $false
  }

  it 'should detect successful outcome' {
    var capture-result = (command:capture-bytes {
      echo Hello, world!
    })
    defer $capture-result[clean]

    put $capture-result[outcome] |
      should-be &strictly $ok
  }

  it 'should detect failed outcome' {
    var exception-message = 'This is an exception!'

    var capture-result = (command:capture-bytes {
      fail $exception-message
    })
    defer $capture-result[clean]

    put $capture-result[outcome][reason][content] |
      should-be &strictly $exception-message
  }

  it 'should create a readable log file' {
    var capture-result = (command:capture-bytes {
      print Greetings!
    })
    defer $capture-result[clean]

    slurp < $capture-result[log-path] |
      should-be Greetings!
  }

  describe 'when capturing both stdout and stderr' {
    it 'should capture stdout' {
      var capture-result = (command:capture-bytes &stream=both {
        print TEST-OUT
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-be TEST-OUT
    }

    it 'should capture stderr' {
      var capture-result = (command:capture-bytes &stream=both {
        print TEST-ERR >&2
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-be TEST-ERR
    }
  }

  describe 'when capturing just stdout' {
    it 'should capture stdout' {
      var capture-result = (command:capture-bytes &stream=out {
        print TEST-OUT
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-be TEST-OUT
    }

    it 'should not capture stderr' {
      var capture-result = (command:capture-bytes &stream=out {
        print TEST-ERR >&2
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-be ''
    }
  }

  describe 'when capturing just stderr' {
    it 'should not capture stdout' {
      var capture-result = (command:capture-bytes &stream=err {
        print TEST-OUT
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-be ''
    }

    it 'should capture stderr' {
      var capture-result = (command:capture-bytes &stream=err {
        print TEST-ERR >&2
      })
      defer $capture-result[clean]

      $capture-result[get-log] |
        should-be 'TEST-ERR'
    }
  }

  describe 'when passing an invalid stream value' {
    it 'should fail' {
      expect-crash {
        command:capture-bytes &stream=INEXISTENT {}
      } |
        str:contains (all)[reason][content] 'Invalid stream value' |
        should-be &strictly $true
    }
  }
}

describe 'Silencing a block' {
  it 'should produce no stdout' {
    expect-log '' {
      command:silence {
        print TEST-OUT
      }
    }
  }

  it 'should produce no stderr' {
    expect-log '' {
      command:silence {
        print TEST-ERR >&2
      }
    }
  }

  describe 'when the block fails' {
    it 'should fail as well' {
      var error-message = 'MEGA-BOOM!'

      expect-crash {
        command:silence {
          fail $error-message
        }
      } |
        str:contains (all)[reason][content] $error-message |
        should-be &strictly $true
    }
  }
}

describe 'Silencing a block until error' {
  describe 'when the block is successful' {
    it 'should print no stdout' {
      expect-log '' {
        command:silence-until-error {
          print TEST-OUT
        }
      }
    }

    it 'should print no stderr' {
      expect-log '' {
        command:silence-until-error {
          print TEST-ERR >&2
        }
      }
    }
  }

  describe 'when the block fails' {
    it 'should print stdout' {
      expect-log &partial '❌❌❌' {
        command:silence-until-error {
          print TEST-OUT
          fail 'KABOOM!'
        }
      }
    }

    it 'should print stderr' {
      expect-log &partial '❌❌❌' {
        command:silence-until-error {
          print TEST-ERR >&2
          fail 'KABOOM!'
        }
      }
    }
  }
}