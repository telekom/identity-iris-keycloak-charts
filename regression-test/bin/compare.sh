RED=31m
GREEN=32m
ZERO=0m
echo -e "Running regression tests"
for test in $(ls regression-test/data/); do
  echo -e "\tRun test '${test}'"
  helm template . --name-template keycloak -f ./regression-test/data/${test}/values.yaml --dry-run --set global.domain=lab.tif.telekom.de -n default > result.yaml
  lines=$(diff result.yaml ./regression-test/data/${test}/expected.yaml | wc -l)
  if [ $lines -ne 0 ]; then
    echo -e "\t\t\e[${RED}${test} failed with diff of $lines lines\e[${ZERO}"
    mv result.yaml TEST-${test}-result.yaml
    echo -e "\t\tExecute 'diff TEST-${test}-result.yaml ./regression-test/data/${test}/expected.yaml' for details"
  else
    echo -e "\t\t\e[${GREEN}succeeded\e[${ZERO}"
    rm -f result.yaml
  fi
done
echo -e "Done."
