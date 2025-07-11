use ../../console
use ../../map
use ../../seq

fn -format-error { |color path line-number kind code|
  console:echo $path':'$line-number': ' (styled $kind': ' $color) (styled $code bold $color)
}

fn -display-superfluous-uses { |path superfluous-uses|
  all $superfluous-uses | each { |error|
    -format-error yellow $path $error[line-number] 'Superfluous use' $error[reference]
  }
}

fn -display-dangling-namespaces { |path dangling-namespaces|
  all $dangling-namespaces | each { |error|
    -format-error yellow $path $error[line-number] 'Dangling namespace' $error[namespace]':'$error[identifier]
  }
}

fn -display-inexistent-relative-uses { |path inexistent-relative-uses|
  all $inexistent-relative-uses | each { |error|
    -format-error red $path $error[line-number] 'Inexistent relative use' $error[reference]
  }
}


fn display-errors { |errors|
  if (seq:is-empty $errors) {
    console:echo ✅ (styled 'No errors found in Elvish uses declarations!' bold green)
  } else {
    map:entries $errors |
      seq:each-spread { |path file-errors|
        if (has-key $file-errors superfluous-uses) {
          -display-superfluous-uses $path $file-errors[superfluous-uses]
        }

        if (has-key $file-errors dangling-namespaces) {
          -display-dangling-namespaces $path $file-errors[dangling-namespaces]
        }

        if (has-key $file-errors inexistent-relative-uses) {
          -display-inexistent-relative-uses $path $file-errors[inexistent-relative-uses]
        }
      }
  }
}