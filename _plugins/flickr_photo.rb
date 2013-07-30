# Flickr Photo Tag
#
# A Jekyll plug-in for embedding a Flickr photo in your Liquid templates.
#
# Usage:
#
#   {% flickr_photo xxxx %}

# Extensively based on Jeremy Benoist's Flickr Photoset plugin:
# https://github.com/j0k3r/jekyll-flickr-photoset

require 'flickraw'
require 'shellwords'

module Jekyll

  class FlickrPhotoTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      params = Shellwords.shellwords markup

      @flickrPhoto       = params[0]
      @galleryType    = params[1] || "orbit"
      @photoThumbnail = params[2] || "Large Square"
      @photoEmbeded   = params[3] || "Medium 640"
      @photoOpened    = params[4] || "Large"
      @video          = params[5] || "Site MP4"
    end

    def render(context)

      flickrConfig = context.registers[:site].config["flickr"]

      galleryType = @galleryType

      if cache_dir = flickrConfig['cache_dir']
        path = File.join(cache_dir, "photo-#{@flickrPhoto}.yml")
        if File.exist?(path)
          photo = YAML::load(File.read(path))
        else
          photo = generate_photo_data(@flickrPhoto, flickrConfig)
          File.open(path, 'w') {|f| f.print(YAML::dump(photo)) }
          photo = YAML::load(File.read(path))
        end
      else
        photo = generate_photo_data(@flickrPhoto, flickrConfig)
      end


      output = "<div class=\"row\">"
      output += "  <div class=\"small-12 small-centered columns\">"
      output += "    <div class=\" flickr-photo-container\"><img class=\"flickr-photo\" src=\"#{photo['urlEmbeded']}\">"
      output += "      <div class=\"flickr-caption show-for-landscape hide-for-small\">\n"
      output += "        <span class=\"orbit-caption-title\">#{photo['title']}</span>\n"
      output += "        <span class=\"right\">\n"
      output += "          <a href=\"#{photo['urlPhotoPage']}\" class=\"ss-icon ss-social-circle\" title=\"View on Flickr\">flickr</a>\n"
      output += "        </span><br>\n"
      output += "        <span class=\"orbit-caption-body\">#{photo['caption']}</span>\n"
      output += "      </div>"
      output += "    </div>"
      output += "  </div>"
      output += "</div>"

      # return content
      output
    end

    def generate_photo_data(flickrPhoto, flickrConfig)

      FlickRaw.api_key       = flickrConfig['api_key']
      FlickRaw.shared_secret = flickrConfig['shared_secret']
      flickr.access_token    = flickrConfig['access_token']
      flickr.access_secret   = flickrConfig['access_secret']

      begin
        flickr.test.login
      rescue Exception => e
        raise "Bad token: #{flickrConfig['access_token']}"
      end

      begin
        photoInfo = flickr.photos.getInfo :photo_id => flickrPhoto
      rescue Exception => e
        raise "Bad photo: #{flickrPhoto}"
      end


      title = photoInfo.title
      id    = photoInfo.id

      urlThumb   = String.new
      urlEmbeded = String.new
      urlOpened  = String.new
      urlVideo   = String.new
      urlPhotoPage = String.new
      caption    = String.new

      sizes = flickr.photos.getSizes(:photo_id => id)

      urlThumb       = sizes.find {|s| s.label == @photoThumbnail }
      urlEmbeded     = sizes.find {|s| s.label == @photoEmbeded }
      urlOpened      = sizes.find {|s| s.label == @photoOpened }
      urlVideo       = sizes.find {|s| s.label == @video }
      urlPhotoPage   = photoInfo.urls.find {|u| u.type == 'photopage'}
      caption        = photoInfo['description']


      photo = FlickrPhotoNeue.new(id, title, caption, urlThumb, urlEmbeded, urlOpened, urlVideo, urlPhotoPage.to_s)

      photo
    end
  end

  class FlickrPhotoNeue
    attr_accessor :id, :title, :caption, :urlThumb, :urlEmbeded, :urlOpened, :urlVideo, :urlFlickr, :urlPhotoPage

    def initialize(id, title, caption, urlThumb, urlEmbeded, urlOpened, urlVideo, urlPhotoPage)
      @title      = title
      @urlThumb   = urlThumb ? urlThumb.source : ''
      @urlEmbeded = urlEmbeded ? urlEmbeded.source : ''
      @urlOpened  = urlOpened ? urlOpened.source : ''
      @urlVideo   = urlVideo ? urlVideo.source : ''
      @urlFlickr  = urlVideo ? urlVideo.url : ''
      @urlPhotoPage = urlPhotoPage
      @caption    = caption
      @id = id
    end
  end

end

Liquid::Template.register_tag('flickr_photo', Jekyll::FlickrPhotoTag)