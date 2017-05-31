require 'helper'

class AzureSearchOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    endpoint https://AZURE_SEARCH_ACCOUNT.search.windows.net
    api_key AZURE_SEARCH_API_KEY
    search_index  messages
    column_names id,user_name,message,tag,created_at
    key_names postid,user,content,tag,posttime
  ]
  # CONFIG = %[
  #   path #{TMP_DIR}/out_file_test
  #   compress gz
  #   utc
  # ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::AzureSearchOutput).configure(conf)
  end

  def test_configure
    d = create_driver

    assert_equal 'https://AZURE_SEARCH_ACCOUNT.search.windows.net', d.instance.endpoint
    assert_equal 'AZURE_SEARCH_API_KEY', d.instance.api_key
    assert_equal 'messages', d.instance.search_index
    assert_equal ["id", "user_name", "message", "tag", "created_at"], d.instance.column_names
  end

  def test_format
    d = create_driver

    time = event_time("2011-01-02 13:14:15 UTC")
    d.run(default_tag: 'documentdb.test') do
      d.feed(time, {"a"=>1})
      d.feed(time, {"a"=>2})
    end

    # assert_equal EXPECTED1, d.formatted[0]
    # assert_equal EXPECTED2, d.formatted[1]
  end

  def test_write
    d = create_driver

    time = event_time("2016-01-28 13:14:15 UTC")
    data = d.run(default_tag: 'azuresearch.test') do
      d.feed(
          time,
          {
              "postid" => "10001",
              "user"=> "ladygaga",
              "content" => "post by ladygaga",
              "tag" => "azuresearch.msg",
              "posttime" =>"2016-01-31T00:00:00Z"
          })

      d.feed(
          time,
          {
              "postid" => "10002",
              "user"=> "katyperry",
              "content" => "post by katyperry",
              "tag" => "azuresearch.msg",
              "posttime" => "2016-01-31T00:00:00Z"
          })
    end
    puts data
    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end
end
