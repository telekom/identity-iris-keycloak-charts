TEMPLATE_NAME=iris

# --- generic code below this line ---
RED=31m
GREEN=32m
ZERO=0m

function usage() {
  echo ""
  echo "USAGE:"
  echo "  $0                : run all tests"
  echo "  $0 -l             : list available tests"
  echo "  $0 -v reference   : run the test 'reference'. print diff to expected result"
  echo ""
}

function executeHelm() {
  local test="$1"
  helm template . --name-template $TEMPLATE_NAME -f ./regression-test/data/${test}/values.yaml --dry-run --set global.domain=lab.tardis.telekom.de -n default > result.yaml 2> stderr.txt
}

function listAvailableTests() {
  echo ""
  echo "Available tests:"
  for test in $(ls regression-test/data/); do
    echo -e "  ${test}\t(dir './regression-test/data/${test}/')"
  done
  echo ""
}

function runTest() {
  local test="$1"

  executeHelm "$test"
  ret_code="$?"

  if [ $ret_code -eq 0 ]; then
    # compare result.yaml and expected.yaml
    sanitizeResult "$test"

    lines=$(diff result.yaml ./regression-test/data/${test}/expected.yaml | wc -l)
    if [ $lines -eq 0 ]; then
      printSuccess "$test"
    elif [ $showDetails ]; then
      printDiff "$test" "result.yaml" "expected.yaml"
    else
      printError "$test"
    fi
  elif [ -f ./regression-test/data/${test}/expected-stderr.txt ]; then
    # error was expected. compare stderr
    lines=$(diff stderr.txt ./regression-test/data/${test}/expected-stderr.txt | wc -l)
    if [ $lines -eq 0 ]; then
      printExpectedError "$test"
    elif [ $showDetails ]; then
      printDiff "$test" "stderr.yaml" "expected-stderr.yaml"
    else
      printUnexpectedError "$test"
    fi
  else
    # unexpected error
    echo -e "\e[${RED}${test} failed with unexpected test failure\e[${ZERO}"
    cat stderr.txt
    rm -f stderr.txt
  fi
  rm -f result.yaml stderr.txt
}

function sanitizeResult() {
  local test="$1"
  if [ -f ./regression-test/data/${test}/sanitize.txt ]; then
    sed -if ./regression-test/data/${test}/sanitize.txt result.yaml
  fi
}

function printSuccess() {
  local test="$1"
  echo -e "Test '${test}': \e[${GREEN}succeeded\e[${ZERO}"
}

function printError() {
  local test="$1"
  echo -e "Test '${test}': \e[${RED}failed with diff of $lines lines\e[${ZERO} (for details execute $0 -v ${test})"
}

function printExpectedError() {
  local test="$1"
  echo -e "Test '${test}': \e[${GREEN}failed with expected result\e[${ZERO}"
}

function printUnexpectedError() {
  local test="$1"
  echo -e "Test '${test}': \e[${RED}failed with unexpected error\e[${ZERO}"
  cat stderr.txt
}

function printDiff() {
  local test="$1"
  local result="$2"
  local backup="TEST-${test}-$result"
  local expected="./regression-test/data/${test}/$3"

  # save for later...
  mv "$result" "$backup"
  echo "diff ${backup} ${expected}"
  diff "${backup}" "${expected}" | less
}

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  usage
elif [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
  listAvailableTests
else
  showDetails=""
  [ $# -gt 0 ] && [ "$1" == "-v" ] && showDetails=true && shift

  selectedTests="$(ls regression-test/data/)"
  [ $# -eq 0 ] || selectedTests="$@"

  echo -e "Running regression tests"
  for test in $selectedTests; do
    runTest "${test}"
  done
  echo -e "Done."
fi

