describe "Arithmetic" {
  describe "addition" {
    it "should work" {
      echo Testing addition...

      var sum = (+ 90 2)

      (expect $sum)[to-equal] 92
    }
  }

  describe "division" {
    it "should work" {
      var division = (/ 90 10)

      (expect $division)[to-equal] 9
    }

    describe "when dividing by zero" {
      it "should fail" {
        (expect-fn {
          / 98 0
        })[to-fail]
      }
    }
  }
}