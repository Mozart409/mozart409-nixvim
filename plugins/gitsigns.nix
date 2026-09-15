{
  programs.nixvim.plugins.gitsigns = {
    enable = true;
    settings = {
      signs = {
        add.text = "+";
        change.text = "~";
        delete.text = "_";
        topdelete.text = "‾";
        changedelete.text = "~";
      };
      on_attach.__raw = ''
        function(bufnr)
          local gitsigns = require('gitsigns')
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end, 'Jump to next git [c]hange')
          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end, 'Jump to previous git [c]hange')

          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'git [s]tage hunk')
          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'git [r]eset hunk')

          map('n', '<leader>hs', gitsigns.stage_hunk, 'git [s]tage hunk')
          map('n', '<leader>hr', gitsigns.reset_hunk, 'git [r]eset hunk')
          map('n', '<leader>hS', gitsigns.stage_buffer, 'git [S]tage buffer')
          map('n', '<leader>hR', gitsigns.reset_buffer, 'git [R]eset buffer')
          map('n', '<leader>hp', gitsigns.preview_hunk, 'git [p]review hunk')
          map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'git preview hunk [i]nline')
          map('n', '<leader>hb', gitsigns.blame_line, 'git [b]lame line')
          map('n', '<leader>hd', gitsigns.diffthis, 'git [d]iff against index')
          map('n', '<leader>hD', function()
            gitsigns.diffthis('@')
          end, 'git [D]iff against last commit')

          map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle git show [b]lame line')
          map('n', '<leader>tw', gitsigns.toggle_word_diff, '[T]oggle git [w]ord diff')
        end
      '';
    };
  };
}
