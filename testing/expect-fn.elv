fn expect-fn { |subject|
  put [
    &to-fail={
      try {
        $subject
      } catch e {
        #Just do nothing
      } else {
        fail 'The code block did not fail!'
      }
    }
  ]
}