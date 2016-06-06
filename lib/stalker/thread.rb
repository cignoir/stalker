require 'open-uri'

module Stalker
  class Thread
    class << self
      def find(search_word, escape = true)
        search_word = URI.escape(search_word) if escape
        doc = Nokogiri::HTML.parse(open(Stalker::Config::REFIND_2CH_BASE + search_word).read)
        doc.css('.thread_url').map{ |node| node.attributes['href'].text }
      end
    end

    attr_accessor :url, :proxy_url, :title, :uuid

    def initialize(url)
      @url = url
      @proxy_url = Stalker::Config::PROXY_BASE + @url
      @uuid = SecureRandom.uuid
    end

    def parse
      doc = Nokogiri::HTML.parse(open(@proxy_url, "r:#{Stalker::Config::INPUT_ENCODING}").read)
      @title = doc.xpath('//h1[@class="title"]').inner_text.encode(Stalker::Config::OUTPUT_ENCODING)

      doc.xpath('//div[@class="post"]').map do |node|
        post = Post.new(thread_uuid = @uuid)

        # date
        div_date = node.xpath('div[@class="date"]').inner_text.encode(Stalker::Config::OUTPUT_ENCODING)
        if /(?<year>\d{4})\/(?<month>\d{2})\/(?<date>\d{2}).+?\s(?<time>\d{2}:\d{2}:\d{2}\..{0,3}).+?ID:(?<user_id>.+)/ =~ div_date
          post.posted_at = DateTime.parse("#{year}-#{month}-#{date}T#{time}+09:00").strftime('%Y-%m-%d %H:%M:%S.%3N')
          post.user_id = user_id
        end

        # number
        div_number = node.xpath('div[@class="number"]').inner_text.encode(Stalker::Config::OUTPUT_ENCODING)
        if /(?<number>\d{1,4}).*/ =~ div_number
          post.number = number.to_i
        end

        # name
        post.name = node.xpath('div[@class="name"]').inner_text.encode(Stalker::Config::OUTPUT_ENCODING)

        # message
        post.message = node.xpath('div[@class="message"]').inner_text.encode(Stalker::Config::OUTPUT_ENCODING)

        post
      end
    end
  end
end