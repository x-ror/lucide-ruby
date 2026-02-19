# frozen_string_literal: true

require "spec_helper"

RSpec.describe LucideRuby::ViewHelpers do
  let(:helper_class) do
    Class.new do
      include LucideRuby::ViewHelpers
    end
  end

  let(:helper) { helper_class.new }

  describe "#lucide_icon" do
    it "renders an SVG icon" do
      html = helper.lucide_icon("check")
      expect(html).to include("<svg")
      expect(html).to include('<path d="M20 6 9 17l-5-5"/>')
    end

    it "accepts symbol names" do
      html = helper.lucide_icon(:check)
      expect(html).to include('<path d="M20 6 9 17l-5-5"/>')
    end

    it "passes options through" do
      html = helper.lucide_icon("check", size: 16, class: "small-icon")
      expect(html).to include('width="16"')
      expect(html).to include('height="16"')
      expect(html).to include('class="small-icon"')
    end

    it "supports data attributes" do
      html = helper.lucide_icon("check", data: { controller: "icon" })
      expect(html).to include('data-controller="icon"')
    end
  end
end
