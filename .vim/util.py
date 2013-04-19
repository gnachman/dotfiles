import vim
def SmartSplit():
  # If a vertical split would not cause the windows to be fewer than 80 characters wide
  # then do a vsplit, else a horizontal split.
  total_width = 0
  n = 0
  for w in vim.windows:
    total_width += w.width
    n += 1
  if total_width / (n+1) <= 80:
    vim.command('execute "split"')
  else:
    vim.command('execute "vsplit"')
