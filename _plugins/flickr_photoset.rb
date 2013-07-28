# Flickr Photoset Tag
#
# A Jekyll plug-in for embedding Flickr photoset in your Liquid templates.
#
# Usage:
#
#   {% flickr_photoset 72157624158475427 %}
#   {% flickr_photoset 72157624158475427 "Square" "Medium 640" "Large" "Site MP4" %}
#
# For futher information please visit: https://github.com/j0k3r/jekyll-flickr-photoset
#
# Author: Jeremy Benoist
# Source: https://github.com/j0k3r/jekyll-flickr-photoset

require 'flickraw'
require 'shellwords'

module Jekyll

  class FlickrPhotosetTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      params = Shellwords.shellwords markup

      @photoset       = params[0]
      @galleryType    = params[1] || "clearing"
      @photoThumbnail = params[2] || "Large Square"
      @photoEmbeded   = params[3] || "Medium 640"
      @photoOpened    = params[4] || "Large"
      @video          = params[5] || "Site MP4"
    end

    def render(context)

      flickrConfig = context.registers[:site].config["flickr"]

      galleryType = @galleryType

      if cache_dir = flickrConfig['cache_dir']
        path = File.join(cache_dir, "#{@photoset}-#{@photoThumbnail}-#{@photoEmbeded}-#{@photoOpened}-#{@video}.yml")
        if File.exist?(path)
          photos = YAML::load(File.read(path))
        else
          photos = generate_photo_data(@photoset, flickrConfig)
          File.open(path, 'w') {|f| f.print(YAML::dump(photos)) }
          photos = YAML::load(File.read(path))
        end
      else
        photos = generate_photo_data(@photoset, flickrConfig)
      end

      if galleryType == 'orbit'
        output = "<div class=\"slideshow-wrapper row\"><div class=\"large-10 small-12 small-centered columns\">\n"
        output += "  <div class=\"preloader\"></div>\n"
        output += "  <ul data-orbit data-options=\"bullets: false; timer: false; animation: 'fade'; animation_speed: 1000;\">\n"

        photos.each_with_index do |photo, i|
          if photo['urlVideo'] != ''
            output += ""
          else
            output += "    <li class=\"\" data-orbit-slide=\"flickr-#{photo['id']}\">\n"
            output += "      <div class=\"orbit-flickr-wrapper\" style=\"background-image: url(\'#{photo['urlOpened']}\');\"></div>\n"
            output += "      <div class=\"orbit-caption show-for-landscape hide-for-small\">\n"
            output += "        <span class=\"orbit-caption-title\">#{photo['title']}</span>\n"
            output += "        <span class=\"right\">\n"
            output += "          <a href=\"#{photo['urlPhotoPage']}\" class=\"ss-icon ss-social-circle\" title=\"View on Flickr\">flickr</a>\n"
            output += "        </span><br>\n"
            output += "        <span class=\"orbit-caption-body\">#{photo['caption']}</span>\n"
            output += "      </div>\n"
            output += "    </li>\n"
          end
        end
        output += "  </ul>\n"
        output += "</div></div>\n"
      else
        # Therefore just a normal clearing gallery
        output =  "<div class=\"row\">\n"
        output += "  <div class=\"large-11 small-centered columns\">\n"
        output += "    <ul class=\"clearing-thumbs\" data-clearing>\n"

        photos.each_with_index do |photo, i|
          if photo['urlVideo'] != ''
            output += ""
          else
            output += "      <li>\n"
            output += "        <a class=\"th\" href=\"#{photo['urlOpened']}\">\n"
            output += "          <img src=\"#{photo['urlThumb']}\" data-caption=\"<span class='orbit-caption-title'>#{photo['title']}</span><br><span class='orbit-caption-body'>#{photo['caption']}</span>\">\n"
            output += "        </a>\n"
            output += "      </li>\n"
          end
        end

        output += "    </ul>\n"
        output += "  </div>\n"
        output += "</div>\n"
      end


      # return content
      output
    end

    def generate_photo_data(photoset, flickrConfig)
      returnSet = Array.new

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
        photos = flickr.photosets.getPhotos :photoset_id => photoset
      rescue Exception => e
        raise "Bad photoset: #{photoset}"
      end

      photos.photo.each_index do | i |

        title = photos.photo[i].title
        id    = photos.photo[i].id

        urlThumb   = String.new
        urlEmbeded = String.new
        urlOpened  = String.new
        urlVideo   = String.new
        urlPhotoPage = String.new
        caption    = String.new

        sizes = flickr.photos.getSizes(:photo_id => id)
        info = flickr.photos.getInfo(:photo_id => id)

        urlThumb       = sizes.find {|s| s.label == @photoThumbnail }
        urlEmbeded     = sizes.find {|s| s.label == @photoEmbeded }
        urlOpened      = sizes.find {|s| s.label == @photoOpened }
        urlVideo       = sizes.find {|s| s.label == @video }
        urlPhotoPage   = info.urls.find {|u| u.type == 'photopage'}
        caption        = info['description']


        photo = FlickrPhoto.new(title, urlThumb, urlEmbeded, urlOpened, urlVideo, urlPhotoPage.to_s, caption, id)
        returnSet.push photo
      end

      # sleep a little so that you don't get in trouble for bombarding the Flickr servers
      sleep 1

      returnSet
    end
  end

  class FlickrPhoto
    attr_accessor :title, :urlThumb, :urlEmbeded, :urlOpened, :urlVideo, :urlFlickr, :urlPhotoPage, :caption, :id

    def initialize(title, urlThumb, urlEmbeded, urlOpened, urlVideo, urlPhotoPage, caption, id)
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

Liquid::Template.register_tag('flickr_photoset', Jekyll::FlickrPhotosetTag)