local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- タブタイトルにカレントディレクトリ名を表示 (tmux: #{pane_current_path} の basename)
wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
  local pane = tab.active_pane
  local cwd = pane.current_working_dir
  local dir = cwd and cwd.file_path or ''
  local basename = dir:match('([^/]+)/*$') or dir
  local index = tab.tab_index + 1
  return string.format('%d:%s', index, basename)
end)

-- Font (iTerm2: HackGenConsole-Regular 16)
config.font = wezterm.font('HackGen Console NF', { weight = 'Regular' })
config.font_size = 16.0

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

-- Tab bar
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

-- Window appearance (no transparency, no blur)
config.window_background_opacity = 1.0
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- Color scheme (randomly selected at startup)
local themes = {
  'Nord',
  'Catppuccin Mocha',
  'Gruvbox Dark (Gogh)',
  'Tokyo Night',
  'Solarized Dark (Gogh)',
  'One Dark (Gogh)',
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
