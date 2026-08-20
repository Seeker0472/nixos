{ lib, ... }:
let
  normalMap = key: action: desc: {
    mode = "n";
    inherit key action;
    options = {
      inherit desc;
      silent = true;
    };
  };
in
{
  keymaps = [
    (normalMap "<Esc>" "<cmd>nohlsearch<cr>" "Clear search highlight")
    (normalMap "<leader>w" "<cmd>write<cr>" "Write buffer")
    (normalMap "<leader>q" "<cmd>confirm quit<cr>" "Quit window")
    (normalMap "<leader>Q" "<cmd>confirm qall<cr>" "Quit Neovim")

    (normalMap "<C-h>" "<C-w>h" "Focus left window")
    (normalMap "<C-j>" "<C-w>j" "Focus lower window")
    (normalMap "<C-k>" "<C-w>k" "Focus upper window")
    (normalMap "<C-l>" "<C-w>l" "Focus right window")
    (normalMap "<leader>-" "<cmd>split<cr>" "Split below")
    (normalMap "<leader>|" "<cmd>vsplit<cr>" "Split right")

    (normalMap "[b" "<cmd>bprevious<cr>" "Previous buffer")
    (normalMap "]b" "<cmd>bnext<cr>" "Next buffer")
    {
      mode = "n";
      key = "<leader>bd";
      action = lib.nixvim.mkRaw ''
        function()
          require("mini.bufremove").delete(0, false)
        end
      '';
      options = {
        desc = "Delete buffer";
        silent = true;
      };
    }

    {
      mode = "x";
      key = "J";
      action = "<cmd>move '>+1<cr>gv=gv";
      options = {
        desc = "Move selection down";
        silent = true;
      };
    }
    {
      mode = "x";
      key = "K";
      action = "<cmd>move '<-2<cr>gv=gv";
      options = {
        desc = "Move selection up";
        silent = true;
      };
    }
    {
      mode = "x";
      key = "<";
      action = "<gv";
      options = {
        desc = "Indent selection left";
        silent = true;
      };
    }
    {
      mode = "x";
      key = ">";
      action = ">gv";
      options = {
        desc = "Indent selection right";
        silent = true;
      };
    }
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options = {
        desc = "Enter terminal normal mode";
        silent = true;
      };
    }
  ];
}
