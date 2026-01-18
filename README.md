# Elephant Iconify

Custom [Elephant](https://github.com/abenz1267/elephant) menu to browse [Iconify](https://iconify.design/) icons in [Walker Launcher](https://github.com/abenz1267/walker).

Browse popular icon libraries like [Lucide](https://lucide.dev/), [Hugeicons](https://hugeicons.com/), and [Phosphor Icons](https://phosphoricons.com/) without opening a web browser.

![screenshot](./screenshot.png)

## Prerequisites

- [Walker](https://github.com/abenz1267/walker)
- [Elephant](https://github.com/abenz1267/elephant) with `menus` provider
- [curl](https://curl.se/) for fetching icons

## Installation

```bash
git clone https://github.com/nino-mau/elephant-iconify
cd elephant-iconify
sudo ./install.sh
```

The install script will:

1. Copy the menu to `~/.config/elephant/menus/`
2. Append action keybindings to your walker config

## Setup

After installation, configure a prefix to trigger the custom menu in your walker config:

```toml
[[providers.prefixes]]
prefix = "?"
provider = "menus:iconify"
```

Then restart walker & elephant.

## Usage

Type to search icons. By default, only Lucide and Hugeicons collections are searched for better performance.

**Special search syntax:**
- Use `/` to search specific collections: `collection/query` (e.g., `phosphor/arrow`)
- Toggle "Search All" with `Ctrl+A` to search across all Iconify collections

**Caching:**
SVG icons are downloaded and cached in `~/.cache/elephant/iconify/` on first use for faster subsequent loads.

> [!NOTE]
> Searching all collections may be slower since icons are fetched on demand.

## Actions

| Key      | Action                                          |
| -------- | ----------------------------------------------- |
| `Enter`  | Copy icon name to clipboard (e.g., `lucide:search`) |
| `Ctrl+S` | Copy icon as SVG code                           |
| `Ctrl+A` | Toggle "Search All" mode                        |

## Configuration

Edit `~/.config/elephant/menus/iconify.lua` to customize:

```lua
-- Number of icons fetched per search
local ICONIFY_API_SEARCH_LIMIT = 64

-- Collections searchable by default
local DEFAULT_COLLECTIONS = { "lucide", "hugeicons" }
```
