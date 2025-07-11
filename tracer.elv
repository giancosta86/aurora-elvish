use ./console

fn create { |is-enabled-retriever|
  put [
    &echo={ |@rest|
      if ($is-enabled-retriever) {
        console:echo $@rest
      }
    }

    &print={ |@rest|
      if ($is-enabled-retriever) {
        console:print $@rest
      }
    }

    &printf={ |&newline=$false template @values|
      if ($is-enabled-retriever) {
        console:printf &newline=$newline $template $@values
      }
    }

    &pprint={ |@values|
      if ($is-enabled-retriever) {
        console:pprint $@values
      }
    }

    &inspect={ |&emoji=🔎 description value|
      if ($is-enabled-retriever) {
        console:inspect &emoji=$emoji $description $value
      }
    }

    &inspect-inputs={ |inputs|
      if ($is-enabled-retriever) {
        console:inspect-inputs $inputs
      }
    }

    &section={ |&emoji=🔎 description string-or-block|
      if ($is-enabled-retriever) {
        console:section &emoji=$emoji $description $string-or-block
      }
    }
  ]
}
