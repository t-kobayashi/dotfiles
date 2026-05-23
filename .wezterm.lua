local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Powerline タブタイトル (色はカラースキームから動的に取得)
local PL_LEFT  = utf8.char(0xe0b2)  --
local PL_RIGHT = utf8.char(0xe0b0)  --
local BUILTIN_SCHEMES = wezterm.color.get_builtin_schemes()

wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
  local palette = conf.resolved_palette

  local base_bg     = wezterm.color.parse(palette.background)
  local bar_bg      = base_bg:darken(0.3)
  local active_bg   = wezterm.color.parse(palette.brights[5])  -- bright blue
  local inactive_bg = base_bg:lighten(0.1)
  local inactive_fg = wezterm.color.parse(palette.foreground)

  -- アクティブタブの文字色: 背景とのコントラストで黒/白を自動選択
  local black = wezterm.color.parse('#000000')
  local white = wezterm.color.parse('#ffffff')
  local active_fg = active_bg:contrast_ratio(black) >= active_bg:contrast_ratio(white)
    and tostring(black) or tostring(white)

  local pane     = tab.active_pane
  local cwd      = pane.current_working_dir
  local dir      = cwd and cwd.file_path or ''
  local basename = dir:match('([^/]+)/*$') or dir
  local index    = tab.tab_index + 1
  local title    = string.format(' %s %d: %s ', wezterm.nerdfonts.fa_folder, index, basename)

  if tab.is_active then
    return {
      { Background = { Color = tostring(bar_bg) } },
      { Foreground = { Color = tostring(active_bg) } },
      { Text = PL_LEFT },
      { Background = { Color = tostring(active_bg) } },
      { Foreground = { Color = active_fg } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = title },
      { Attribute = { Intensity = 'Normal' } },
      { Background = { Color = tostring(bar_bg) } },
      { Foreground = { Color = tostring(active_bg) } },
      { Text = PL_RIGHT },
    }
  end

  return {
    { Background = { Color = tostring(bar_bg) } },
    { Foreground = { Color = tostring(inactive_bg) } },
    { Text = PL_LEFT },
    { Background = { Color = tostring(inactive_bg) } },
    { Foreground = { Color = tostring(inactive_fg) } },
    { Text = title },
    { Background = { Color = tostring(bar_bg) } },
    { Foreground = { Color = tostring(inactive_bg) } },
    { Text = PL_RIGHT },
  }
end)

-- 右下にカラースキーム名を表示
wezterm.on('update-right-status', function(window, pane)
  local scheme_name = window:effective_config().color_scheme or ''
  -- 括弧とその中身を削除 (例: "Gruvbox Dark (Gogh)" → "Gruvbox Dark")
  local name = scheme_name:gsub('%s*%b()%s*', ''):gsub('%s+$', '')

  local palette  = BUILTIN_SCHEMES[scheme_name]
  local bar_bg   = palette and wezterm.color.parse(palette.background):darken(0.3) or '#181825'
  local accent   = palette and palette.brights and palette.brights[5] or '#89b4fa'

  window:set_right_status(wezterm.format {
    { Background = { Color = tostring(bar_bg) } },
    { Foreground = { Color = accent } },
    { Text = PL_LEFT },
    { Background = { Color = accent } },
    { Foreground = { Color = tostring(bar_bg) } },
    { Text = '  ' .. name .. ' ' },
  })
end)

-- Font (iTerm2: HackGenConsole-Regular 16)
config.font = wezterm.font('HackGen Console NF', { weight = 'Regular' })
config.font_size = 16.0
config.window_frame = {
  font = wezterm.font('HackGen Console NF', { weight = 'Regular' }),
  font_size = 14.0,
}

-- Window size (iTerm2: 128 cols x 48 rows)
config.initial_cols = 128
config.initial_rows = 48

-- Scrollback (iTerm2: 10000 lines)
config.scrollback_lines = 10000

-- Cursor (iTerm2: block, no blink)
config.default_cursor_style = 'SteadyBlock'

-- Select-to-copy (iTerm2: CopySelection = 1)
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
  },
}

-- Tab bar (retro mode for powerline custom rendering)
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- Window appearance (no transparency, no blur)
config.window_background_opacity = 1.0
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- Color scheme (randomly selected at startup)
local themes = {
  'nord',
  'Catppuccin Mocha',
  'Gruvbox Dark (Gogh)',
  'Tokyo Night',
  'Solarized Dark (Gogh)',
  'One Dark (Gogh)',
  'Monokai Pro (Gogh)',
  'Ubuntu',
  'Dracula',
}
math.randomseed(os.time())
config.color_scheme = themes[math.random(#themes)]

-- Leader key (C-z, tmux prefix と同じ)
config.leader = { key = 'z', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- C-z をターミナルに送る (tmux: bind C-z send-prefix)
  { key = 'z', mods = 'LEADER|CTRL', action = wezterm.action.SendKey { key = 'z', mods = 'CTRL' } },

  -- タブ操作 (tmux: C-n / C-p / c)
  { key = 'n', mods = 'LEADER|CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER|CTRL', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'c', mods = 'LEADER',      action = wezterm.action.SpawnTab 'CurrentPaneDomain' },

  -- タブ番号で移動 (tmux: prefix + [1-9], base-index 1)
  { key = '1', mods = 'LEADER', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = wezterm.action.ActivateTab(4) },
  { key = '6', mods = 'LEADER', action = wezterm.action.ActivateTab(5) },
  { key = '7', mods = 'LEADER', action = wezterm.action.ActivateTab(6) },
  { key = '8', mods = 'LEADER', action = wezterm.action.ActivateTab(7) },
  { key = '9', mods = 'LEADER', action = wezterm.action.ActivateTab(8) },

  -- ペイン分割 (tmux デフォルト: % = 左右, " = 上下)
  { key = '%',  mods = 'LEADER', action = wezterm.action.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = '"',  mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- ペインリサイズ開始 (tmux: bind -r C-h/l/j/k, リピート対応)
  { key = 'h', mods = 'LEADER|CTRL', action = wezterm.action.Multiple {
    wezterm.action.AdjustPaneSize { 'Left', 6 },
    wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 1000 },
  }},
  { key = 'l', mods = 'LEADER|CTRL', action = wezterm.action.Multiple {
    wezterm.action.AdjustPaneSize { 'Right', 6 },
    wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 1000 },
  }},
  { key = 'j', mods = 'LEADER|CTRL', action = wezterm.action.Multiple {
    wezterm.action.AdjustPaneSize { 'Down', 6 },
    wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 1000 },
  }},
  { key = 'k', mods = 'LEADER|CTRL', action = wezterm.action.Multiple {
    wezterm.action.AdjustPaneSize { 'Up', 6 },
    wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 1000 },
  }},

  -- ペイン入れ替え (tmux: bind -r s swap-pane -U, リピート対応)
  { key = 's', mods = 'LEADER', action = wezterm.action.Multiple {
    wezterm.action.RotatePanes 'CounterClockwise',
    wezterm.action.ActivateKeyTable { name = 'resize_pane', one_shot = false, timeout_milliseconds = 1000 },
  }},

  -- ペイン/タブを閉じる (tmux: k / K)
  { key = 'k', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = 'K', mods = 'LEADER', action = wezterm.action.CloseCurrentTab  { confirm = false } },

  -- ペイン一覧 (tmux: i)
  { key = 'i', mods = 'LEADER', action = wezterm.action.PaneSelect {} },

  -- ペイン移動 (tmux: prefix + 矢印キー / o)
  { key = 'LeftArrow',  mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'o',          mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Next' },

  -- コピーモード / ペースト (tmux: [ / y / p)
  { key = '[', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
  { key = 'y', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
  { key = 'p', mods = 'LEADER', action = wezterm.action.PasteFrom 'Clipboard' },

}

config.key_tables = {
  -- リサイズリピートモード (C-z C-h 後に C-h を押し続けて連続リサイズ)
  resize_pane = {
    { key = 'h', mods = 'CTRL', action = wezterm.action.AdjustPaneSize { 'Left',  6 } },
    { key = 'l', mods = 'CTRL', action = wezterm.action.AdjustPaneSize { 'Right', 6 } },
    { key = 'j', mods = 'CTRL', action = wezterm.action.AdjustPaneSize { 'Down',  6 } },
    { key = 'k', mods = 'CTRL', action = wezterm.action.AdjustPaneSize { 'Up',    6 } },
    { key = 's', mods = 'NONE', action = wezterm.action.RotatePanes 'CounterClockwise' },
    { key = 'Escape', mods = 'NONE', action = 'PopKeyTable' },
  },

  -- コピーモード Emacs キーバインド (tmux: setw -g mode-keys emacs)
  copy_mode = {
    -- 終了
    { key = 'g',      mods = 'CTRL', action = wezterm.action.CopyMode 'Close' },
    { key = 'q',      mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
    { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },

    -- 文字単位移動 (C-b/f/p/n + 矢印キー)
    { key = 'b',          mods = 'CTRL', action = wezterm.action.CopyMode 'MoveLeft' },
    { key = 'f',          mods = 'CTRL', action = wezterm.action.CopyMode 'MoveRight' },
    { key = 'p',          mods = 'CTRL', action = wezterm.action.CopyMode 'MoveUp' },
    { key = 'n',          mods = 'CTRL', action = wezterm.action.CopyMode 'MoveDown' },
    { key = 'LeftArrow',  mods = 'NONE', action = wezterm.action.CopyMode 'MoveLeft' },
    { key = 'RightArrow', mods = 'NONE', action = wezterm.action.CopyMode 'MoveRight' },
    { key = 'UpArrow',    mods = 'NONE', action = wezterm.action.CopyMode 'MoveUp' },
    { key = 'DownArrow',  mods = 'NONE', action = wezterm.action.CopyMode 'MoveDown' },

    -- 行頭/行末 (C-a / C-e)
    { key = 'a', mods = 'CTRL', action = wezterm.action.CopyMode 'MoveToStartOfLine' },
    { key = 'e', mods = 'CTRL', action = wezterm.action.CopyMode 'MoveToEndOfLineContent' },

    -- 単語単位移動 (M-b / M-f)
    { key = 'b', mods = 'META', action = wezterm.action.CopyMode 'MoveBackwardWord' },
    { key = 'f', mods = 'META', action = wezterm.action.CopyMode 'MoveForwardWord' },

    -- ページ移動 (C-v / M-v)
    { key = 'v', mods = 'CTRL', action = wezterm.action.CopyMode 'PageDown' },
    { key = 'v', mods = 'META', action = wezterm.action.CopyMode 'PageUp' },
    { key = 'PageDown', mods = 'NONE', action = wezterm.action.CopyMode 'PageDown' },
    { key = 'PageUp',   mods = 'NONE', action = wezterm.action.CopyMode 'PageUp' },

    -- バッファ先頭/末尾 (M-< / M->)
    { key = '<', mods = 'META', action = wezterm.action.CopyMode 'MoveToScrollbackTop' },
    { key = '>', mods = 'META', action = wezterm.action.CopyMode 'MoveToScrollbackBottom' },

    -- 選択開始 (C-Space)
    { key = ' ', mods = 'CTRL', action = wezterm.action.CopyMode { SetSelectionMode = 'Cell' } },

    -- コピーして終了 (M-w / C-w)
    { key = 'w', mods = 'META', action = wezterm.action.Multiple {
      wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
      wezterm.action.CopyMode 'Close',
    }},
    { key = 'w', mods = 'CTRL', action = wezterm.action.Multiple {
      wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
      wezterm.action.CopyMode 'Close',
    }},

    -- 検索 (C-s 前方 / C-r 後方)
    { key = 's', mods = 'CTRL', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
    { key = 'r', mods = 'CTRL', action = wezterm.action.CopyMode 'PriorMatch' },

  },

  -- 検索モード Emacs キーバインド
  search_mode = {
    { key = 'g',      mods = 'CTRL', action = wezterm.action.CopyMode 'Close' },
    { key = 'Escape', mods = 'NONE', action = wezterm.action.CopyMode 'Close' },
    { key = 'Enter',  mods = 'NONE', action = wezterm.action.CopyMode 'AcceptPattern' },
    { key = 's',      mods = 'CTRL', action = wezterm.action.CopyMode 'NextMatch' },
    { key = 'r',      mods = 'CTRL', action = wezterm.action.CopyMode 'PriorMatch' },
  },
}

return config
