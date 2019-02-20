## This Service is takes a url an array of media types on initialization
# It then parses the html page at the provided URL and scrapes out the URLS for each of the assets.
class AssetScrapeService
  require 'open-uri'
  require 'uri'
  require 'mimemagic'

  ASSET_TAGS = %w( img video svg script link ).join(', ')

  def initialize params
    @url = params[:url] #page to be scraped
  end

  def call!
    return nil unless self.valid?
    parse_page
  end

  def valid?
    return false if validate_url(@url).nil?
    true
  end

  private

  def parse_page
    begin
      page = Nokogiri::HTML(open(@url)) #open page with Nokogiri
    rescue
      return nil
    end
    process_tags(page.search(ASSET_TAGS))
  end

  def process_tags tags
    results = []
    tags.each do |tag|
      url = process_tag_url tag
      unless url.blank? || validate_url(url).nil?
        name = extract_name url
        mime_type = extract_mime_type name
        unless name.nil? || mime_type.nil?
          results << {name: name, url: url, mime_type: mime_type}
        end
      end
    end
    results
  end

  def process_tag_url tag
    case tag.name.downcase
      when 'video' #video
        url = extract_url_from_source tag
      else
        url = extract_url tag
    end
    url
  end

  def extract_url tag
    url = tag['src'] || tag['href']
    prepend_url url
  end

  def extract_url_from_source tag
    url = tag['src'] ||
        tag.search('source[type="video/mp4"]').first.try(:[], 'src') #for the purposes of the sample I only care about mp4s for video
    prepend_url url
  end

  def prepend_url url
    return nil if url.nil?
    url = url.prepend('https:') if url.start_with? '//' #if protocol not specified use https
    url = url.prepend(@url) if url.start_with? '/' #if relative url prepend url
    url
  end

  def extract_name url
    uri = URI.parse(url)
    File.basename(uri.path)
  end

  def validate_url url
    url = URI.parse(url) rescue false
    unless url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
      return nil
    end
    true
  end

  def extract_mime_type name
    mime_type = MimeMagic.by_path(name)
    return nil if mime_type.nil?
    mime_type.type
  end

end