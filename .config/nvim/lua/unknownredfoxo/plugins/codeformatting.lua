return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
            },
            formatters = {
                clang_format = {
                    prepend_args = {
                        "--style={                                            \
                            BasedOnStyle: llvm,                               \
                            IndentWidth: 4,                                   \
                            ColumnLimit: 128,                                 \
                            AllowShortIfStatementsOnASingleLine: OnlyFirstIf, \
                            AllowShortBlocksOnASingleLine: Empty,             \
                            AllowShortFunctionsOnASingleLine: None,           \
                            AllowShortLoopsOnASingleLine: true,               \
                            BinPackArguments: true,                          \
                            MaxEmptyLinesToKeep: 1,                           \
                            AlignAfterOpenBracket: true,                      \
                            SpaceBeforeParens: ControlStatements,             \
                            AlwaysBreakAfterReturnType: Automatic,            \
                            BreakBeforeBraces: Linux,                         \
                            PenaltyReturnTypeOnItsOwnLine: 1,                 \
                            AlignConsecutiveMacros: {                         \
                                Enabled: false,                               \
                            },                                                \
                            AlignEscapedNewlines: LeftWithLastLine,           \
                            PointerAlignment: Right,                          \
                            ContinuationIndentWidth: 4,                       \
                            IndentCaseLabels: false                           \
                        }",
                    },
                },
            },
        },
    },
}
