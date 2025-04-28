-- .luacheckrc
std = 'luajit'
globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'pending', 'assert', 'eq' }
ignore = {
  'plugin/*', -- plugin loader shim
}

max_line_length = false -- or turn it off completely
