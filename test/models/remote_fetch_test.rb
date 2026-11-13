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


  # A tiny web server on this machine. RemoteFetch refuses local addresses on purpose, so the address check is stubbed here
  # to let the fetching itself (redirects, errors, size limits) be tested for real.
  def serve(routes)
    server = TCPServer.new("127.0.0.1", 0)
    thread = Thread.new do
      loop do
        client = server.accept
        path = client.gets.to_s.split[1]
        while (line = client.gets) && line != "\r\n"; end
        status, headers, body = routes.fetch(path, [ 404, {}, "not here" ])
        client.write("HTTP/1.1 #{status} Status\r\n#{headers.map { |name, value| "#{name}: #{value}\r\n" }.join}Content-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
        client.close
      end
    rescue IOError, Errno::EBADF
      nil
    end
    RemoteFetch.stub(:public_address_for, "127.0.0.1") { yield "http://example.test:#{server.addr[1]}" }
  ensure
    thread&.kill
    server&.close
  end

  test "a page is fetched and its body returned" do
    serve("/page" => [ 200, { "Content-Type" => "text/html" }, "<p>hello</p>" ]) do |base|
      response = RemoteFetch.get("#{base}/page")
      assert_equal "<p>hello</p>", response.body
    end
  end

  test "redirects are followed, including relative ones" do
    serve("/start" => [ 302, { "Location" => "/middle" }, "" ], "/middle" => [ 301, { "Location" => "/end" }, "" ], "/end" => [ 200, {}, "arrived" ]) do |base|
      assert_equal "arrived", RemoteFetch.get("#{base}/start").body
    end
  end

  test "too many redirects are refused" do
    serve("/a" => [ 302, { "Location" => "/b" }, "" ], "/b" => [ 302, { "Location" => "/c" }, "" ], "/c" => [ 302, { "Location" => "/d" }, "" ],
          "/d" => [ 302, { "Location" => "/e" }, "" ], "/e" => [ 200, {}, "too far" ]) do |base|
      error = assert_raises(RemoteFetch::Refused) { RemoteFetch.get("#{base}/a") }
      assert_match(/Too many redirects/, error.message)
    end
  end

  test "an error page is refused with its status" do
    serve({}) do |base|
      error = assert_raises(RemoteFetch::Refused) { RemoteFetch.get("#{base}/missing") }
      assert_match(/returned 404/, error.message)
    end
  end

  test "a file bigger than the limit is refused" do
    serve("/huge" => [ 200, {}, "x" * (RemoteFetch::MAX_BYTES + 1) ]) do |base|
      error = assert_raises(RemoteFetch::Refused) { RemoteFetch.get("#{base}/huge") }
      assert_match(/too big/, error.message)
    end
  end

  test "a name that doesn't exist is refused" do
    Resolv.stub(:getaddresses, []) do
      assert_raises(RemoteFetch::Refused) { RemoteFetch.get("http://nothing.invalid/") }
    end
  end

  test "a name that points at an internal address is refused, even if it also has a public one" do
    Resolv.stub(:getaddresses, [ "93.184.216.34", "10.0.0.5" ]) do
      error = assert_raises(RemoteFetch::Refused) { RemoteFetch.get("http://sneaky.example/") }
      assert_match(/isn't allowed/, error.message)
    end
  end

  test "a public name resolves to its IPv4 address first" do
    Resolv.stub(:getaddresses, [ "2606:4700:4700::1111", "1.1.1.1" ]) do
      assert_equal "1.1.1.1", RemoteFetch.public_address_for("one.one.one.one")
    end
  end
end
