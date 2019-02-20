require "rails_helper"

RSpec.describe "Scrape", :type => :feature, js: true do

  it "should not find any assets" do
    set_url_and_click_button '/test/no_elements.html', 'all'
    expect(page).to have_css('.results-area h1', text: 'No Results Found')
  end

  it "should display error with bad url" do
    set_url_and_click_button 'this is a very bad url', 'all', false
    expect(page).to have_css('.alert.alert-danger', text:'There was an error processing that URL, please insure it is correct and try again.')
  end

  it "should find one video asset" do
    set_url_and_click_button '/test/one_video.html', 'video'
    expect(page).to have_css('.results-area .card', count: 1)
  end

  it "should find two js assets" do
    set_url_and_click_button '/test/two_javascript.html', 'js'
    expect(page).to have_css('.results-area .card', count: 2)
  end

  it "should find three image assets" do
    set_url_and_click_button '/test/three_images.html', 'image'
    expect(page).to have_css('.results-area .card', count: 3)
  end

  it "should find four css assets" do
    set_url_and_click_button '/test/four_css.html', 'css'
    expect(page).to have_css('.results-area .card', count: 4)
  end

  def set_url_and_click_button html_path, data_type, use_prefix = true
    visit '/'
    if use_prefix
      url = URI.parse(current_url).to_s
      url = "#{url}#{html_path}"
    else
      url = html_path
    end
    find('#url-input').set(url)
    find('button#dropdownMenuButton').click()
    find("a.dropdown-item[data-type='#{data_type}']").click()
    wait_for_ajax
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      active = page.evaluate_script('jQuery.active')
      until active == 0
        active = page.evaluate_script('jQuery.active')
      end
    end
  end

end