# From: https://github.com/tcpkump/nixvim/blob/main/config/chatgpt.nix
{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "gp";
      src = pkgs.fetchFromGitHub {
        owner = "Robitx";
        repo = "gp.nvim";
        rev = "52938ffbd47b5e06d0f9b7c8b146f26d6021fbac";
        hash = "sha256-nowrrgdRxxJ81xsmuUYKsbPNLTGVKO6KbSpU0U98lWE=";
      };
    })
  ];

  extraConfigLua = ''
    require('gp').setup({
        hooks = {
            -- example of adding command which opens new chat dedicated for translation
            Translator = function(gp, params)
                local chat_system_prompt = "You are a Translator, please translate between English and Finnish depending on the source language."
                gp.cmd.ChatNew(params, chat_system_prompt, gp.get_chat_agent("ChatGPT4o"))
            end,
        },
    })
  '';

  keymaps = [
    {
      key = "<leader>ac";
      action = "<cmd>GpChatToggle vsplit<cr>";
      options = {
        desc = "ChatGPT";
      };
    }

    {
      key = "<leader>au";
      action = "<cmd>GpChatStop<cr>";
      options = {
        desc = "ChatGPT Stop";
      };
    }

    {
      key = "<leader>an";
      action = "<cmd>GpChatNew<cr>";
      options = {
        desc = "ChatGPT New Chat";
      };
    }

    {
      key = "<leader>ad";
      action = "<cmd>GpChatDelete<cr>";
      options = {
        desc = "ChatGPT Delete Chat";
      };
    }

    {
      key = "<leader>aa";
      action = "<cmd>GpChatRespond<cr>";
      options = {
        desc = "ChatGPT Send Message";
      };
    }

    {
      key = "<leader>af";
      action = "<cmd>GpChatFinder<cr>";
      options = {
        desc = "ChatGPT Find Chat";
      };
    }

    {
      mode = "v";
      key = "<leader>ap";
      action = "<cmd>'<,'>GpChatPaste<cr>";
      options = {
        desc = "ChatGPT Paste Selection to Chat";
      };
    }
  ];
}
