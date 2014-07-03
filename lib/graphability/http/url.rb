require 'yaml'

module Graphability::HTTP
  class Url
    attr_reader :url, :original_url

    def initialize(url, opts = {})
      opts = {
          :force => false
      }.merge(opts)

      @original_url = url

      @embedded = false
      @url = opts[:force] ? url.to_s : c14n(url).to_s
    end

    def embedded?
      @embedded
    end

    def valid?
      @url.size > 0 && @url.start_with?('http') && ! ["127.0.0.1", "localhost", "0.0.0.0"].any? { |expr| @url.include?(expr) }
    end

    def canonical
      @canonical ||= @url.downcase.gsub("://www.", "://").gsub("https:","http:")
    end

    def domain
      @domain ||= begin
        host = Addressable::URI.parse(url).host
        host.gsub!("www.","")
        host
      end
    end

    def domain_url
      @domain_url ||= begin
        host = Addressable::URI.parse(url).host
        "http://#{host}"
      end
    end

    def handicap
      @handicap ||= begin
        handicap = 0
        handicap -= 5 unless valid?
        %w(? # feed rss proxy /mobile. /m.).each { |expression| handicap -= 1 if @url.include?(expression) }
        handicap
      end
    end

    private
    c14ndb_ = YAML.load_file(File.join(File.dirname(__FILE__), '/c14n.yml'))

    C14N_ = {}
    C14N_[:global] = c14ndb_[:all].freeze
    C14N_[:global_values] = c14ndb_[:values].map { |v| v.split('=') }.freeze
    C14N_[:hosts] = c14ndb_[:hosts].inject({}) { |h, (k, v)| h[/#{Regexp.escape(k)}$/.freeze] = v; h }

    def c14n(url)
      return nil if url.to_s.empty?

      begin
        url.chomp!

        u = Addressable::URI.parse(url)

        if u.query_values && embedded_url = (u.query_values["imgrefurl"] || u.query_values["url"])
          if embedded_url.to_s.start_with?('http')
            u = Addressable::URI.parse(embedded_url)
            @embedded = true
          end
        end

        if q = u.query_values(Array)
          q.delete_if { |k, v| C14N_[:global].include?(k) }
          q.delete_if { |k, v| C14N_[:global_values].include?([k, v]) }
          q.delete_if { |k, v| C14N_[:hosts].find { |r, p| u.host =~ r && p.include?(k) } }
        end

        u.query_values = q

        u.fragment = nil

        url = Addressable::URI.unencode(u).to_s.gsub /(https?:\/\/.*?)(:[0-9]+)(\/.*)/, '\1\3' # rm port :80, :8080 ...


        ["?", "/", "#", ":"].each do |car|
          url = url.chop if url.end_with?(car)
        end

        [
            "/default.html",
            "/default.htm",
            "/default.aspx",
            "/default.asp",
            "/index.php",
            "/index.html",
            "/index.htm",
            "/index.aspx",
            "/index.asp"
        ].each do |eof|
          url.gsub(/(.*?)#{eof}$/, '\1')
        end

        url.gsub!('https', 'http')

      rescue Exception => e
        log.error ["UrlCleaner : Error on c18n #{url}", e.message].join("\n")
      end

      url
    end
  end
end