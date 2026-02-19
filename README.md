# LucideRuby

Rails view helpers for rendering [Lucide](https://lucide.dev) SVG icons inline.

Icons are **not bundled** in the gem. A rake task syncs them from official Lucide GitHub releases into your Rails app's filesystem.

## Installation

Add to your Gemfile:

```ruby
gem "lucide-ruby"
```

Then run:

```bash
bundle install
rails generate lucide_ruby:install
rake lucide:sync
```

This will:

1. Create a config initializer at `config/initializers/lucide_ruby.rb`
2. Create the icon directory at `app/assets/icons/lucide/`
3. Download all Lucide SVG icons from the latest release

Commit the icons to version control so deploys don't need to re-sync.

## Usage

```erb
<%= lucide_icon("arrow-down") %>
<%= lucide_icon(:check, size: 16, class: "text-green-500") %>
<%= lucide_icon("menu", data: { action: "click->menu#toggle" }) %>
<%= lucide_icon("user", aria: { label: "User profile" }) %>
```

### Options

| Option | Description |
|--------|-------------|
| `size` | Sets both `width` and `height` |
| `class` | CSS class (appended to `default_class` if configured) |
| `data` | Data attributes hash |
| `aria` | Aria attributes hash (disables auto `aria-hidden`) |
| `stroke-width` | Override stroke width |
| `fill` | Override fill color |
| `stroke` | Override stroke color |
| Any SVG attribute | Passed through to the `<svg>` element |

### Accessibility

By default, icons render with `aria-hidden="true"`. When you pass any `aria` attribute (e.g., `aria: { label: "..." }`), `aria-hidden` is omitted so screen readers can access the icon.

## Configuration

```ruby
# config/initializers/lucide_ruby.rb
LucideRuby.configure do |config|
  config.default_class = "icon"
  config.default_size = 20
  config.default_stroke_width = 1.5
  config.default_fill = "none"
  config.default_stroke = "currentColor"
  config.icon_path = Rails.root.join("app/assets/icons/lucide").to_s
  config.default_attributes = {}
end
```

## Rake Tasks

### `rake lucide:sync`

Downloads and extracts Lucide icons from GitHub releases.

```bash
# Sync latest version
rake lucide:sync

# Pin to a specific version
LUCIDE_VERSION=0.575.0 rake lucide:sync
```

### `rake lucide:info`

Shows info about currently synced icons.

```bash
rake lucide:info
# Lucide Icons
#   Path:    /path/to/app/assets/icons/lucide
#   Version: 0.575.0
#   Icons:   1458
```

## Caching

Icons are cached in memory after first use. For production, you can preload all icons at boot:

```ruby
# config/initializers/lucide_ruby.rb
LucideRuby.configure do |config|
  # ...
end

LucideRuby.cache.preload! if Rails.env.production?
```

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
