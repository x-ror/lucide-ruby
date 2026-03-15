# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module LucideRuby
  module ReleaseResolver
    REPOSITORY_API_URL = "https://api.github.com/repos/lucide-icons/lucide"
    ASSET_NAME_PATTERN = /^lucide-icons-.*\.zip$/

    extend self

    def resolve(version: nil)
      version ? resolve_version(version) : resolve_latest
    end

    def resolve_latest
      releases = fetch_json("#{REPOSITORY_API_URL}/releases?per_page=30")

      release = releases.find do |candidate|
        next false if candidate["draft"] || candidate["prerelease"]

        release_asset(candidate)
      end

      unless release
        raise LucideRuby::SyncError, "Could not find a Lucide release with downloadable assets"
      end

      release_info(release)
    end

    def resolve_version(version)
      release = fetch_json("#{REPOSITORY_API_URL}/releases/tags/#{version}")
      release_info(release, fallback_version: version)
    end

    def release_asset(release)
      release.fetch("assets", []).find do |asset|
        asset["name"]&.match?(ASSET_NAME_PATTERN)
      end
    end

    def release_info(release, fallback_version: nil)
      asset = release_asset(release)
      version = release["tag_name"] || fallback_version

      unless asset
        raise LucideRuby::SyncError, "Could not find lucide-icons zip for release #{version}"
      end

      {
        version: version,
        download_url: asset["browser_download_url"]
      }
    end

    def fetch_json(url)
      response = make_request(URI(url))
      JSON.parse(response.body)
    rescue JSON::ParserError => error
      raise LucideRuby::SyncError, "Invalid response from GitHub: #{error.message}"
    end

    def make_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = 15
      http.read_timeout = 60

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "lucide-ruby/#{LucideRuby::VERSION}"
      request["Accept"] = "application/vnd.github+json"

      response = http.request(request)

      return response if response.is_a?(Net::HTTPSuccess)

      raise LucideRuby::SyncError, "GitHub request failed: #{response.code} #{response.message}"
    end
  end
end