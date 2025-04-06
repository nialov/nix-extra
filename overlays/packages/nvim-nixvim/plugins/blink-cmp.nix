{ pkgs, ... }: {
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        fuzzy.prebuilt_binaries.download = false;
        # Recommended by minuet-ai-nvim
        completion.trigger.prefetch_on_insert = false;
        keymap = {
          # preset = "super-tab";
          # -- set to 'none' to disable the 'default' preset
          # preset = 'default',

          "<C-p>" = [ "select_prev" "fallback" ];
          "<C-n>" = [ "select_next" "fallback" ];
          "<C-k>" = [ "accept" "fallback" ];
          "<A-y>".__raw = "require('minuet').make_blink_map()";
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
          default = [ "lsp" "path" "snippets" "buffer" "tmux" "ripgrep" ];
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
            minuet = {
              name = "minuet";
              module = "minuet.blink";
              score_offset = 8;
            };
            tmux = {
              module = "blink-cmp-tmux";
              name = "tmux";
              # -- default options
              opts = {
                all_panes = false;
                capture_history = false;
                # -- only suggest completions from `tmux` if the `trigger_chars` are
                # -- used
                triggered_only = false;
                trigger_chars = [ "." ];
              };
            };
          };
        };
      };
    };
    blink-ripgrep.enable = true;
  };

  extraPlugins = [
    {
      plugin = pkgs.vimPlugins.minuet-ai-nvim;
      config = ''
        lua << EOF
        require("minuet").setup({
            provider = 'codestral',
            -- n_completions = 1, -- recommend for local model for resource saving
            -- I recommend beginning with a small context window size and incrementally
            -- expanding it, depending on your local computing power. A context window
            -- of 512, serves as an good starting point to estimate your computing
            -- power. Once you have a reliable estimate of your local computing power,
            -- you should adjust the context window to a larger value.
            -- context_window = 512,
            provider_options = {
                openai_fim_compatible = {
                    api_key = 'TERM',
                    name = 'Ollama',
                    end_point = 'https://ollama.novaskai.xyz/v1/completions',
                    model = 'deepseek-coder-v2:16b',
                    optional = {
                        max_tokens = 112,
                        top_p = 0.9,
                    },
                },
                codestral = {
                    model = 'codestral-latest',
                    end_point = 'https://codestral.mistral.ai/v1/fim/completions',
                    api_key = 'CODESTRAL_API_KEY',
                    stream = true,
                    -- template = {
                        -- prompt = "See [Prompt Section for default value]",
                        -- suffix = "See [Prompt Section for default value]",
                    -- },
                    optional = {
                        stop = nil, -- the identifier to stop the completion generation
                        max_tokens = nil,
                    },
                },
            },
        })
        EOF

      '';
    }
    { plugin = pkgs.vimPlugins.blink-cmp-tmux; }

  ];

}
