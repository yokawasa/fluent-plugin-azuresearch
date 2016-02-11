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

  def create_driver(conf = CONFIG, tag='azuresearch.test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::AzureSearchOutput, tag).configure(conf)
  end

  def test_configure
    #### set configurations
    # d = create_driver %[
    #   path test_path
    #   compress gz
    # ]
    #### check configurations
    # assert_equal 'test_path', d.instance.path
    # assert_equal :gz, d.instance.compress
  end

  def test_format
    d = create_driver

    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":1}\n]
    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":2}\n]

    # d.run
  end

  def test_write
    d = create_driver

    time = Time.parse("2016-01-28 13:14:15 UTC").to_i
    d.emit(
        {
            "postid" => "10001",
            "user"=> "ladygaga",
            "content" => "post by ladygaga",
            "tag" => "azuresearch.msg",
            "posttime" =>"2016-01-31T00:00:00Z"
        }, time)

    d.emit(
        {
            "postid" => "10002",
            "user"=> "katyperry",
            "content" => "post by katyperry",
            "tag" => "azuresearch.msg",
            "posttime" => "2016-01-31T00:00:00Z"
        }, time)

    data = d.run
    puts data
    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end
end

