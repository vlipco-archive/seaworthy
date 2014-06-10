function b.test.sample () {
  true
  b.unittest.assert_success $?
  true
  b.unittest.assert_error $?
}