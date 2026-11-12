require "net/http"
require "resolv"
require "ipaddr"

# Fetches a user-supplied URL, refusing anything that points at the local network.
# The connection is pinned to the address that was checked, so DNS can't change its answer in between.
module RemoteFetch
  class Refused < StandardError; end

  MAX_BYTES = 15.megabytes
  HEADERS = { "User-Agent" => "Mozilla/5.0 (compatible; Mise)", "Accept" => "text/html,image/*" }.freeze
  # Not covered by IPAddr#private?: "this host" (0.0.0.0 reaches localhost on Linux), carrier-grade NAT (Tailscale), IPv6 unspecified.
  EXTRA_BLOCKED = %w[0.0.0.0/8 100.64.0.0/10 ::/128].map { |range| IPAddr.new(range) }.freeze

  def self.get(url, redirects: 3)
    uri = parse(url)
    raise Refused, "That doesn't look like a web address." unless uri.is_a?(URI::HTTP) && uri.host

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.ipaddr = public_address_for(uri.hostname)
    http.open_timeout = 10
    http.read_timeout = 15

    response = http.start { |connection| connection.request(Net::HTTP::Get.new(uri.request_uri, HEADERS)) { |res| read_limited(res) } }

    case response
    when Net::HTTPRedirection
      raise Refused, "Too many redirects." if redirects.zero?
      get(URI.join(uri, response["location"]).to_s, redirects: redirects - 1)
    when Net::HTTPSuccess then response
    else raise Refused, "The site returned #{response.code}."
    end
  end

  def self.parse(url)
    URI.parse(url.to_s.strip)
  rescue URI::InvalidURIError
    raise Refused, "That doesn't look like a web address."
  end
  private_class_method :parse

  def self.internal?(address)
    ip = IPAddr.new(address)
    ip = ip.native if ip.ipv4_mapped?
    ip.private? || ip.loopback? || ip.link_local? || EXTRA_BLOCKED.any? { |range| range.include?(ip) }
  end

  def self.public_address_for(host)
    addresses = Resolv.getaddresses(host)
    raise Refused, "That address couldn't be found." if addresses.empty?
    raise Refused, "That address isn't allowed." if addresses.any? { |address| internal?(address) }

    addresses.min_by { |address| address.include?(":") ? 1 : 0 } # prefer IPv4
  end

  def self.read_limited(response)
    return unless response.is_a?(Net::HTTPSuccess)

    body = +""
    response.read_body do |chunk|
      body << chunk
      raise Refused, "That file is too big." if body.bytesize > MAX_BYTES
    end
    response.body = body
  end
  private_class_method :read_limited
end
