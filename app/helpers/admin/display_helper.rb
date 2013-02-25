module Admin::DisplayHelper
  include Admin::Resources::DisplayHelper

  def build_display(item, fields)
    fields.map do |attribute, type|
      condition = (type == :boolean) || item.send(attribute).present?
      title = @resource.human_attribute_name(attribute) + " <small>[#{attribute}]</small>"
      value = condition ? send("display_#{type}", item, attribute) : mdash
      [title.html_safe, value]
    end
  end

  def display_password(item, attribute)
    item.send(attribute)
  end

  def display_time(item, attribute)
    I18n.l(item.send(attribute), :format => @resource.typus_date_format(attribute))
  end
end