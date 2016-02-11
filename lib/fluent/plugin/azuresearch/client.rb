module Fluent
  module AzureSearch
    class Client

        def initialize (api_url, api_key, api_version="2015-02-28")
            require 'rest-client'
            require 'json'
            @api_url = api_url
            @api_version = api_version
            @headers = {
                'Content-Type' => "application/json; charset=UTF-8",
                'Api-Key' => api_key,
                'Accept' => "application/json",
                'Accept-Charset' => "UTF-8"
            }
        end 

        def add_documents(index_name, documents, merge=true)
            raise ConfigError, 'no index_name' if index_name.empty?
            raise ConfigError, 'no documents' if documents.empty?
            action = merge ? 'mergeOrUpload' : 'upload' 
            for document in documents
                document['@search.action'] = action
            end
            req_body =  { :value => documents }.to_json
           # p "REQ_BODY= #{req_body}"
           # p "URI= #{@api_url}/indexes/#{index_name}/docs/index?api-version=#{@api_version}"
            res = RestClient.post(
                "#{@api_url}/indexes/#{index_name}/docs/index?api-version=#{@api_version}",
                req_body,
                @headers)
            res
        end

    end
  end
end

