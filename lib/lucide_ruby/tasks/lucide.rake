# frozen_string_literal: true

require "net/http"
require "uri"
require "fileutils"
require "tmpdir"
require "zip"

namespace :lucide do
  desc "Sync Lucide icons from GitHub releases"
  task sync: :environment do
    version = ENV["LUCIDE_VERSION"]
    icon_path = LucideRuby.configuration.resolved_icon_path

    puts "Fetching Lucide icons..."

    if version
      release = LucideRuby::ReleaseResolver.resolve(version: version)
      download_url = release[:download_url]
      version = release[:version]
      puts "Pinned version: #{version}"
    else
      puts "Fetching latest release with assets..."
      release = LucideRuby::ReleaseResolver.resolve
      download_url = release[:download_url]
      version = release[:version]
      puts "Latest version: #{version}"
    end

    Dir.mktmpdir("lucide-sync") do |tmpdir|
      zip_path = File.join(tmpdir, "lucide-icons.zip")

      # Download
      puts "Downloading #{download_url}..."
      download_file(download_url, zip_path)
      puts "Downloaded #{File.size(zip_path)} bytes"

      # Extract SVGs directly from zip
      staging_path = "#{icon_path}.staging"
      backup_path = "#{icon_path}.backup"

      FileUtils.rm_rf(staging_path)
      FileUtils.mkdir_p(staging_path)

      svg_count = 0
      Zip::File.open(zip_path) do |zip_file|
        zip_file.each do |entry|
          next if entry.directory?
          next unless entry.name.end_with?(".svg")

          dest = File.join(staging_path, File.basename(entry.name))
          File.binwrite(dest, entry.get_input_stream.read)
          svg_count += 1
        end
      end

      if svg_count == 0
        FileUtils.rm_rf(staging_path)
        raise LucideRuby::SyncError, "No SVG files found in the downloaded archive"
      end

      puts "Found #{svg_count} icons"

      # Write version file
      File.write(File.join(staging_path, ".lucide-version"), version)

      # Swap directories
      FileUtils.rm_rf(backup_path)
      FileUtils.mv(icon_path, backup_path) if Dir.exist?(icon_path)
      FileUtils.mv(staging_path, icon_path)
      FileUtils.rm_rf(backup_path)

      # Clear cache
      LucideRuby.cache.clear!

      puts "Synced #{svg_count} Lucide icons (#{version}) to #{icon_path}"
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

