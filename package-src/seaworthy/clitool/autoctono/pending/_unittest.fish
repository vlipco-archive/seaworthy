## Unit Test Framework

set _atn_TESTFUNCS ()
set _atn_TESTDESCS ()
set _atn_ASSERTIONS_FAILED 0
set _atn_ASSERTIONS_PASSED 0

## Adds test cases to be executed
## @param testcase - Function with assertions
## @param description - Description of the testcase
function atn.unittest.add_test_case
  if is_function? "$argv[1]"
    _atn_TESTFUNCS+set  ($argv[1])
    shift
    _atn_TESTDESCS+set  ("$argv")
  end
end

## Asserts a function exit code is zero
## @param return code - return code of the command
function atn.unittest.assert_success
  if [ $argv[1] -gt 0 ]
    log.error "'$argv'... FAIL"
    log.error "Expected TRUE, but exit code is NOT 0"
    let _atn_ASSERTIONS_FAILED++
    return 1
  end
  let _atn_ASSERTIONS_PASSED++
  return 0
end

## Asserts a functoin exit code is 1
## @param func_name - Name of the function
function atn.unittest.assert_error
  if [ $argv[1] -eq 0 ]
    log.error "'$argv'... FAIL"
    log.error "Expected FALSE, but exit code is 0"
    let _atn_ASSERTIONS_FAILED++
    return 1
  end
  let _atn_ASSERTIONS_PASSED++
  return 0
end

## Asserts a function output is the same as required
## @param reqvalue - Value to be equals to the output
## @param func_name - Name of the function which result is to be tested
function atn.unittest.assert_equal
  set -l val "$argv[1]"
  shift
  set -l result "$argv[1]"
  if [ "$val" !set   "$result" ]
    log.error "'$argv' equals to '$val'... FAIL"
    log.error "Expected '$val', but it was returned '$result'"
    let _atn_ASSERTIONS_FAILED++
    return 1
  end
  let _atn_ASSERTIONS_PASSED++
  return 0
end

## Asserts a function will raise a given exception
## @param func_name - a string containing the name of the function which will raise an exception
## @param exception - a string containing the exception which should be raise
function atn.unittest.assert_raise
  set -l fired 0
  function catch_exception set fired 1 ; }
  atn.try.do "$argv[1]"
  atn.catch "$argv[2]" catch_exception
  atn.try.end
  if [ $fired -eq 1 ]
    let _atn_ASSERTIONS_PASSED++
  else
    let _atn_ASSERTIONS_FAILED++
    log.error "'$argv[1]' has not raised '$argv[2]' as expected..."
  end
  unset -f catch_exception
end

## Do a double for a function, replacing it codes for the other functions' code
## @param func1 - a string containing the name of the function to be replaced
## @param func2 - a string containing the name of the function which will replace func1
function atn.unittest.double.do
  if is_function? "$argv[1]" ; and is_function? "$argv[2]"
    set -l actualFunc (declare -f "$argv[1]" | sed '1d;2d;$d') \
          set func (declare -f "$argv[2]" | sed '1d;2d;$d') \
          set func_name "$argv[1]"
    atn.set "atn.unittest.doubles.$func_name" "$actualFunc"
    set -l mocks (atn.get atn.unittest.doubles)
    atn.set "atn.unittest.doubles" "$mocks $func_name"
    eval "function $argv[1]
      $func
    }"
  end
end

## Undo the double for the function
## @param func - the string containing the name of the function
function atn.unittest.double.undo
  set -l key "atn.unittest.doubles.$argv[1]"
  if atn.is_set? "$key"
    set -l func_body (atn.get $key)
    eval "function $argv[1]
      $func_body
    }"
    atn.unset "$key"
    set -l mocks (atn.get atn.unittest.doubles)
    atn.set "atn.unittest.doubles" "${mocks//$argv[1]/}"
  end
end

## Turns all doubled functions to its normal behavior
function atn.unittest.double.undo_all
  set IFS " "
  for func_name in (atn.get 'atn.unittest.doubles')
    atn.unittest.double.undo "$func_name"
  end
  unset IFS
end

## Returns a list of loaded test cases
function atn.unittest.find_test_cases
  declare -f | grep '^b\.test\.' | sed 's/ ().*$//'
end

## Execute and return whether a test case was run successfuly
##
## @param test_case - a test case function name
function atn.unittest.run_successfuly?
  set -l test_case "$argv[1]"
  set -l FAILED_ASSERTIONS_BEFORE "$_atn_ASSERTIONS_FAILED"

  is_function? atn.unittest.setup ; and atn.unittest.setup
  $test_case
  atn.unittest.double.undo_all
  is_function? atn.unittest.teardown ; and atn.unittest.teardown

  [ $_atn_ASSERTIONS_FAILED -eq $FAILED_ASSERTIONS_BEFORE ]
end
