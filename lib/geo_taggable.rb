# encoding: utf-8
module GeoTaggable
  def geo_tag_list
    geo_tags.map(&:name).join(', ')
  end

  def geo_tag_list=(list)
    tag_names = list.split(/,\s*/)
    geo_tags.map(&:name).join(', ')
    self.geo_tags = tag_names.map {|tag_name| GeoTag.find_or_create_by_name(tag_name)}
  end
end
