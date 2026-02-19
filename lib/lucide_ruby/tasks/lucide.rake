# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "fileutils"
require "tmpdir"
require "zip"

namespace :lucide do
  desc "Sync Lucide icons from GitHub releases"
  task sync: :environment do
    version = ENV["LUCIDE_VERSION"]
    icon_path = LucideRuby.configuration.resolved_icon_path

    puts "Fetching Lucide icons..."

    # Determine download URL
    if version
      download_url = "https://github.com/lucide-icons/lucide/releases/download/#{version}/lucide-icons-#{version}.zip"
      puts "Pinned version: #{version}"
    else
      puts "Fetching latest release..."
      latest_url = fetch_latest_release_url
      version = latest_url[/\/([^\/]+)\/lucide-icons-/, 1]
      download_url = latest_url
      puts "Latest version: #{version}"
    end

    Dir.mktmpdir("lucide-sync") do |tmpdir|
      zip_path = File.join(tmpdir, "lucide-icons.zip")
      extract_path = File.join(tmpdir, "extracted")

      # Download
      puts "Downloading #{download_url}..."
      download_file(download_url, zip_path)
      puts "Downloaded #{File.size(zip_path)} bytes"

      # Extract
      FileUtils.mkdir_p(extract_path)
      extract_zip(zip_path, extract_path)

      # Find SVG files in extracted archive
      svg_source = find_svg_directory(extract_path)

      if svg_source.nil?
        raise LucideRuby::SyncError, "No SVG files found in the downloaded archive"
      end

      svg_files = Dir.glob(File.join(svg_source, "*.svg"))
      puts "Found #{svg_files.size} icons"

      # Atomic replace: write to temp dir, then swap
      staging_path = "#{icon_path}.staging"
      backup_path = "#{icon_path}.backup"

      FileUtils.rm_rf(staging_path)
      FileUtils.mkdir_p(staging_path)

      svg_files.each do |svg_file|
        FileUtils.cp(svg_file, staging_path)
      end

      # Write version file
      File.write(File.join(staging_path, ".lucide-version"), version)

      # Swap directories
      FileUtils.rm_rf(backup_path)
      FileUtils.mv(icon_path, backup_path) if Dir.exist?(icon_path)
      FileUtils.mv(staging_path, icon_path)
      FileUtils.rm_rf(backup_path)

      # Clear cache
      LucideRuby.cache.clear!

      puts "Synced #{svg_files.size} Lucide icons (#{version}) to #{icon_path}"
    end
  end

  desc "Show info about synced Lucide icons"
  task info: :environment do
    icon_path = LucideRuby.configuration.resolved_icon_path

    unless Dir.exist?(icon_path)
      puts "No icons found at #{icon_path}"
      puts "Run `rake lucide:sync` to download icons."
      next
    end

    svg_count = Dir.glob(File.join(icon_path, "*.svg")).size
    version_file = File.join(icon_path, ".lucide-version")
    version = File.exist?(version_file) ? File.read(version_file).strip : "unknown"

    puts "Lucide Icons"
    puts "  Path:    #{icon_path}"
    puts "  Version: #{version}"
    puts "  Icons:   #{svg_count}"
  end
end

def fetch_latest_release_url
  uri = URI("https://api.github.com/repos/lucide-icons/lucide/releases/latest")
  response = make_request(uri)

  data = JSON.parse(response.body)
  asset = data["assets"]&.find { |a| a["name"]&.match?(/^lucide-icons-.*\.zip$/) }

  unless asset
    raise LucideRuby::SyncError, "Could not find lucide-icons zip in latest release"
  end

  asset["browser_download_url"]
end

def download_file(url, destination, redirect_limit = 5)
  raise LucideRuby::SyncError, "Too many redirects" if redirect_limit == 0

  uri = URI(url)
  response = make_request(uri)

  case response
  when Net::HTTPSuccess
    File.binwrite(destination, response.body)
  when Net::HTTPRedirection
    download_file(response["location"], destination, redirect_limit - 1)
  else
    raise LucideRuby::SyncError, "Download failed: #{response.code} #{response.message}"
  end
end

def make_request(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  http.open_timeout = 15
  http.read_timeout = 60

  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "lucide-ruby/#{LucideRuby::VERSION}"
  request["Accept"] = "application/octet-stream, application/json"

  http.request(request)
end

def extract_zip(zip_path, extract_path)
  Zip::File.open(zip_path) do |zip_file|
    zip_file.each do |entry|
      entry_path = File.join(extract_path, entry.name)

      # Prevent zip slip
      unless entry_path.start_with?(File.realpath(extract_path))
        raise LucideRuby::SyncError, "Zip slip detected: #{entry.name}"
      end

      if entry.directory?
        FileUtils.mkdir_p(entry_path)
      else
        FileUtils.mkdir_p(File.dirname(entry_path))
        entry.extract(entry_path)
      end
    end
  end
end

def find_svg_directory(extract_path)
  # Look for SVGs directly or in subdirectories
  if Dir.glob(File.join(extract_path, "*.svg")).any?
    return extract_path
  end

  Dir.glob(File.join(extract_path, "**", "*.svg")).first&.then { |f| File.dirname(f) }
end
