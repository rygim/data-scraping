#!/usr/bin/env bash


### By default, this script will download 10 pages worth of data.  Add a parameter number to download that many pages

NUM_PAGES=${1:-10}

for page in $(seq 1 $NUM_PAGES) 
do
  curl http://www.textsfromlastnight.com/texts/page:$page 2> /dev/null | pup div.content json{} | jq -c '.[] | { areacode: .children[0].children[0].text, data: .children[1].children[0].text }' | grep -v '{"areacode":null,"data":null}' | sed -e 's/"areacode":"(/"areacode":"/' -e 's/):","data"/","data"/g'
done
