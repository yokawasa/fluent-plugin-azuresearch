#!/bin/sh

SERVICE_NAME='Azure Search Service Name'
ADMIN_KEY='Azure Search API Admin Key'
API_VER='2015-02-28-Preview'
CONTENT_TYPE='application/json'
URL="https://${SERVICE_NAME}.search.windows.net/indexes?api-version=${API_VER}"

curl -s\
 -H "Content-Type: ${CONTENT_TYPE}"\
 -H "api-key: ${ADMIN_KEY}"\
 -XPOST ${URL} -d'{
    "name": "messages",
    "fields": [
        { "name":"id", "type":"Edm.String", "key": true, "searchable": false },
        { "name":"user_name", "type":"Edm.String" },
        { "name":"message", "type":"Edm.String", "filterable":false, "sortable":false, "facetable":false, "analyzer":"en.lucene" },
        { "name":"created_at", "type":"Edm.DateTimeOffset", "facetable":false}
    ]
}'
