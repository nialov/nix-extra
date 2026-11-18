{ pkgs, ... }:
{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        fuzzy = {
          prebuilt_binaries.download = false;
          implementation = "prefer_rust_with_warning";
          # https://cmp.saghen.dev/configuration/reference.html#fuzzy
          sorts = [
            "score"
            "kind"
            "sort_text"
          ];
        };
        # Recommended by minuet-ai-nvim
        completion = {
          trigger.prefetch_on_insert = false;
          menu.draw = {
            columns.__raw = "{ { 'source_name' },  { 'label', 'label_description', gap = 1 } }";
            treesitter = [ "lsp" ];
            components.kind_icon = {
              text.__raw = ''
                function(ctx)
                  local lspkind = require("lspkind")
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                      local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                      if dev_icon then
                          icon = dev_icon
                      end
                  end

                  return icon .. ctx.icon_gap
                end
              '';
              highlight.__raw = ''
                function(ctx)
                  local hl = ctx.kind_hl
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end
              '';
            };
          };
        };
        keymap = {
          # preset = "super-tab";
          # -- set to 'none' to disable the 'default' preset
          # preset = 'default',

          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          # "<C-k>" = [ "accept" "snippet_forward" "fallback" ];
          "<C-k>".__raw = ''
            {
             function(cmp)
               if cmp.snippet_active() then return cmp.accept()
               else return cmp.select_and_accept() end
             end,
             'snippet_backward',
             'show_signature',
             'fallback'
            }
          '';
          "<C-j>" = [
            "snippet_forward"
            "fallback"
          ];
          "<A-y>".__raw = "require('minuet').make_blink_map()";
          "<A-d>" = [
            "show_signature"
            "hide_signature"
            "fallback"
          ];
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
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
            "tmux"
            "ripgrep"
            "emoji"
          ];
          providers = {
            lsp = {
              async = true;
              # Prioritize lsp
              score_offset = 100;
            };
            ripgrep = {
              async = true;
              module = "blink-ripgrep";
              name = "Ripgrep";
              # Deprioritize
              score_offset = -10;
              opts = {
                prefix_min_len = 3;
                backend = {
                  context_size = 5;
                  ripgrep = {
                    max_filesize = "1M";
                    project_root_fallback = true;
                    search_casing = "--ignore-case";
                  };
                };
                project_root_marker = ".git";
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
              score_offset = -20;
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
            buffer = {
              transform_items.__raw = ''
                function(_, items)
                  return vim
                    .iter(items)
                    :filter(function(item)
                        -- Filter out Snippet words from completion
                        return item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
                     end)
                    :totable()
                end
              '';
              opts = {
                # https://cmp.saghen.dev/recipes#buffer-completion-from-all-open-buffers
                # filter to only "normal" buffers
                get_bufnrs.__raw = ''
                  function()
                    -- return vim.tbl_filter(function(bufnr)
                      -- return vim.bo[bufnr].buftype == ""
                    -- end, vim.api.nvim_list_bufs())
                    return vim
                      .iter(vim.api.nvim_list_bufs())
                      :filter(function(bufnr) return vim.bo[bufnr].buftype == "" end)
                      :totable()
                  end
                '';
              };
            };
            path = {
              score_offset = 20;
              max_items = 3;
            };
            emoji = {
              module = "blink-emoji";
              name = "Emoji";
              score_offset = 15;
              # Optional configurations
              opts = {
                insert = true;
              };
            };
          };
        };
      };
    };
    blink-ripgrep.enable = true;
    blink-emoji.enable = true;
    luasnip = {
      enable = true;
      fromLua = [ { paths = ../snippets; } ];
    };
    lspkind = {
      enable = true;
      cmp.enable = false;
    };
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
