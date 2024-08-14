{ pkgs, ... }:
let inherit (pkgs) lib;

in {
  luaLoader.enable = true;
  opts = {
    # Expand tab to spaces
    expandtab = true;

    # Incremental live completion
    inccommand = "nosplit";

    # Set highlight on search
    hlsearch = true;

    # Make line numbers default
    number = true;

    # Do not save when switching buffers
    hidden = true;

    # Enable mouse mode
    mouse = "a";

    # Enable break indent
    breakindent = true;

    # Case insensitive searching UNLESS /C or capital in search
    ignorecase = true;
    smartcase = true;

    # Decrease update time
    updatetime = 250;

    signcolumn = "yes";

    backup = false;
    writebackup = false;
    swapfile = false;
    cmdheight = 2;
    scrolloff = 999;
    laststatus = 2;
    showmode = true;
    showcmd = true;
    incsearch = true;
    showmatch = true;
    termguicolors = true;
    wildmenu = true;
    timeout = true;
    # -- the timeout when WhichKey opens is controlled by the vim setting timeoutlen.
    # -- Please refer to the documentation to properly set it up. Setting it to 0,
    # -- will effectively always show WhichKey immediately, but a setting of 500
    # -- (500ms) is probably more appropriate.
    timeoutlen = 500;
    modelines = 0;
    # -- vim.o.number = "relativenumber"
    ruler = true;
    visualbell = true;
    cursorline = true;
    fileencoding = "utf-8";
    # -- vim.o.shadafile = nil
    wrap = true;
    linebreak = true;
    textwidth = 0;
    wrapmargin = 0;
    tabstop = 4;
    shiftwidth = 4;
    shiftround = false;
    splitbelow = true;
    splitright = true;
    foldlevelstart = 99;
    foldenable = false;
    infercase = true;
    virtualedit = "block";
    lazyredraw = true;
    autoread = true;
    conceallevel = 0;
    history = 10000;
    confirm = true;
    backspace = "indent,eol,start";
    listchars = "tab:▸ ,eol:¬";
    viminfo = "!,'500,f1,<550,:550,@550,s500";
    whichwrap = "<,>,[,],h,l";
    grepprg = "rg --vimgrep --no-heading --ignore-case";
    grepformat = "%f:%l:%c:%m,%f:%l:%m";
    completeopt = "menu,menuone,noselect";
    clipboard = "";
    guicursor = lib.concatStringsSep "," [
      "n-v-c:block"
      "i-ci-ve:ver25"
      "r-cr:hor20,o:hor50"
      "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
      "sm:block-blinkwait175-blinkoff150-blinkon175"
    ];
  };

  globals = {
    # -- Set leader key to comma
    mapleader = ",";

    # -- Set gx handler
    netrw_browsex_viewer = "wsl-open-dynamic";
    gitblame_enabled = 0;
  };
  autoCmd = [
    {
      callback.__raw = ''
        function ()
          local disable_env_variable_name = "NEOVIM_DISABLE_AUTOFORMAT"
          local disable_autoformat = vim.tbl_contains(vim.tbl_keys(vim.fn.environ()), disable_env_variable_name)
          if disable_autoformat then
              vim.cmd([[ FormatDisable ]])
              vim.notify(
                  string.format(
                      "Would enable auto-formatting for buffer but environment variable %s exists.",
                      disable_env_variable_name
                  )
              )
          else
              vim.cmd([[ FormatEnable ]])
              vim.notify("Enabled auto-formatting for buffer.")
          end
        end
      '';
      event = [ "BufEnter" ];
      pattern = [ "*" ];
    }
    {
      event = [ "VimResized" "WinEnter" "FocusGained" ];
      pattern = [ "*" ];
      command = "wincmd =";
    }
    {
      event = [ "FocusLost" ];
      pattern = [ "*" ];
      callback.__raw = ''
        function ()
            vim.cmd [[
                " Save when losing focus.
                exe ':silent! update'

                " Go back to normal mode from insert mode.
                if mode() == 'i'
                  exe ':stopinsert'
                endif

                if getbufvar(bufnr('%'), '&filetype') == 'fzf'
                  exe ':q'
                endif
            ]]

        end

      '';
    }
  ];
  userCommands = {
    "WikiEntry" = {
      command.__raw = "require('nialov_utils').wikientry";
      desc = "Open personal wiki entry";
    };

  };
  files = {
    "after/ftplugin/fish.lua" = { localOpts.commentstring = "#%s"; };
    "after/ftplugin/nix.lua" = { };
    "after/ftplugin/pandoc.lua" = {
      localOpts = {
        equalprg = "pandoc -f markdown -t markdown";
        formatprg = "pandoc -f markdown -t markdown";
        # TODO: Check if works or if PandocAugroup is needed:
        # " Must be overwritten with autocmd due to whatever plugin not respecting
        # " simple setlocal done above
        # augroup PandocAugroup
        #     autocmd!
        #     autocmd BufNewFile,BufRead *.md setlocal conceallevel=0
        # augroup END
        conceallevel = 0;
        shiftwidth = 4;
        tabstop = 4;
      };
    };
    "after/ftplugin/rst.lua" = {
      localOpts = {
        formatlistpat = "^\\s*\\d\\+[\\]:.)}\\t ]\\s*\\|^\\s*[-+o*]\\s*";
        indentexpr = "";
        equalprg = "pandoc -f rst -t rst";
        formatprg = "pandoc -f rst -t rst";
        spell = true;
        spelllang = "en";
        shiftwidth = 3;
        softtabstop = -1;
        tabstop = 3;
        expandtab = true;
      };
      keymaps = [{
        mode = "n";
        key = "gw";
        action = "gq";
        options = {
          silent = true;
          buffer = true;
        };
      }];
      extraConfigVim = ''
        setlocal suffixesadd+=.rst
        setlocal suffixes+=.rst
        nmap <buffer> <silent> gw gq
        function! AuFocusLost()
            " Save when losing focus.
            exe ':silent! update'

            " Go back to normal mode from insert mode.
            if mode() == 'i'
              exe ':stopinsert'
            endif

            if getbufvar(bufnr('%'), '&filetype') == 'fzf'
              exe ':q'
            endif
        endfunction
      '';
    };
    "after/ftdetect/direnv.lua" = {
      extraConfigVim = ''
        autocmd BufNewFile,BufRead .envrc setfiletype direnv
      '';
    };
    # TODO: Are others from after/ftdetect/ (jinja, meta.yaml, tmpl) needed?

  };
  extraFiles = {
    "lua/nialov_utils.lua" = builtins.readFile ./lua/nialov_utils.lua;
  };
  extraConfigLua = ''
    vim.opt.diffopt:append("vertical")
    -- Resize window upon entering. VimResized does not seem to work?
    local resize = function()
    	vim.cmd(vim.api.nvim_replace_termcodes("wincmd =", true, true, true))
    end

    vim.api.nvim_create_autocmd({ "VimResized", "WinEnter" }, { pattern = "*", callback = resize })
    vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
  '';
  extraConfigVim = ''
    augroup enable_hl_search
        autocmd!
        autocmd! BufEnter * set hlsearch
    augroup end

    packadd cfilter
    set shortmess+=c
    set matchpairs+=<:> " use % to jump between pairs
    runtime! macros/matchit.vim
    set colorcolumn=+1
    set iskeyword+=-

    " Highlight yanked text
    augroup highlight_yank
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
    augroup END
  '';
  keymaps = [
    {
      key = "<leader>vo";
      action = "<cmd>only<CR>";
      options.desc = "Close all splits except current";
    }
    {
      key = "<leader>vp";
      action = "<cmd>set paste!<CR>";
      options.desc = "Set paste mode";
    }
    {
      key = "<leader>vq";
      action = "<cmd>Fidget clear<CR>";
      options.desc = "Dismiss all notifications";
    }
    {
      key = "<leader>ss";
      action = "<cmd>Startify<CR>";
      options.desc = "Open Startify";
    }
    {
      key = "<leader>nn";
      action.__raw = ''require("oil").open'';
      options.desc = "Open oil.nvim file browser";
    }
    {
      key = "<leader>dg";
      action = "<cmd>diffget<CR>";
      options.desc = "Get change from other buffer";
    }
    {
      key = "<leader>dp";
      action = "<cmd>diffput<CR>";
      options.desc = "Put change from this buffer";
    }

    {
      key = "<C-j>";
      action.__raw = ''
              	function()
                    local luasnip = require("luasnip")
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    end
        		end
      '';
      mode = [ "i" "s" ];
      options.desc = "Jump backwards in snippet";
    }
    {
      key = "<leader>we";
      action = "<cmd>WikiEntry<CR>";
      options.desc = "Open diary entry for editing";
    }
    {
      key = "<A-h>";
      action.__raw = "require('tmux').move_left";
    }
    {
      key = "<A-j>";
      action.__raw = "require('tmux').move_bottom";
    }
    {
      key = "<A-k>";
      action.__raw = "require('tmux').move_top";
    }
    {
      key = "<A-l>";
      action.__raw = "require('tmux').move_right";
    }

  ];
  extraPackages = lib.attrValues { inherit (pkgs) ripgrep pretty-task; };

  colorschemes.gruvbox = {
    enable = true;
    settings = {
      palette_overrides = {
        # bright_blue = "#5476b2";
        # bright_purple = "#fb4934";
        # dark1 = "#323232";
        # dark2 = "#383330";
        # dark3 = "#323232";
      };
      terminal_colors = true;
    };
  };
  diagnostics = {
    virtual_lines = { };
    virtual_text = true;
    update_in_insert = false;
  };
  plugins = {
    startify = {
      enable = true;
      settings = {
        custom_header = [
          ""
          "     ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
          "     ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
          "     ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
          "     ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
          "     ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
          "     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
        ];
        enable_unsafe = true;
        change_to_dir = false;

      };

    };
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = let
          srcList = [
            "async_path"
            "tmux"
            "nvim_lsp"
            # "nvim_lsp_signature_help"
            # TODO: Does biblio completion work? pandoc.nvim is recommended
            "cmp_pandoc"
            "spell"
            "fuzzy_buffer"
          ];
          srcWithConf = [
            {
              name = "luasnip";
              option = { use_show_condition = false; };
            }
            {
              name = "buffer";
              # option = { get_bufnrs = "vim.api.nvim_list_bufs"; };
            }
          ];
        in srcWithConf ++ (builtins.map (source: { name = source; }) srcList);
        mapping = {
          "<C-k>" = ''
            cmp.mapping(
              function(fallback)
                local luasnip = require('luasnip')
                if cmp.visible() then
                    if luasnip.expandable() then
                      luasnip.expand()
                    elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
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
              }),
              { 'i' }
            )
          '';
          "<C-x><C-f>" = ''
              cmp.mapping(
                  cmp.mapping.complete({
                    config = {
                      sources = cmp.config.sources({
                        { name = 'async_path' },
                      }),
                    },
              }),
              { 'i' }
            )
          '';
        };
        snippet = {
          expand =
            "function(args) require('luasnip').lsp_expand(args.body) end";
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
    cmp-ai.settings = {
      max_lines = 50;
      provider = "OpenAI";
      provider_options.model = "gpt-3.5-turbo";
      run_on_every_keystroke = false;
      ignored_file_types = { };
      notify = false;

    };
    treesitter = {
      enable = true;
      folding = true;
      indent = true;
      nixvimInjections = true;
      disabledLanguages = [
        "fugitive"
        "qf"
        "help"

      ];
      incrementalSelection = {
        enable = true;
        keymaps = {
          initSelection = "gnn";
          nodeDecremental = "grm";
          nodeIncremental = "grn";
          scopeIncremental = "grc";
        };
      };
      # TODO:
      # textobjects = {
      #   select = {
      #     enable = true;
      #     keymaps = {
      #       # -- You can use the capture groups defined in textobjects.scm
      #       "af" = "@function.outer";
      #       "if" = "@function.inner";
      #     };
      #   };

      # };
    };
    treesitter-textobjects = { enable = true; };
    notify = {
      enable = false;
      backgroundColour = "#000000";
    };
    fidget = {
      enable = true;
      notification = { overrideVimNotify = true; };
    };
    fzf-lua = {
      enable = true;
      keymaps = {
        "<C-f>" = {
          action = "files";
          options = {
            desc = "Fzf-Lua Files";
            silent = true;
          };
        };
        "<C-g>" = "live_grep";
        "<C-b>" = "buffers";
        # "gr" = "lsp_references";
        # "gd" = "lsp_definitions";
      };
      settings = {
        files = {
          color_icons = true;
          file_icons = true;
          # find_opts = {
          #   __raw =
          #     "[[-type f -not -path '*.git/objects*' -not -path '*.env*']]";
          # };
          multiprocess = true;
          prompt = "Files❯ ";
        };
        winopts = {
          col = 0.3;
          height = 0.4;
          row = 0.99;
          width = 0.93;
        };
      };

    };
    lualine = {
      enable = true;
      globalstatus = true;
      extensions = [ "fzf" "quickfix" "fugitive" "oil" ];
      sections = {
        lualine_b = [ "branch" "diff" "diagnostics" ];
        lualine_a = [ "mode" ];
        lualine_c = [{
          name = "filename";
          extraConfig = {
            file_status = true;
            newfile_status = true;
            path = 1;
            shorting_target = 60;
          };
        }];

        lualine_z = [ "location" ];
      };
      inactiveSections = {
        lualine_c = [ "filename" ];
        lualine_z = [ "location" ];
      };
    };
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        diagnostic = {
          "<leader>lj" = {
            action = "goto_next";
            desc = "Go to next diagnostic";
          };
          "<leader>lk" = {
            action = "goto_prev";
            desc = "Go to previous diagnostic";
          };
        };
        lspBuf = {
          K = "hover";
          gi = "implementation";
          gt = "type_definition";
        };
        extra = [
          {
            key = "<leader>lx";
            action = "<CMD>LspStop<Enter>";
          }
          {
            key = "<leader>ls";
            action = "<CMD>LspStart<Enter>";
          }
          {
            key = "<leader>lr";
            action = "<CMD>LspRestart<Enter>";
          }
          {
            key = "gd";
            action.__raw = "require('fzf-lua').lsp_definitions";
          }
          {
            key = "gr";
            action.__raw = "require('fzf-lua').lsp_references";
          }
          {
            key = "<leader>lD";
            action.__raw = "require('fzf-lua').diagnostics_workspace";
            options.desc = "Workspace diagnostics";
          }
          {
            key = "<leader>ld";
            action.__raw = "require('fzf-lua').diagnostics_document";
            options.desc = "Document diagnostics";
          }
          {
            mode = "n";
            key = "<leader>ll";
            action.__raw = "vim.lsp.codelens.refresh";
            options.desc = "LSP CodeLens refresh";
          }
          {
            mode = "n";
            key = "<leader>lL";
            action.__raw = "vim.lsp.codelens.run";
            options.desc = "LSP CodeLens run";
          }
        ];
      };
      servers = {
        pyright = {
          enable = true;
          settings = {

            pyright = { disableOrganizeImports = true; };
            python = {

              analysis = {
                autoImportCompletions = false;
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
                # -- openFilesOnly fixes very high cpu usage of pyright
                diagnosticMode = "openFilesOnly";
                # -- typeCheckingMode = "off",
              };
            };
          };
        };
        pylyzer = { enable = false; };
        ruff = { enable = true; };
        lua-ls = {
          enable = true;
          settings = {

            completion = {
              autoRequire = false;
              callSnippet = "Replace";
            };
            telemetry = { enable = false; };
            diagnostics = {
              globals = [ "vim" "describe" "before_each" "it" "assert" ];
            };
          };

        };
        # TODO: vimls.enable = true;
        yamlls = {
          enable = true;
          settings = { keyOrdering = false; };
        };
        nil-ls.enable = true;
        texlab.enable = true;
        rust-analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        bashls.enable = true;
      };
    };
    luasnip = {
      enable = true;
      fromLua = [{ paths = ./snippets; }];
    };
    oil = {
      enable = true;
      settings = {
        view_options.show_hidden = true;
        skip_confirm_for_simple_edits = true;
      };
    };
    lsp-format.enable = true;
    none-ls = {
      enable = true;
      enableLspFormat = true;
      # TODO: I do not want to format every filetype automatically
      # onAttach = "";
      sources = {
        diagnostics = {

          statix.enable = true;
          vint.enable = true;
          codespell.enable = true;
          selene.enable = true;
          rstcheck = {
            enable = true;
            withArgs = ''
              { extra_args = { "--ignore-directives", "mermaid" }, }
            '';
          };
          proselint = {
            enable = true;
            withArgs = ''
              {
                extra_filetypes = { "rst", "pandoc" },
                timeout = 2000,
                method = require("null-ls").methods.DIAGNOSTICS_ON_SAVE,
              }

            '';
          };
        };
        formatting = {

          nixfmt.enable = true;
          stylua.enable = true;
          black.enable = true;
          isort = {
            enable = true;
            withArgs = ''
              { extra_args = { "--profile", "black" }, }
            '';
          };
          prettier = {
            enable = true;
            withArgs = ''
              { disabled_filetypes = { "pandoc", "markdown" }, }
            '';

          };
          shfmt.enable = true;

        };
        code_actions = { gitsigns.enable = true; };
      };
    };
    nvim-autopairs = {
      enable = true;
      settings = {
        disable_filetype = [ "rst" ];
        check_ts = true;
      };
    };
    # tmux-navigator = {
    #   enable = true;
    #   settings.no_mappings = true;
    #   keymaps = [
    #     {
    #       action = "left";
    #       key = "<A-h>";
    #     }
    #     {
    #       action = "down";
    #       key = "<A-j>";
    #     }
    #     {
    #       action = "up";
    #       key = "<A-k>";
    #     }
    #     {
    #       action = "right";
    #       key = "<A-l>";
    #     }
    #   ];
    # };
    telescope = { enable = true; };
    which-key = {
      enable = true;
      registrations = {
        "<leader>l" = { name = "lsp"; };
        "<leader>g" = { name = "git"; };
        "<leader>d" = { name = "diff"; };
        "<leader>s" = { name = "startify"; };
        "<leader>v" = { name = "vim"; };
        "<leader>w" = { name = "wiki"; };
        "<leader>n" = { name = "oil.nvim"; };
      };
    };
    fugitive.enable = true;
    friendly-snippets.enable = true;
    rainbow-delimiters.enable = true;
    surround.enable = true;
    commentary.enable = true;
    gitblame = { enable = true; };
    gitsigns = { enable = true; };
  };

  extraPlugins = let
    noConfigPlugins = with pkgs.vimPlugins; [
      neodev-nvim
      vim-rooter
      vim-numbertoggle
      vim-eunuch
      vim-repeat
      vim-abolish
      nui-nvim
      vim-pandoc-syntax
    ];

  in noConfigPlugins ++ [

    {
      plugin = pkgs.vimPlugins.vim-dispatch;
      config = ''
        let g:dispatch_no_tmux_make = 1
        let g:dispatch_no_tmux_start = 1
      '';
    }
    {
      plugin = pkgs.vimPlugins.tmux-nvim;
      config = ''
        lua << EOF
        require("tmux").setup({
        	-- overwrite default configuration
        	-- here, e.g. to enable default bindings
        	copy_sync = {
        		-- enables copy sync and overwrites all register actions to
        		-- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
        		enable = true,
        		redirect_to_clipboard = true,
        		sync_clipboard = true,
        		-- Stop SyncRegisters slowdown (maybe)
        		sync_registers = true,
        		register_offset = 9,
        		sync_unnamed = true,
        		sync_deletes = true,
        	},
        	navigation = {
        		-- enables default keybindings (C-hjkl) for normal mode
        		enable_default_keybindings = false,
        	},
        	resize = {
        		-- enables default keybindings (A-hjkl) for normal mode
        		enable_default_keybindings = false,
        	},
        })
        EOF
      '';
    }
    {
      plugin = pkgs.vimPlugins.vim-pandoc;
      config = ''
        let g:pandoc#completion#bib#mode = 'fallback'
        let g:pandoc#syntax#conceal#use = 0
        let g:pandoc#folding#level = 4
        let g:pandoc#hypertext#use_default_mappings = 0
        let g:pandoc#keyboard#use_default_mappings = 0
        let g:pandoc#keyboard#display_motions = 0
        augroup PandocAugroup
            autocmd!
            autocmd BufEnter *.md setlocal omnifunc=pandoc#completion#Complete
        augroup END
      '';
    }
  ];

}
