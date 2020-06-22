# without lines 1-12, screenshots and html captured from failing specs are blank
# source: https://github.com/mattheworiordan/capybara-screenshot/issues/225
require "action_dispatch/system_testing/test_helpers/setup_and_teardown" 
::ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown.module_eval do
  def before_setup
    super
  end

  def after_teardown
    super
  end
end

Capybara::Screenshot.register_driver(:selenium_chrome_headless_sandboxless) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara::Screenshot.autosave_on_failure = false

# Save CircleCI artifacts

def save_timestamped_page_and_screenshot(page, meta)
  filename = File.basename(meta[:file_path])
  line_number = meta[:line_number]

  time_now = Time.now
  timestamp = "#{time_now.strftime('%Y-%m-%d-%H-%M-%S.')}#{'%03d' % (time_now.usec/1000).to_i}"

  screenshot_name = "screenshot-#{filename}-#{line_number}-#{timestamp}.png"
  screenshot_path = "#{Rails.root.join('tmp/capybara')}/#{screenshot_name}"
  page.save_screenshot(screenshot_path)

  page_name = "html-#{filename}-#{line_number}-#{timestamp}.html"
  page_path = "#{Rails.root.join('tmp/capybara')}/#{page_name}"
  page.save_page(page_path)

  puts "\n  Screenshot: tmp/capybara/#{screenshot_name}"
  puts "  HTML: tmp/capybara/#{page_name}"
end
