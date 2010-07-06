# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def geo_tags_for location
    location.geo_tags.collect do |geo_tag|
      link_to h(geo_tag.name), geo_tag
    end.join ' '
  end

  def cases_for location
    "лечу #{location.case_from} #{location.case_to} c пересадкой #{location.case_in}"
  end
end
