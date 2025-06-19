{ pkgs, ... }:
let
  inherit (pkgs) lib;

in
{
  imports = [
    ./plugins/gp.nix
    # ./plugins/cmp.nix
    ./plugins/blink-cmp.nix
  ];
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
    # completeopt = "menu,menuone,noselect";
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
    # Set default sql syntax
    sql_type_default = "postgresql";

  };
  autoCmd = [
    # {
    #   callback.__raw = ''
    #     function ()
    #       local disable_env_variable_name = "NEOVIM_DISABLE_AUTOFORMAT"
    #       local disable_autoformat = vim.tbl_contains(vim.tbl_keys(vim.fn.environ()), disable_env_variable_name)
    #       if disable_autoformat then
    #           vim.cmd([[ FormatDisable ]])
    #           vim.notify(
    #               string.format(
    #                   "Would enable auto-formatting for buffer but environment variable %s exists.",
    #                   disable_env_variable_name
    #               )
    #           )
    #       else
    #           vim.cmd([[ FormatEnable ]])
    #           vim.notify("Enabled auto-formatting for buffer.")
    #       end
    #     end
    #   '';
    #   event = [ "FileReadPost" ];
    #   pattern = [ "*" ];
    # }
    {
      event = [
        "VimResized"
        "WinEnter"
        "FocusGained"
      ];
      pattern = [ "*" ];
      command = "wincmd =";
    }
    # {
    #   event = "BufWritePre";
    #   callback.__raw = ''
    #     function()
    #       local disable_env_variable_name = "NEOVIM_DISABLE_AUTOFORMAT"
    #       local disable_autoformat = vim.tbl_contains(vim.tbl_keys(vim.fn.environ()), disable_env_variable_name)
    #       if disable_autoformat then
    #           vim.notify(
    #               string.format(
    #                   "Not formatting as environment variable %s exists.",
    #                   disable_env_variable_name
    #               )
    #           )
    #       else
    #           vim.lsp.buf.format({ timeout_ms = 2000 })
    #       end
    #     end
    #   '';
    # }
    # {
    #   event = [ "FocusLost" ];
    #   pattern = [ "*" ];
    #   callback.__raw = ''
    #     function ()
    #         vim.cmd [[
    #             " Save when losing focus.
    #             exe ':silent! update'

    #             " Go back to normal mode from insert mode.
    #             if mode() == 'i'
    #               exe ':stopinsert'
    #             endif

    #             if getbufvar(bufnr('%'), '&filetype') == 'fzf'
    #               exe ':q'
    #             endif
    #         ]]

    #     end

    #   '';
    # }
  ];
  userCommands = {
    "WikiEntry" = {
      command.__raw = "require('nialov_utils').wikientry";
      desc = "Open personal wiki entry";
    };
    "Format" = {
      # command.__raw = "vim.lsp.buf.format";
      nargs = "?";
      command.__raw = ''
        function (opts)
          if not opts.args or opts.args == "" or opts.args == "lsp" then
            vim.lsp.buf.format()
          elseif opts.args == "pre-commit" then
            if vim.bo.modified then
              vim.cmd("write")
            end
            local result = vim.fn.system("pre-commit run --files " .. vim.fn.expand("%"))
            vim.notify(result)
            vim.cmd("edit")
          else
            vim.notify("Unknown format type: " .. opts.args, vim.log.levels.ERROR)
          end
        end
      '';
      complete.__raw = ''
        function ()
          return { "lsp", "pre-commit" }
        end
      '';
      desc = "Format current buffer using lsp or pre-commit";
    };
    # "PreCommit" = {
    #   command.__raw = ''
    #     function ()
    #         if vim.bo.modified
    #             vim.cmd("write")
    #         end
    #         local result = vim.fn.system("pre-commit run --files " .. vim.fn.expand("%"))
    #         vim.notify(result)
    #     end
    #   '';
    #   desc = "Format current buffer using pre-commit";
    # };

  };
  files = {
    "after/ftplugin/fish.lua" = {
      localOpts.commentstring = "#%s";
    };
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
        # spelllang = "en";
        shiftwidth = 3;
        softtabstop = -1;
        tabstop = 3;
        expandtab = true;
      };
      keymaps = [
        # Rebind wrap to equalprg
        {
          mode = [ "n" ];
          key = "gw";
          action = "=";
          options = {
            silent = true;
            buffer = true;
          };
        }
        {
          mode = [ "v" ];
          key = "gw";
          action = "=";
          options = {
            silent = true;
            buffer = true;
          };
        }
      ];
      extraConfigVim = ''
        setlocal suffixesadd+=.rst
        setlocal suffixes+=.rst
        nmap <buffer> <silent> gw gq
      '';
    };
    "after/ftdetect/direnv.lua" = {
      extraConfigVim = ''
        autocmd BufNewFile,BufRead .envrc setfiletype direnv
      '';
    };
    # TODO: Are others from after/ftdetect/ (jinja, meta.yaml, tmpl) needed?
    "after/ftplugin/python.lua" = {
      # autoCmd = [{
      #   event = "BufWritePre";
      #   callback.__raw = ''
      #     function()
      #       vim.lsp.buf.code_action {
      #         context = {only = {"source.fixAll.ruff"}},
      #         apply = true
      #       }
      #     end
      #   '';
      # }];
    };

  };
  extraFiles = {
    "lua/nialov_utils.lua".source = ./lua/nialov_utils.lua;
  };
  extraConfigLua = ''
    vim.opt.diffopt:append("vertical")
    -- Resize window upon entering. VimResized does not seem to work?
    local resize = function()
    	vim.cmd(vim.api.nvim_replace_termcodes("wincmd =", true, true, true))
    end

    vim.api.nvim_create_autocmd({ "VimResized", "WinEnter" }, { pattern = "*", callback = resize })
  '';
  # vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
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

    function! SetSpellLang()
        let l:spelllang = matchstr(expand('%:t'), '\.\zs[^.]*\ze\..*$')
        if !empty(l:spelllang)
            call nvim_notify('Spelllang solving found: ' . l:spelllang, 2, {})
            if strlen(l:spelllang) > 2
                return
            endif
            execute 'silent! setlocal spelllang=' . l:spelllang
        endif
    endfunction
    autocmd BufRead,BufNewFile * call SetSpellLang()
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
    # {
    #   key = "<leader>ss";
    #   action = "<cmd>Startify<CR>";
    #   options.desc = "Open Startify";
    # }
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
      mode = [
        "i"
        "s"
      ];
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
    {
      key = "<leader>gg";
      action = "<cmd>Git<CR>";
      options.desc = "Open vim-fugitive git menu";
    }
    {
      key = "<leader>qn";
      action = "<cmd>cnext<CR>";
      options.desc = "Go to next quickfix error";
    }
    {
      key = "<leader>qp";
      action = "<cmd>cprevious<CR>";
      options.desc = "Go to previous quickfix error";
    }
    {
      key = "<leader>ql";
      # action = "<cmd>Dispatch pre-commit run --files %<CR>";
      action.__raw = ''
        function() 
            vim.cmd [[ Dispatch pre-commit run --files % ]]
        end
      '';
      options.desc = "Run pre-commit check on current file";
    }
    {
      key = "<leader>qq";
      action = "<cmd>cfile<CR>";
      options.desc = "Open quickfix";
    }

  ];
  extraPackages = lib.attrValues {
    inherit (pkgs)
      ripgrep
      pretty-task
      # ctags-lsp
      ;
    # TODO: pandoc 3.6 includes rst regressions
    inherit (pkgs.release2411Packages) pandoc;
  };

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
  diagnostic.settings = {
    virtual_lines = {
      current_line = true;
    };
    virtual_text = false;
    update_in_insert = false;
  };
  plugins = {
    startify = {
      enable = false;
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
    treesitter = {
      enable = true;
      folding = true;
      nixvimInjections = true;
      # disabledLanguages = [
      #   "fugitive"
      #   "qf"
      #   "help"

      # ];
      settings = {
        highlight = {
          enable = true;
          disable = [
            "fugitive"
            "qf"
            "help"
          ];
        };
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "gnn";
            node_decremental = "grm";
            node_incremental = "grn";
            scope_incremental = "grc";
          };
          indent = true;
        };
      };
      # incrementalSelection = {
      #   enable = true;
      #   keymaps = {
      #     initSelection = "gnn";
      #     nodeDecremental = "grm";
      #     nodeIncremental = "grn";
      #     scopeIncremental = "grc";
      #   };
      # };
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
    treesitter-textobjects = {
      enable = true;
    };

    notify = {
      enable = false;
      settings.background_colour = "#000000";
    };
    fidget = {
      enable = true;
      settings.notification.override_vim_notify = true;
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
        "<C-g>" = "grep_project";
        "<C-b>" = "buffers";
        "<C-x><C-f>" = {
          action = "complete_path";
          mode = [
            "i"
            "s"
          ];
          options = {
            desc = "Fzf-Lua path completion";
            silent = true;
          };
        };
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
        grep = { };
        winopts = {
          col = 0.3;
          height = 0.4;
          row = 0.99;
          width = 0.93;
          # Default preview width is 60 % of fzf-lua popup window
          # This hides file info in the search split
          preview.horizontal = "right:45%";
        };
      };

    };
    lualine = {
      enable = true;
      settings = {
        globalstatus = false;
        extensions = [
          "fzf"
          "quickfix"
          "fugitive"
          "oil"
        ];
        sections = {
          lualine_b = [
            "branch"
            "diff"
            "diagnostics"
          ];
          lualine_a = [ "mode" ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              file_status = true;
              newfile_status = true;
              path = 1;
              shorting_target = 60;
            }
          ];

          lualine_x = [
            # {
            #   __unkeyed-1.__raw = ''
            #     function ()
            #         local lsp_format = require("lsp-format")
            #         if lsp_format.disabled then
            #             return "Autoformat (off)"
            #         end
            #         return "Autoformat (on)"
            #     end
            #   '';
            #   color.__raw = ''
            #     function (section)
            #         if require("lsp-format").disabled then
            #             return { fg = "#aa3355" }
            #         end
            #         return { fg = "#33aa88" }
            #     end
            #   '';
            # }
            # Copied from nixvim examples:
            "diagnostics"
            {
              __unkeyed-1.__raw = ''
                function()
                    local msg = ""
                    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                    local clients = vim.lsp.vim.lsp.get_clients()
                    if next(clients) == nil then
                        return msg
                    end
                    for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                        end
                    end
                    return msg
                end
              '';
              icon = "";
              color.fg = "#ffffff";
            }
            "encoding"
            "fileformat"
            "filetype"

          ];
          lualine_z = [ "location" ];
        };
        inactive_sections = {
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              # Absolute path, with tilde as the home directory
              path = 3;
            }
          ];
          lualine_z = [ "location" ];
        };
      };
    };
    lsp = {
      enable = true;
      # See <leader>li keymap for toggle
      inlayHints = true;

      # Disable or enable capability for a server:
      onAttach = ''
        if client.name == "pylsp" then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
        if client.name == "basedpyright" then
          client.flags = { debounce_text_changes = 300 }
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
        if client.name == "ruff" then
          client.server_capabilities.documentFormattingProvider = true
        end
      '';

      preConfig = ''
        vim.diagnostic.config({
          severity_sort = true,
          float = {
            border = 'rounded',
            source = 'always',
          },
        })

        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
          vim.lsp.handlers.hover,
          {border = 'rounded'}
        )

        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
          vim.lsp.handlers.signature_help,
          {border = 'rounded'}
        )

        vim.lsp.handlers["textDocument/diagnostic"] = vim.lsp.with(
          vim.lsp.diagnostic.on_diagnostic, {
            -- Enable underline, use default values
            underline = true,
            -- Enable virtual text, override spacing to 4
            --  virtual_text = {
              -- spacing = 4,
            -- },
            -- Disable a feature
            update_in_insert = false,
          }
        )
      '';
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
          "<leader>crn" = "rename";
          "<leader>la" = "code_action";
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
            key = "<leader>la";
            action.__raw = "require('fzf-lua').lsp_code_actions";
            options.desc = "LSP code actions";
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
          {
            mode = "n";
            key = "<leader>li";
            action.__raw = ''
              function ()
                  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
              end
            '';
            options.desc = "Toggle inlay hints";
          }
        ];
      };
      servers = {
        # pyright = {
        #   enable = true;
        #   settings = {

        #     pyright = { disableOrganizeImports = true; };
        #     python = {

        #       analysis = {
        #         autoImportCompletions = false;
        #         autoSearchPaths = true;
        #         useLibraryCodeForTypes = true;
        #         # -- openFilesOnly fixes very high cpu usage of pyright
        #         diagnosticMode = "openFilesOnly";
        #         # -- typeCheckingMode = "off",
        #       };
        #     };
        #   };
        # };
        basedpyright = {
          enable = true;
          extraOptions.settings = {

            basedpyright = {
              disableOrganizeImports = true;
              analysis = {
                autoImportCompletions = false;
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
                # -- openFilesOnly fixes very high cpu usage of pyright
                diagnosticMode = "openFilesOnly";
                # -- typeCheckingMode = "off",
                typeCheckingMode = "standard";
                inlayHints.callArgumentNames = false;
                # Exclude paths from analysis, most importantly, nix "result" paths
                exclude = [
                  "result*"
                  ".cache"
                  ".direnv"
                  ".git"
                  ".mypy_cache"
                  ".pytest_cache"
                  ".ruff_cache"
                  ".venv"
                  "dist"
                  ".mamba"
                  ".conda"
                  "__pycahe__"
                ];
              };
            };
          };
          # onAttach.function = "\n";
        };
        pylyzer = {
          enable = false;
        };

        pylsp = {
          enable = false;
          extraOptions.settings.pylsp.plugins = {
            jedi_completion = {
              enabled = true;
              fuzzy = true;
            };
            # pylsp_mypy = {
            #   enabled = true;
            #   dmypy = true;
            #   live_mode = false;
            # };

            # We don't need those as ruff is already providing such features.
            flake8.enabled = false;
            mccabe.enabled = false;
            preload.enabled = false;
            pycodestyle.enabled = false;
            pydocstyle.enabled = false;
            pyflakes.enabled = false;
            pylint.enabled = false;
            ruff.enabled = false;
            yapf.enabled = false;
            # plugins.pylsp_mypy.enabled = true;
          };
        };
        ruff = {
          enable = true;
          extraOptions = {
            init_options = {
              settings = {
                logLevel = "debug";
                configurationPreference = "filesystemFirst";
                lint = {
                  enable = true;
                };
              };
            };

          };
        };
        lua_ls = {
          enable = true;
          settings = {

            completion = {
              autoRequire = false;
              callSnippet = "Replace";
            };
            telemetry = {
              enable = false;
            };
            diagnostics = {
              globals = [
                "vim"
                "describe"
                "before_each"
                "it"
                "assert"
              ];
            };
          };

        };
        # TODO: vimls.enable = true;
        yamlls = {
          enable = true;
          settings = {
            keyOrdering = false;
          };
        };
        nil_ls = {
          enable = true;
          # https://github.com/oxalica/nil/blob/main/docs/configuration.md
          extraOptions.settings = {
            nil.nix.flake.autoArchive = false;
          };
        };
        texlab = {
          enable = true;
          extraOptions.settings = {

            texlab = {
              inlayHints = {
                labelDefinitions = false;
                labelReferences = false;
                maxLength = 5;
              };
            };
          };
        };
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
        bashls.enable = true;
      };
    };
    luasnip = {
      enable = true;
      fromLua = [ { paths = ./snippets; } ];
    };
    oil = {
      enable = true;
      settings = {
        view_options.show_hidden = true;
        skip_confirm_for_simple_edits = true;
      };
    };
    none-ls = {
      enable = true;
      enableLspFormat = false;
      settings = {
        update_in_insert = false;
      };
      # TODO: I do not want to format every filetype automatically
      # onAttach = "";
      sources = {
        diagnostics = {

          mypy = {
            enable = true;
            settings = {
              extra_args = [ "--check-untyped-defs" ];
            };

          };
          statix.enable = true;
          vint.enable = true;
          codespell.enable = true;
          selene.enable = true;
          rstcheck = {
            enable = true;
            settings = {
              extra_args = [
                "--ignore-directives"
                "mermaid"
              ];
            };
          };
          proselint = {
            enable = true;
            settings = {
              extra_filetypes = [
                "rst"
                "pandoc"
              ];
              timeout = 2000;
              # method.__raw = "require('null-ls').methods.DIAGNOSTICS_ON_SAVE";
            };
          };
          sqlfluff = {
            enable = true;
            # dialect can be specified by .sqlfluff file in the directory of sql file
            # settings = { extra_args = [ "--dialect" "postgres" ]; };
          };
        };
        formatting = {

          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          stylua.enable = true;
          # black.enable = true;
          # isort = {
          #   enable = true;
          #   settings = { extra_args = [ "--profile" "black" ]; };
          # };
          prettier = {
            enable = true;
            settings = {
              disabled_filetypes = [
                "pandoc"
                "markdown"
              ];
            };

          };
          shfmt.enable = true;

        };
        code_actions = {
          gitsigns.enable = true;
        };
      };
    };
    nvim-autopairs = {
      enable = true;
      settings = {
        disable_filetype = [ "rst" ];
        check_ts = true;
      };
    };
    # lsp-format = {
    #   enable = true;
    #   settings = { sync = true; };
    # };
    telescope = {
      enable = true;
      # enabledExtensions = [ ];
      keymaps = {
        "<leader>ts" = {
          action = "symbols";
          options = {
            desc = "Telescope emojis and symbols";
          };
        };
      };
    };
    which-key = {
      enable = true;
      settings.spec = [
        {
          __unkeyed-1 = "<leader>l";
          group = "lsp";
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "git";
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "diff";
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "startify";
        }
        {
          __unkeyed-1 = "<leader>v";
          group = "vim";
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "wiki";
        }
        {
          __unkeyed-1 = "<leader>n";
          group = "oil.nvim";
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "lsp;";
        }
        {
          __unkeyed-1 = "<leader>a";
          group = "ai;";
        }
        {
          __unkeyed-1 = "<leader>t";
          group = "telescope";
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "quickfix";
        }

      ];
    };
    chatgpt = {
      enable = false;
      settings = {
        keymaps = {
          submit = "<C-s>";
        };
      };

    };
    fugitive.enable = true;
    friendly-snippets.enable = true;
    rainbow-delimiters.enable = true;
    vim-surround.enable = true;
    commentary.enable = true;
    gitblame = {
      enable = true;
    };
    gitsigns = {
      enable = true;
    };
    web-devicons = {
      enable = true;
    };
    # https://github.com/nomnivore/ollama.nvim/tree/main
    # https://nix-community.github.io/nixvim/plugins/ollama/index.html
    ollama = {
      enable = true;
      action = "display";
      model = "llama3.2:latest";
      url = "https://ollama.novaskai.xyz";

    };

  };

  extraPlugins =
    let
      noConfigPlugins = with pkgs.vimPlugins; [
        neodev-nvim
        vim-rooter
        vim-numbertoggle
        vim-eunuch
        vim-repeat
        vim-abolish
        nui-nvim
        vim-pandoc-syntax
        telescope-symbols-nvim
      ];

    in
    noConfigPlugins
    ++ [

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
      # {
      #   plugin = pkgs.vimPlugins.ctags-lsp-nvim;
      #   config = ''
      #     lua << EOF
      #     require("lspconfig").ctags_lsp.setup({ })
      #     EOF
      #   '';
      # }

    ];

}
