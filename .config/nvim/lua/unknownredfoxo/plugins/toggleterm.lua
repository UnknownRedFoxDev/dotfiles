return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 15, -- Height of the split window
                open_mapping = [[<c-\>]], -- Ctrl + \ toggles the window open/closed
                direction = 'horizontal', -- Can be 'horizontal', 'vertical', or 'float'
            })
        end
    },
}
