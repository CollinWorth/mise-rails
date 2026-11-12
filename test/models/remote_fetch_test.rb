require "test_helper"

class RemoteFetchTest < ActiveSupport::TestCase
  test "addresses on this machine or the local network are internal" do
    %w[127.0.0.1 0.0.0.0 10.0.0.5 192.168.1.20 172.16.0.1 169.254.169.254 100.64.0.5 100.100.100.100 ::1 ::].each do |address|
      assert RemoteFetch.internal?(address), "#{address} should be internal"
    end
    assert RemoteFetch.internal?("::ffff:127.0.0.1")
  end

  test "public addresses are allowed" do
    %w[8.8.8.8 1.1.1.1 93.184.216.34 2606:4700:4700::1111].each do |address|
      assert_not RemoteFetch.internal?(address), "#{address} should be public"
    end
  end

  test "get refuses internal hosts and non-web addresses before connecting" do
    [ "http://0.0.0.0:3000/", "http://127.0.0.1/", "http://localhost/", "http://100.100.100.100/", "http://[::1]/" ].each do |url|
      assert_raises(RemoteFetch::Refused, url) { RemoteFetch.get(url) }
    end
    assert_raises(RemoteFetch::Refused) { RemoteFetch.get("ftp://example.com/file") }
    assert_raises(RemoteFetch::Refused) { RemoteFetch.get("not a url") }
  end
end
