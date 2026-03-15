# frozen_string_literal: true

require "spec_helper"

RSpec.describe LucideRuby::ReleaseResolver do
  describe ".resolve" do
    it "selects the newest stable release that includes the zip asset" do
      response = instance_double(
        Net::HTTPSuccess,
        body: JSON.dump(
          [
            {
              "tag_name" => "0.576.0",
              "draft" => false,
              "prerelease" => false,
              "assets" => []
            },
            {
              "tag_name" => "0.575.0",
              "draft" => false,
              "prerelease" => false,
              "assets" => [
                {
                  "name" => "lucide-icons-0.575.0.zip",
                  "browser_download_url" => "https://example.test/0.575.0.zip"
                }
              ]
            }
          ]
        )
      )

      allow(described_class).to receive(:make_request).and_return(response)

      expect(described_class.resolve).to eq(
        version: "0.575.0",
        download_url: "https://example.test/0.575.0.zip"
      )
    end

    it "ignores prereleases even when they include assets" do
      response = instance_double(
        Net::HTTPSuccess,
        body: JSON.dump(
          [
            {
              "tag_name" => "0.576.0-beta.1",
              "draft" => false,
              "prerelease" => true,
              "assets" => [
                {
                  "name" => "lucide-icons-0.576.0-beta.1.zip",
                  "browser_download_url" => "https://example.test/0.576.0-beta.1.zip"
                }
              ]
            },
            {
              "tag_name" => "0.575.0",
              "draft" => false,
              "prerelease" => false,
              "assets" => [
                {
                  "name" => "lucide-icons-0.575.0.zip",
                  "browser_download_url" => "https://example.test/0.575.0.zip"
                }
              ]
            }
          ]
        )
      )

      allow(described_class).to receive(:make_request).and_return(response)

      expect(described_class.resolve).to eq(
        version: "0.575.0",
        download_url: "https://example.test/0.575.0.zip"
      )
    end

    it "raises when a pinned release has no zip asset" do
      response = instance_double(
        Net::HTTPSuccess,
        body: JSON.dump(
          {
            "tag_name" => "0.576.0",
            "assets" => []
          }
        )
      )

      allow(described_class).to receive(:make_request).and_return(response)

      expect do
        described_class.resolve(version: "0.576.0")
      end.to raise_error(LucideRuby::SyncError, "Could not find lucide-icons zip for release 0.576.0")
    end
  end
end