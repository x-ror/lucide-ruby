# frozen_string_literal: true

require "spec_helper"

RSpec.describe LucideRuby::Cache do
  subject(:cache) { described_class.new }

  describe "#read and #write" do
    it "stores and retrieves values" do
      cache.write("check", "<path/>")
      expect(cache.read("check")).to eq("<path/>")
    end

    it "returns nil for missing keys" do
      expect(cache.read("missing")).to be_nil
    end
  end

  describe "#fetch" do
    it "returns cached value if present" do
      cache.write("check", "<path/>")
      result = cache.fetch("check") { "should not be called" }
      expect(result).to eq("<path/>")
    end

    it "computes and caches value if missing" do
      result = cache.fetch("check") { "<path/>" }
      expect(result).to eq("<path/>")
      expect(cache.read("check")).to eq("<path/>")
    end
  end

  describe "#clear!" do
    it "removes all entries" do
      cache.write("a", "1")
      cache.write("b", "2")
      cache.clear!
      expect(cache.size).to eq(0)
    end
  end

  describe "#size" do
    it "returns number of cached entries" do
      expect(cache.size).to eq(0)
      cache.write("a", "1")
      expect(cache.size).to eq(1)
    end
  end

  describe "#preload!" do
    it "preloads all icons from the icon directory" do
      count = cache.preload!
      expect(count).to eq(3) # check, arrow-down, user
      expect(cache.read("check")).to include("path")
    end

    it "raises IconsNotSynced when directory doesn't exist" do
      LucideRuby.configure { |c| c.icon_path = "/tmp/nonexistent-lucide-icons" }
      expect { cache.preload! }.to raise_error(LucideRuby::IconsNotSynced)
    end
  end
end
