use os
use ./command

describe 'Testing whether a command exists in Bash' {
  describe 'if the command is a program in the path' {
    it 'should put $true' {
      var exists = (command:exists-in-bash cat)

      (expect $exists)[to-be] $true
    }
  }

  describe 'if the command is an alias' {
    it 'should put $true' {
      var test-alias = myTestAlias

      echo 'alias '$test-alias'=''ls -l''' >> ~/.bashrc

      var exists = (command:exists-in-bash cat)

      (expect $exists)[to-be] $true
    }
  }

  describe 'if the command does not exist' {
    it 'should put $false' {
      var exists = (command:exists-in-bash INEXISTENT)

      (expect $exists)[to-be] $false
    }
  }
}

describe 'Capturing a block of commands to log' {
  it 'should actually create the log file on output' {
    var capture-result = (command:capture-to-log {
      echo Hello, world!
    })

    (expect (os:is-regular $capture-result[log-path]))[to-be] $true
  }

  it 'should have a cleaning method' {
    var capture-result = (command:capture-to-log {
      echo Hello, world!
    })

    $capture-result[clean]

    (expect (os:is-regular $capture-result[log-path]))[to-be] $false
  }

  it 'should detect successful outcome' {
    var capture-result = (command:capture-to-log {
      echo Hello, world!
    })
    defer $capture-result[clean]

    (expect $capture-result[outcome])[to-be] $ok
  }

  it 'should detect failed outcome' {
    var exception-message = 'This is an exception!'

    var capture-result = (command:capture-to-log {
      fail $exception-message
    })
    defer $capture-result[clean]

    (expect $capture-result[outcome][reason][content])[to-be] $exception-message
  }

  it 'should create a readable log file' {
    var capture-result = (command:capture-to-log {
      print Greetings!
    })
    defer $capture-result[clean]

    var content = (slurp < $capture-result[log-path])

    (expect $content)[to-equal] Greetings!
  }

  describe 'when capturing both stdout and stderr' {
    it 'should capture stdout' {
      var capture-result = (command:capture-to-log {
        print TEST-OUT
      })
      defer $capture-result[clean]

      var log = ($capture-result[get-log])

      (expect $log)[to-equal] TEST-OUT
    }

    it 'should capture stderr' {
      var capture-result = (command:capture-to-log {
        print TEST-ERR >&2
      })
      defer $capture-result[clean]

      var log = ($capture-result[get-log])

      (expect $log)[to-equal] TEST-ERR
    }
  }

  describe 'when capturing just stdout' {
    it 'should capture stdout' {
      var capture-result = (command:capture-to-log &stderr=$false {
        print TEST-OUT
      })
      defer $capture-result[clean]

      var log = ($capture-result[get-log])

      (expect $log)[to-equal] TEST-OUT
    }

    it 'should not capture stderr' {
      var capture-result = (command:capture-to-log &stderr=$false {
        echo TEST-ERR >&2
      })
      defer $capture-result[clean]

      var log = ($capture-result[get-log])

      (expect $log)[to-equal] ''
    }
  }
}