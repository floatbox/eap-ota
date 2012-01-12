module Admin::FormHelper
  include Admin::Resources::FormHelper

  # кнопка "И добавить новый" всем только мешает
  # "сохранить" - теперь первая (и дефолтная) кнопка
  def save_options
    { # "_addanother" => "Save and add another",
      "_save" => "Save",
      "_continue" => "Save and continue editing"
    }
  end

  def typus_template_field(attribute, template, form)
    options = { :start_year => @resource.typus_options_for(:start_year),
                :end_year => @resource.typus_options_for(:end_year),
                :minute_step => @resource.typus_options_for(:minute_step),
                :disabled => attribute_disabled?(attribute),
                :include_blank => true }

    html_options = attribute_disabled?(attribute) ? { :disabled => 'disabled' } : {}

    label_text = @resource.human_attribute_name(attribute) + " <small>[#{attribute}]</small>"

    if options[:disabled] == true
      label_text += "<small>#{Typus::I18n.t("Read only")}</small>"
    end

    locals = { :resource => @resource,
               :attribute => attribute,
               :attribute_id => "#{@resource.table_name}_#{attribute}",
               :options => options,
               :html_options => html_options,
               :form => form,
               :label_text => label_text.html_safe }

    render "admin/templates/#{template}", locals
  end

end
