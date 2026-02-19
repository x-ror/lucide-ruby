# frozen_string_literal: true

require "lucide_ruby"
require "fileutils"

FIXTURES_PATH = File.expand_path("fixtures/icons", __dir__)

RSpec.configure do |config|
  config.before(:each) do
    LucideRuby.reset_configuration!
    LucideRuby.configure do |c|
      c.icon_path = FIXTURES_PATH
    end
  end

  config.before(:suite) do
    FileUtils.mkdir_p(FIXTURES_PATH)

    File.write(File.join(FIXTURES_PATH, "check.svg"), <<~SVG)
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
    SVG

    File.write(File.join(FIXTURES_PATH, "arrow-down.svg"), <<~SVG)
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></svg>
    SVG

    File.write(File.join(FIXTURES_PATH, "user.svg"), <<~SVG)
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
    SVG

    File.write(File.join(FIXTURES_PATH, ".lucide-version"), "0.500.0")
  end

  config.after(:suite) do
    FileUtils.rm_rf(FIXTURES_PATH)
  end
end
