# -*- coding: utf-8 -*-
require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))


module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

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

Если /^(?:|я |затем )убираю галочку "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end


Если /^(?:|я |затем )выбираю "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

То /^(?:|я |затем )должен увидеть "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end



То /^(?:|я |затем )должен получить JSON :$/ do |expected_json|
  require 'json'
  expected = JSON.pretty_generate(JSON.parse(expected_json))
  actual   = JSON.pretty_generate(JSON.parse(response.body))
  expected.should == actual
end

То /^(?:|я |затем я )не должен увидеть "([^\"]*)"(?: внутри "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_content(text)
    else
      assert page.has_no_content?(text)
    end
  end
end

Если /^(?:я|затем) передвигаю мышку на "([^\"]+)"$/ do |locator|
  page.driver.find(locator).first.node.hover
end

То /^открой мне браузер$/ do
  save_and_open_page
end

То  /^в поле "([^\"]*)" написано "([^\"]*)"/  do |selector, text|
  find_field(selector).value.should == text
end

Если /^я в комплитере кликаю по варианту "([^"]*)" "([^"]*)"$/ do |red_text, gray_text|
  page.find("u[text()='#{gray_text}']/u[text()='#{red_text}']").click
end


Если /^(?:|я |затем я )в календаре кликаю по дню через (\d+) дней$/ do |d|
  page.find("li[data-dmy='#{(Date.today + d.to_i.days).strftime('%d%m%y')}']").click
end

То /^в заголовке выдачи содержится "([^"]*)" c интервалом через (\d+) дней \- через (\d+) дней$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Если /^нажимаю на "Искать"$/ do
  sleep(2)
  with_scope '#search-submit' do
    click_link('Искать')
  end
end

Если /^я жду (\d+) секунд$/ do |sec|
  sleep sec.to_i
end

Если /^я переключаюсь на другое окно$/ do
  page.driver.browser.window_handles.each do |h|
    if h != page.driver.browser.window_handle
      page.driver.browser.switch_to.window(h)
      break
    end
  end
end


То /^я должен оказаться на странице (.+)$/ do |page_name|
  #page.driver.browser.switch_to.window('/pnr_form')
  #print page.driver.browser.bridge.getWindowHandles #methods.sort.join(', ')#.bridge.getWindowHandlers
  current_path.should == path_to(page_name)
end


То /^должно быть отправлено письмо на адрес "([^"]*)"$/ do |email_address|
  email = ActionMailer::Base.deliveries.first
  email.to[0].should == email_address
end


То /^дата через (\d+) дней подсвечивается$/ do |d|
  page.should have_xpath("//li[data-dmy='#{(Date.today + d.to_i.days).strftime('%d%m%y')}'][background-color='#DC3F8A']")
  #page.find("li[data-dmy='#{(Date.today + d.to_i.days).strftime('%d%m%y')}']").background-color.should == 'DC3F8A'
end

