# -*- coding: utf-8 -*-

require 'fluent/plugin/output'

module Fluent::Plugin
  class AzureSearchOutput < Output
    Fluent::Plugin.register_output('azuresearch', self)

    helpers :compat_parameters

    DEFAULT_BUFFER_TYPE = "memory"

    unless method_defined?(:log)
        define_method('log') { $log }
    end

    def initialize
        super
        require 'msgpack'
        require 'time'
        require 'fluent/plugin/azuresearch/client'
    end

    config_param :endpoint, :string,
                 :desc => "Azure Search Endpoint URL"
    config_param :api_key, :string, :secret => true,
                 :desc => "Azure Search API key"
    config_param :search_index, :string,
                 :desc => "Azure Search Index name to insert records"
    config_param :column_names, :string,
                 :desc => "Column names in a target Azure search index (comman separated)"
    config_param :key_names, :string, default: nil,
                 :desc => <<-DESC
Key names in incomming record to insert (comman separated).
${time} is placeholder for Time.at(time).strftime("%Y-%m-%dT%H:%M:%SZ"),
and ${tag} is placeholder for tag
DESC

    config_section :buffer do
        config_set_default :@type, DEFAULT_BUFFER_TYPE
        config_set_default :chunk_keys, ['tag']
    end

    def configure(conf)
        compat_parameters_convert(conf, :buffer)
        super
        raise Fluent::ConfigError, 'no endpoint' if @endpoint.empty?
        raise Fluent::ConfigError, 'no api_key' if @api_key.empty?
        raise Fluent::ConfigError, 'no search_index' if @search_index.empty?
        raise Fluent::ConfigError, 'no column_names' if @column_names.empty?

        @column_names = @column_names.split(',')
        @key_names = @key_names.nil? ? @column_names : @key_names.split(',')
        raise Fluent::ConfigError, 'NOT match keys number: column_names and key_names' \
                if @key_names.length != @column_names.length
    end

    def start
        super
        # start
        @client=Fluent::AzureSearch::Client::new( @endpoint, @api_key )
    end

    def shutdown
        super
        # destroy
    end

    def format(tag, time, record)
        values = []
        @key_names.each_with_index do |key, i|
            if key == '${time}'
                value = Time.at(time).strftime('%Y-%m-%dT%H:%M:%SZ')
            elsif key == '${tag}'
                value = tag
            else
                value = record.include?(key) ? record[key] : ''
            end
            values << value
        end
        [tag, time, values].to_msgpack
    end

    def formatted_to_msgpack_binary?
        true
    end

    def multi_workers_ready?
        true
    end

    def write(chunk)
        documents = []
        chunk.msgpack_each do |tag, time, values|
            document = {}
            @column_names.each_with_index do|k, i|
                document[k] = values[i]
            end
            documents.push(document)
        end

        begin
            res = @client.add_documents(@search_index, documents)
            puts res
        rescue Exception => ex
            log.fatal "UnknownError: '#{ex}'"
                          + ", data=>" + (documents.to_json).to_s
        end
    end

  end
end
