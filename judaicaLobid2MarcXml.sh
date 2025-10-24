# description:
# Gets all data concerning judaica from lobid-resources.
# Extracts all alma IDs from the roughly 5k documents.
# Lookup every one of these alma IDs to get the MARC-XML data.
# Write those single MARC-XML data lookups into one valid XML file.
#
# duration (Laptop from 2017):
# - 13s to get lobid data
# - 70s extract alma IDs
# - 14m get 5k MARC XML
#
# preconditions:
# apt install jq

IFS="
";

FILE_LOBID=lobidData.jsonl.gz
FILE_ALMAID=almaId.csv
FILE_MARCXML=lobid2Judaica.mrc.xml

echo '<?xml version="1.0" encoding="UTF-8"?>' > $FILE_MARCXML
echo "<records>" >> $FILE_MARCXML

function getLobiddata(){
echo "Start getLobiddata :$(date)"
  curl --header "Accept: application/x-jsonlines" --header "Accept-Encoding: gzip" "https://lobid.org/resources/search?q=subject.id%3A%28%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N630100%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N631000%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N632000%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N632050%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N635000%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N636000%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N637000%22+OR+%22https%3A%2F%2Fnwbib.de%2Fsubjects%23N638000%22%29" > $FILE_LOBID
echo "Ende Laden lobid Daten: $(date)"
}

function extractAlmaId(){
echo "Start extractAlmaId :$(date)"
  rm $FILE_ALMAID
  for i in $(zcat $FILE_LOBID);
    do echo "$i"|jq .almaMmsId |tr -d '"' >> $FILE_ALMAID
  done
echo "Ende extrahieren alma IDs: $(date)"
}

function getMarcXml(){
echo "Start getMarcXml :$(date)"
  for i in $(cat $FILE_ALMAID);
    do curl  --silent "https://lobid.org/marcxml/$i" >> $FILE_MARCXML
       echo "" >> $FILE_MARCXML
  done
  echo "</records>" >>  $FILE_MARCXML
echo "Ende getMarcXml: $(date)"
}


getLobiddata
extractAlmaId
getMarcXml
