require 'helper'
require 'json'
require 'yaml'

class TestSauce < Test::Unit::TestCase
  context "A V1 jobs instance" do
    setup do
      # Create this file and put in your details to run the tests
      account = YAML.load_file "account.yml"
      @username = account["username"]
      @access_key = account["access_key"]
      @ip = account["ip"]
      @client = Sauce::Client.new(:username => @username,
                                  :access_key => @access_key,
                                  :protocol => account["protocol"],
                                  :host => account["host"],
                                  :port => account["port"],
                                  :api_path => account["api_path"],
                                  :api_version => account["api_version"])

      #@example_data = YAML.load_file('example_data.yml')
    end

=begin
    should "initialize with passed variables" do
      client = Sauce::Client.new(:username => "test_user",
                                 :access_key => "abc123")
      
      job = client.jobs.new(JSON.parse(@example_data["example_job"]))

      assert_equal "501aca56282545a9a21ad2fc592b03fa", job.id
      assert_equal "joe", job.owner
      assert_equal "complete", job.status
      assert_equal "job-example-fixture", job.name 

      assert_equal "firefox", job.browser
      assert_equal "3.5.", job.browser_version
      assert_equal "Windows 2003", job.os

      assert_equal 1253856281, job.creation_time
      assert_equal 1253856366, job.start_time
      assert_equal 1253856465, job.end_time 

      assert_equal "http://saucelabs.com/video/8b6bf8d360cc338cc7cf7f6e093264d0/video.flv", job.video_url
      assert_equal "http://saucelabs.com/video/8b6bf8d360cc338cc7cf7f6e093264d0/selenium-server.log", job.log_url

      assert_equal false, job.public
      assert_equal ["test", "example", "python_is_fun"], job.tags
    end
=end

    # Note: Relies on server-side data fixture
    should "retrieve and parse a job via the api" do
      job = @client.jobs.find("gem-test-job")

      assert_equal "gem-test-job", job.id
      assert_equal "sah", job.owner
      assert_equal "complete", job.status
      assert_equal "job-example-fixture", job.name

      assert_equal "firefox", job.browser
      assert_equal "3.5.", job.browser_version
      assert_equal "Windows 2003", job.os

      assert_equal 1266030817, job.creation_time
      assert_equal 1266030833, job.start_time
      assert_equal 1266030871, job.end_time 

      assert_equal "http://saucelabs.com/jobs/gem-test-job/video.flv", job.video_url
      assert_equal "http://saucelabs.com/jobs/gem-test-job/selenium-server.log", job.log_url

      assert_equal false, job.public
      assert_equal ['test', 'equal', 'multilingualism_is_fun'], job.tags
    end

    should "update writable properties" do
      job = @client.jobs.find("gem-test-job")

      # Make sure it's in the expected condition before changing
      assert_equal false, job.public
      assert_equal ["test", "example", "multilingualism_is_fun"], job.tags
      assert_equal "job-example-fixture", job.name

      job.public = true
      job.tags = ["changed", "updated", "ruby_is_also_fun"]
      job.name = "changed-job-name", job.name
      job.save

      # Fresh copy of the same job
      job2 = @client.jobs.find("gem-test-job")

      assert_equal true, job2.public
      assert_equal ["changed", "updated", "ruby_is_also_fun"], job2.tags
      assert_equal "changed-job-name", job2.name

      # Return the job to its original state and check it out
      job.public = false
      job.tags = ["test", "example", "multilingualism_is_fun"]
      job.name = "job-example-fixture", job.name
      job.save

      # Check to see if the change took
      job2.refresh!
      assert_equal job.public, job2.public
      assert_equal job.tags, job2.tags
      assert_equal job.name, job2.name
    end

    should "not update read-only properties" do
      job = @client.jobs.find("gem-test-job")

      # Make sure it's in the expected condition before changing
      assert_equal "complete", job.status
      assert_equal "sah", job.owner
      assert_equal "Windows 2003", job.os

      job.status = "groggy"
      job.owner = "sjobs"
      job.os = "darwin" # In a perfect world...
      assert_equal "groggy", job.status
      assert_equal "sjobs", job.owner
      assert_equal "darwin", job.os
      job.save

      # Changes should go away when refreshed
      job.refresh!
      assert_equal "complete", job.status
      assert_equal "sah", job.owner
      assert_equal "Windows 2003", job.os
    end

    should "list the 100 most recent jobs" do
      jobs = @client.jobs.all

      assert_equal 2, jobs.count
    end

    should "show the full job information on index if requested" do
      flunk "TODO: implement this"
    end

    def teardown
    end
  end
end
