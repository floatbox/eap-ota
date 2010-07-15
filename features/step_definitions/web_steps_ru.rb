# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

# Commonly used webrat steps
# http://github.com/brynary/webrat

Допустим /^(?:|я )нахожусь на (.+)$/ do |page_name|
  visit path_to(page_name)
end

Если /^(?:|я |затем )перехожу на (.+)$/ do |page_name|
  visit path_to(page_name)
end

Если /^(?:|я |затем )нажимаю на кнопку "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |button,selector|
  with_scope(selector) do 
    click_button(button)
  end
end

Если /^(?:|я |затем )перехожу по линку "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |link,selector|
  with_scope(selector) do 
    click_link(link)
  end
end

Если /^(?:|я |затем )ввожу "([^\"]*)" в поле "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do 
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#

Если /^(?:|я |затем )заполняю следующие поля:$/ do |fields|
  fields.rows_hash.each do |name, value|
    Если %{я ввожу "#{value}" в поле "#{name}"}
  end
end

Если /^(?:|я |затем )выбираю "([^\"]*)" в выпадающем списке "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, :from => field)
  end
end


Если /^(?:|я |затем )ставлю галочку "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    check(field)
  end
end


Если /^(?:|я |затем )выбираю "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

То /^(?:|я |затем )должен увидеть "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

То /^(?:|я |затем я )не должен увидеть "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if defined?(Spec::Rails::Matchers)
      page.should_not have_content(text)
    else
      assert_not page.has_content?(text)
    end
  end
end

Если /^(?:я|затем) передвигаю мышку на "([^\"]+)"$/ do |locator|
  page.driver.find(locator).first.node.hover
end

То /^открой мне браузер$/ do
  save_and_open_page
end
