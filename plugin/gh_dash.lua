local ok, gh_dash = pcall(require, 'gh_dash')
if not ok then
  return
end
gh_dash.setup()
