# Add your affiliate tag to _config.yml for the amazon key, like:
#
# amazon: michaelbrundage
#
# And then use any product ID with this filter, like:
#
# {{ '0321165810' | amazon }}
#
# To get the URL
# http://www.amazon.com/gp/product/0321165810?tag=kenners-21

module AmazonFilter
  def amazon(input)
    amazon_info = @context.registers[:site].config['amazon']
    tag = amazon_info['tag']
    if (tag.nil?)
      raise FatalException.new("Missing required 'amazon' tag in _config.yml.")
    end

    "http://www.amazon.co.uk/dp/#{input}/?tag=#{tag}"
  end
end

Liquid::Template.register_filter(AmazonFilter)
