local api = vim.api
local util = require('dashboard.util')

local function defaule_header()
  return util.center_align({
    '                                                                         ',
    '██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗ ',
    '██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗',
    '██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║',
    '██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║',
    '██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝',
    '╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ',
    '                                                                         ',
  })
end

local function default_center()
  local spaces = (' '):rep(16)
  return {
    {
      desc = 'Open Doc in Neovim' .. spaces,
      shortcut = 'a',
      action = 'help dashboard',
      short_hi = 'DashboardShortCut',
    },
    { desc = 'Open Doc in Browser' .. spaces, shortcut = 'b', short_hi = 'DashboardShortCut' },
  }
end

local function parse_center(center_conf)
  local center = {}
  for _, item in ipairs(center_conf) do
    center[#center + 1] = item.desc
    center[#center + 1] = ''
  end
  return util.center_align(util.tail_align(center))
end

local function default_footer()
  return {
    'Time is money',
  }
end

local function handle_cursor(winid, bufnr, center_first)
  local lnum, before_col = unpack(api.nvim_win_get_cursor(winid))
  if lnum < center_first then
    lnum = center_first
  end
  local text = api.nvim_buf_get_text(bufnr, lnum - 1, 0, lnum - 1, -1, {})[1]
  local col = text:find('%w')
  if not col then
    lnum = lnum > vim.b[bufnr].before and lnum + 1 or lnum - 1
    col = before_col + 1
  end
  vim.b[bufnr].before = lnum
  api.nvim_win_set_cursor(winid, { lnum, col - 1 })
end

local function init(entry, opt)
  entry:append(opt.header or defaule_header()):hi(function()
    return 'DashboardHeader'
  end)

  local center_conf = opt.center or default_center()
  local center = parse_center(center_conf)

  local center_first = api.nvim_buf_line_count(entry.bufnr) + 1

  entry
    :append(center)
    :hi(function()
      return 'DashboardCenter'
    end)
    :tailbtn(function(item)
      for _, val in ipairs(center_conf) do
        if item:find(val.desc) then
          return val.shortcut, val.short_hi, val.action
        end
      end
    end)

  handle_cursor(entry.winid, entry.bufnr, center_first)
  api.nvim_create_autocmd('CursorMoved', {
    buffer = entry.bufnr,
    callback = function()
      handle_cursor(entry.winid, entry.bufnr, center_first)
    end,
  })

  local footer = opt.footer or default_footer()

  entry:append(util.center_align(footer)):hi(function()
    return 'DashboardFooter'
  end)
  return entry
end

return {
  init = init,
}
