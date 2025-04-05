{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        fuzzy.prebuilt_binaries.download = false;
        keymap = {
          # preset = "super-tab";
          # -- set to 'none' to disable the 'default' preset
          # preset = 'default',

          "<C-p>" = [ "select_prev" "fallback" ];
          "<C-n>" = [ "select_next" "fallback" ];
          "<C-k>" = [ "accept" "fallback" ];
          # ['<Down>'] = { 'select_next', 'fallback' },

          # -- disable a keymap from the preset
          # ['<C-e>'] = {},

          # -- show with a list of providers
          # ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },

          # -- control whether the next command will be run when using a function
          # ['<C-n>'] = { 
          # function(cmp)
          # if some_condition then return end -- runs the next command
          # return true -- doesn't run the next command
          # end,
          # 'select_next'
          # },
        };

        snippets.preset = "luasnip";
        sources = {
          default = [ "lsp" "path" "snippets" "buffer" "ripgrep" ];
          providers = {
            ripgrep = {
              async = true;
              module = "blink-ripgrep";
              name = "Ripgrep";
              score_offset = 100;
              opts = {
                prefix_min_len = 3;
                context_size = 5;
                max_filesize = "1M";
                project_root_marker = ".git";
                project_root_fallback = true;
                search_casing = "--ignore-case";
                additional_rg_options = { };
                fallback_to_regex_highlighting = true;
                ignore_paths = { };
                additional_paths = { };
                debug = false;
              };
            };
          };
        };
      };
    };
    blink-ripgrep.enable = true;
  };

}
