# Azure Search output plugin for Fluentd

fluent-plugin-azuresearch is a fluent plugin to output to Azure Search

## Installation

    $ gem install fluent-plugin-azuresearch

## Configuration

### Azure Search

To use Microsoft Azure Search, you must create an Azure Search service in the Azure Portal. Also you must have an index, persisted storage of documents to which fluent-plugin-azuresearch writes event stream out. Here are instructions:

 * [Create a service](https://azure.microsoft.com/en-us/documentation/articles/search-create-service-portal/)
 * [Create an index](https://azure.microsoft.com/en-us/documentation/articles/search-what-is-an-index/)


### Fluentd - fluent.conf

    <match azuresearch.*>
        @type azuresearch
        @log_level info
        endpoint   https://AZURE_SEARCH_ACCOUNT.search.windows.net
        api_key    AZURE_SEARCH_API_KEY
        search_index  messages
        column_names id,user_name,message,tag,created_at
        key_names postid,user,content,tag,posttime
    </match>
  
 * **endpoint (required)** - Azure Search service endpoint URI
 * **api\_key (required)** - Azure Search API key
 * **search\_index (required)** - Azure Search Index name to insert records
 * **column\_names (required)** - Column names in a target Azure search index. Each column needs to be separated by a comma.
 * **key\_names (optional)** - Default:nil. Key names in incomming record to insert. Each key needs to be separated by a comma. ${time} is placeholder for Time.at(time).strftime("%Y-%m-%dT%H:%M:%SZ"), and ${tag} is placeholder for tag. By default, **key\_names** is as same as **column\_names**

[note] @log_level is a fluentd built-in parameter (optional) that controls verbosity of logging: fatal|error|warn|info|debug|trace (See also [Logging of Fluentd](http://docs.fluentd.org/articles/logging#log-level)) 

## Sample Configurations
### Case1 - column_names is as same as key_names 

Suppose you have the following fluent.conf and azure search index schema:

<u>fluent.conf</u>

    <match azuresearch.*>
        @type azuresearch
        endpoint   https://yoichidemo.search.windows.net
        api_key    2XX3D2456052A9AD21E54CB03C3ABF6A(dummy)
        search_index  messages
        column_names id,user_name,message,created_at
    </match>

<u>Azure Search Schema: messages</u>

    {
        "name": "messages",
        "fields": [
            { "name":"id", "type":"Edm.String", "key": true, "searchable": false },
            { "name":"user_name", "type":"Edm.String" },
            { "name":"message", "type":"Edm.String", "filterable":false, "sortable":false, "facetable":false, "analyzer":"en.lucene" },
            { "name":"created_at", "type":"Edm.DateTimeOffset", "facetable":false}
        ]
    }

The plugin will write event stream out to Azure Ssearch like this:

<u>Input event stream</u>

    { "id": "1", "user_name": "taylorswift13", "message":"post by taylorswift13", "created_at":"2016-01-29T00:00:00Z" },
    { "id": "2", "user_name": "katyperry", "message":"post by katyperry", "created_at":"2016-01-30T00:00:00Z" },
    { "id": "3", "user_name": "ladygaga", "message":"post by ladygaga", "created_at":"2016-01-31T00:00:00Z" }


<u>Search results</u>

    "value": [
        { "@search.score": 1, "id": "1", "user_name": "taylorswift13", "message": "post by taylorswift13", "created_at": "2016-01-29T00:00:00Z" },
        { "@search.score": 1, "id": "2", "user_name": "katyperry", "message": "post by katyperry", "created_at": "2016-01-30T00:00:00Z" },
        { "@search.score": 1, "id": "3", "user_name": "ladygaga", "message": "post by ladygaga", "created_at": "2016-01-31T00:00:00Z" }
    ]


### Case2 - column_names is NOT as same as key_names

Suppose you have the following fluent.conf and azure search index schema:

<u>fluent.conf</u>

    <match azuresearch.*>
        @type azuresearch
        endpoint   https://yoichidemo.search.windows.net
        api_key    2XX3D2456052A9AD21E54CB03C3ABF6A(dummy)
        search_index  messages
        column_names id,user_name,message,created_at
        key_names postid,user,content,posttime
    </match>

<u>Azure Search Schema: messages</u>

    {
        "name": "messages",
        "fields": [
            { "name":"id", "type":"Edm.String", "key": true, "searchable": false },
            { "name":"user_name", "type":"Edm.String" },
            { "name":"message", "type":"Edm.String", "filterable":false, "sortable":false, "facetable":false, "analyzer":"en.lucene" },
            { "name":"created_at", "type":"Edm.DateTimeOffset", "facetable":false}
        ]
    }

The plugin will write event stream out to Azure Ssearch like this:

<u>Input event stream</u>

    { "postid": "1", "user": "taylorswift13", "content":"post by taylorswift13", "posttime":"2016-01-29T00:00:00Z" },
    { "postid": "2", "user": "katyperry", "content":"post by katyperry", "posttime":"2016-01-30T00:00:00Z" },
    { "postid": "3", "user": "ladygaga", "content":"post by ladygaga", "posttime":"2016-01-31T00:00:00Z" }


<u>Search results</u>

    "value": [
        { "@search.score": 1, "id": "1", "user_name": "taylorswift13", "message": "post by taylorswift13", "created_at": "2016-01-29T00:00:00Z" },
        { "@search.score": 1, "id": "2", "user_name": "katyperry", "message": "post by katyperry", "created_at": "2016-01-30T00:00:00Z" },
        { "@search.score": 1, "id": "3", "user_name": "ladygaga", "message": "post by ladygaga", "created_at": "2016-01-31T00:00:00Z" }
    ]


### Case3 - column_names is NOT as same as key_names, Plus, key_names includes ${time} and ${tag}

<u>fluent.conf</u>

    <match azuresearch.*>
        @type azuresearch
        endpoint   https://yoichidemo.search.windows.net
        api_key    2XX3D2456052A9AD21E54CB03C3ABF6A(dummy)
        search_index  messages
        column_names id,user_name,message,tag,created_at
        key_names postid,user,content,${tag},${time}
    </match>

<u>Azure Search Schema: messages</u>

    {
        "name": "messages",
        "fields": [
            { "name":"id", "type":"Edm.String", "key": true, "searchable": false },
            { "name":"user_name", "type":"Edm.String" },
            { "name":"message", "type":"Edm.String", "filterable":false, "sortable":false, "facetable":false, "analyzer":"en.lucene" },
            { "name":"created_at", "type":"Edm.DateTimeOffset", "facetable":false}
        ]
    }

The plugin will write event stream out to Azure Ssearch like this:

<u>Input event stream</u>

    { "id": "1", "user_name": "taylorswift13", "message":"post by taylorswift13" },
    { "id": "2", "user_name": "katyperry", "message":"post by katyperry" },
    { "id": "3", "user_name": "ladygaga", "message":"post by ladygaga" }

<u>Search results</u>

    "value": [
        { "@search.score": 1, "id": "1", "user_name": "taylorswift13", "message": "post by taylorswift13", "tag": "azuresearch.msg", "created_at": "2016-01-31T21:03:41Z" },
        { "@search.score": 1, "id": "2", "user_name": "katyperry", "message": "post by katyperry", "tag": "azuresearch.msg", "created_at": "2016-01-31T21:03:41Z" },
        { "@search.score": 1, "id": "3", "user_name": "ladygaga", "message": "post by ladygaga", "tag": "azuresearch.msg", "created_at": "2016-01-31T21:03:41Z" }
    ]
[note] the value of created_at above is the time when fluentd actually recieves its corresponding input event.


## Tests
### Running test code
    $ git clone https://github.com/yokawasa/fluent-plugin-azuresearch.git
    $ cd fluent-plugin-azuresearch
    
    # edit CONFIG params of test/plugin/test_azuresearch.rb 
    $ vi test/plugin/test_azuresearch.rb
    
    # run test 
    $ rake test

### Creating package, running and testing locally 
    $ rake build
    $ rake install:local
     
    # running fluentd with your fluent.conf
    $ fluentd -c fluent.conf -vv &
     
    # send test input event to test plugin using fluent-cat
    $ echo ' { "postid": "100", "user": "ladygaga", "content":"post by ladygaga"}' | fluent-cat azuresearch.msg

Please don't forget that you need forward input configuration to receive the message from fluent-cat

    <source>
        @type forward
    </source>


## TODOs
 * Input validation for Azure Search - check total size of columns to add 

## Change log
* [Changelog](ChangeLog.md)

## Links

* http://yokawasa.github.io/fluent-plugin-azuresearch
* https://rubygems.org/gems/fluent-plugin-azuresearch

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yokawasa/fluent-plugin-azuresearch.

## Copyright

<table>
  <tr>
    <td>Copyright</td><td>Copyright (c) 2016- Yoichi Kawasaki</td>
  </tr>
  <tr>
    <td>License</td><td>Apache License, Version 2.0</td>
  </tr>
</table>

