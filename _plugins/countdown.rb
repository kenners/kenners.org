require 'date'

module Jekyll
  module CountdownFilter
    def countdown(date)
      dday = Jekyll.configuration({})['countdown']['dday']
      arrivalday = Jekyll.configuration({})['countdown']['arrivalday']
      if dday > date.to_date
        days = (dday - date.to_date).to_i
        if days == 1
            "Deploy in #{days} day"
        else
            "Deploy in #{days} days"
        end
      else
        days = (date.to_date - arrivalday).to_i
        if arrivalday > date.to_date
          "In transit"
        else
          "Day \##{days} in Antarctica"
        end
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::CountdownFilter)
