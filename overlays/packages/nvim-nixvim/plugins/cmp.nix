{
  plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      # TODO: Switch to magazine-nvim-src? Works as drop-in replacement.
      # package = pkgs.neovimUtils.buildNeovimPlugin {
      #   pname = "nvim-cmp";
      #   version = inputs.magazine-nvim-src.rev;
      #   src = inputs.magazine-nvim-src;
      #   postPatch = ''
      #     cp ${pkgs.vimPlugins.nvim-cmp}/nvim-cmp-scm-1.rockspec ./nvim-cmp-scm-1.rockspec
      #   '';
      # };
      settings = {
        sources = [
          { name = "nvim_lsp"; }
          {
            name = "luasnip";
            option = { use_show_condition = true; };
          }
          { name = "cmp_pandoc"; }
          { name = "async_path"; }
          { name = "spell"; }
          {
            name = "buffer";
            option = { get_bufnrs.__raw = "vim.api.nvim_list_bufs"; };
          }
          # {
          #   name = "fuzzy_buffer";
          #   option = { min_match_length = 5; };
          # }
          { name = "tmux"; }
          { name = "emoji"; }
        ];
        mapping = {
          "<C-k>" = ''
            cmp.mapping(
              function(fallback)
                local luasnip = require('luasnip')
                if cmp.visible() then
                    if luasnip.expandable() then
                      luasnip.expand()
                    -- elseif luasnip.expand_or_jumpable() then
                      -- luasnip.expand_or_jump()
                    else
                      cmp.confirm({select = true, behavior = cmp.ConfirmBehavior.Replace})
                    end
                elseif luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                else
                    cmp.complete()
                end
              end,
              { "i", "s" }
            )
          '';

          "<C-e>" = "cmp.mapping.close()";
          # "<CR>" =
          #   "cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })";
          "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<C-b>" = ''
            cmp.mapping(
                  cmp.mapping.complete({
                    config = {
                      sources = cmp.config.sources({
                        { name = 'cmp_ai' },
                      }),
                    },
              }), {"i"})
          '';

          # "<C-e>" = ''
          #   cmp.mapping(
          #         cmp.mapping.complete({
          #           config = {
          #             sources = cmp.config.sources({
          #               { name = 'emoji' },
          #             }),
          #           },
          #     }), {"i"})
          # '';
          # "<C-x><C-f>" = ''
          #     cmp.mapping(
          #         cmp.mapping.complete({
          #           config = {
          #             sources = cmp.config.sources({
          #               { name = 'async_path' },
          #             }),
          #           },
          #     }),
          #     { 'i' }
          #   )
          # '';
        };
        snippet = {
          expand =
            "function(args) require('luasnip').lsp_expand(args.body) end";
        };
        # sorting.comparators = [
        # "require('cmp_fuzzy_buffer.compare')"
        # "require('cmp').config.compare.offset"
        # "require('cmp').config.compare.exact"
        # "require('cmp').config.compare.locality"
        # "require('cmp').config.compare.recently_used"
        # "require('cmp').config.compare.score"
        # "require('cmp').config.compare.order"
        # ];
        performance = {
          debounce = 240;
          fetching_timeout = 1000;
          throttle = 60;
          max_view_entries = 7;
        };
        formatting = {
          fields = [ "abbr" "menu" "kind" ];
          format.__raw = ''
            function(entry, item)
                    -- Define menu shorthand for different completion sources.
                    local menu_icon = {
                        nvim_lsp = "📖",
                        nvim_lua = "🌙",
                        luasnip  = "",
                        buffer   = "🔋",
                        path     = "💾",
                        tmux     = "🖥️",
                    }
                    -- Set the menu "icon" to the shorthand for each completion source.
                    item.menu = menu_icon[entry.source.name] or entry.source_name

                    -- Set the fixed width of the completion menu to 60 characters.
                    -- fixed_width = 20

                    -- Set 'fixed_width' to false if not provided.
                    fixed_width = fixed_width or false

                    -- Get the completion entry text shown in the completion window.
                    local content = item.abbr

                    -- Set the fixed completion window width.
                    if fixed_width then
                        vim.o.pumwidth = fixed_width
                    end

                    -- Get the width of the current window.
                    local win_width = vim.api.nvim_win_get_width(0)

                    -- Set the max content width based on either: 'fixed_width'
                    -- or a percentage of the window width, in this case 20%.
                    -- We subtract 10 from 'fixed_width' to leave room for 'kind' fields.
                    local max_content_width = fixed_width and fixed_width - 10 or math.floor(win_width * 0.2)

                    -- Truncate the completion entry text if it's longer than the
                    -- max content width. We subtract 3 from the max content width
                    -- to account for the "..." that will be appended to it.
                    if #content > max_content_width then
                        item.abbr = vim.fn.strcharpart(content, 0, max_content_width - 3) .. "..."
                    else
                        item.abbr = content .. (" "):rep(max_content_width - #content)
                    end
                    return item
                end
          '';
        };
      };
      cmdline = {
        "/" = {
          mapping.__raw = "cmp.mapping.preset.cmdline()";
          completion.keyword_length = 2;
          sources = [{ name = "buffer"; }];
        };
        ":" = {
          mapping.__raw = "cmp.mapping.preset.cmdline()";
          completion.keyword_length = 2;
          sources = [
            { name = "path"; }
            {
              name = "cmdline";
              option = { ignore_cmds = [ "Man" "!" ]; };
            }
          ];
        };

      };
    };
    cmp-ai = {
      enable = true;
      settings = {
        max_lines = 1000;
        provider = "Ollama";
        provider_options.model = "qwen2.5-coder:0.5b";
        provider_options.base_url = "https://ollama.novaskai.xyz/api/generate";
        run_on_every_keystroke = false;
        ignored_file_types = { };
        notify = true;
      };
    };
    cmp-emoji = { enable = true; };
  };
}
