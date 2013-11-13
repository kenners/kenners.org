require 'date'

module Jekyll
  module CountdownFilter
    def countdown(date)
      dday = Jekyll.configuration({})['countdown']['dday']
      if dday > date.to_date
        days = (dday - date.to_date).to_i
        if days == 1
            "Deploy in #{days} day"
        else
            "Deploy in #{days} days"
        end
      else
        days = (date.to_date - dday).to_i
        "Day \##{days} South"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::CountdownFilter)