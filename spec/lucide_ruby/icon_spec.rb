# frozen_string_literal: true

require "spec_helper"

RSpec.describe LucideRuby::Icon do
  describe ".normalize_name" do
    it "converts symbols to strings" do
      expect(described_class.normalize_name(:check)).to eq("check")
    end

    it "converts underscores to hyphens" do
      expect(described_class.normalize_name("arrow_down")).to eq("arrow-down")
    end

    it "downcases the name" do
      expect(described_class.normalize_name("ArrowDown")).to eq("arrowdown")
    end

    it "strips whitespace" do
      expect(described_class.normalize_name("  check  ")).to eq("check")
    end
  end

  describe ".extract_inner_html" do
    it "extracts content between svg tags" do
      svg = '<svg xmlns="http://www.w3.org/2000/svg" width="24"><path d="M20 6 9 17l-5-5"/></svg>'
      expect(described_class.extract_inner_html(svg)).to eq('<path d="M20 6 9 17l-5-5"/>')
    end

    it "returns empty string for empty svg" do
      svg = '<svg xmlns="http://www.w3.org/2000/svg"></svg>'
      expect(described_class.extract_inner_html(svg)).to eq("")
    end

    it "handles multiline svg content" do
      svg = "<svg>\n<path d=\"M1\"/>\n<path d=\"M2\"/>\n</svg>"
      result = described_class.extract_inner_html(svg)
      expect(result).to include('<path d="M1"/>')
      expect(result).to include('<path d="M2"/>')
    end
  end

  describe "#render" do
    it "renders an SVG with default attributes" do
      html = described_class.new("check").render
      expect(html).to include("<svg")
      expect(html).to include("</svg>")
      expect(html).to include('<path d="M20 6 9 17l-5-5"/>')
      expect(html).to include('width="24"')
      expect(html).to include('height="24"')
      expect(html).to include('stroke="currentColor"')
      expect(html).to include('aria-hidden="true"')
    end

    it "accepts symbol names" do
      html = described_class.new(:check).render
      expect(html).to include('<path d="M20 6 9 17l-5-5"/>')
    end

    it "normalizes underscored names" do
      html = described_class.new(:arrow_down).render
      expect(html).to include('<path d="M12 5v14"/>')
    end

    it "applies size option" do
      html = described_class.new("check", size: 16).render
      expect(html).to include('width="16"')
      expect(html).to include('height="16"')
    end

    it "applies class option" do
      html = described_class.new("check", class: "text-red-500").render
      expect(html).to include('class="text-red-500"')
    end

    it "merges class with default_class" do
      LucideRuby.configure { |c| c.default_class = "icon" }
      html = described_class.new("check", class: "text-red-500").render
      expect(html).to include('class="icon text-red-500"')
    end

    it "applies default_class when no class given" do
      LucideRuby.configure { |c| c.default_class = "icon" }
      html = described_class.new("check").render
      expect(html).to include('class="icon"')
    end

    it "applies data attributes" do
      html = described_class.new("check", data: { action: "click->menu#toggle" }).render
      expect(html).to include('data-action="click-&gt;menu#toggle"')
    end

    it "applies aria attributes and skips aria-hidden" do
      html = described_class.new("check", aria: { label: "Checkmark" }).render
      expect(html).to include('aria-label="Checkmark"')
      expect(html).not_to include('aria-hidden')
    end

    it "sets aria-hidden when no aria attributes given" do
      html = described_class.new("check").render
      expect(html).to include('aria-hidden="true"')
    end

    it "returns html_safe string" do
      html = described_class.new("check").render
      expect(html).to be_html_safe
    end

    it "applies custom stroke_width" do
      html = described_class.new("check", "stroke-width": 1.5).render
      expect(html).to include('stroke-width="1.5"')
    end

    it "raises IconNotFound for missing icons" do
      expect {
        described_class.new("nonexistent").render
      }.to raise_error(LucideRuby::IconNotFound, /nonexistent/)
    end

    it "raises IconsNotSynced when icon directory doesn't exist" do
      LucideRuby.configure { |c| c.icon_path = "/tmp/nonexistent-lucide-icons" }
      expect {
        described_class.new("check").render
      }.to raise_error(LucideRuby::IconsNotSynced)
    end
  end
end
