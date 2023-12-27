local formatters = {
    lua = function(text_inside, text_var)
        if not text_var then
            return string.format('print("%s")', text_inside)
        end
        return string.format('print("%s =", %s)', text_inside, text_var)
        -- for nvim stuff
        -- return string.format('print([[%s: ]] .. vim.inspect(%s))', text_inside, text_var)
    end,

    python = function(text_inside, text_var)
        if not text_var then
            return string.format("print(%s)", text_inside)
        end
        return string.format('print("%s =", {%s})', text_inside, text_var)
    end,

    javascript = function(text_inside, text_var)
        if not text_var then
            return string.format('console.warn("%s")', text_inside)
        end
        return string.format('console.warn("%s=", %s)', text_inside, text_var)
    end,

    typescript = function(text_inside, text_var)
        if not text_var then
            return string.format('console.warn("%s")', text_inside)
        end
        return string.format('console.warn("%s=", %s)', text_inside, text_var)
    end,

    go = function(text_inside, text_var)
        if not text_var then
            return string.format('fmt.Println("%s")', text_inside)
        end
        return string.format('fmt.Println("%s = ", %s)', text_inside, text_var)
    end,

    vim = function(text_inside, text_var)
        if not text_var then
            return string.format('echo "%s', text_inside)
        end
        return string.format('echo "%s = ".%s', text_inside, text_var)
    end,

    rust = function(text_inside, text_var)
        if not text_var then
            return string.format([[println!("%s);]], text_inside)
        end
        return string.format([[println!("%s = {:#?}", %s);]], text_inside, text_var)
    end,

    zsh = function(text_inside, text_var)
        if not text_var then
            return string.format('echo "%s"', text_inside)
        end
        return string.format('echo "%s = $%s"', text_inside, text_var)
    end,

    bash = function(text_inside, text_var)
        if not text_var then
            return string.format('echo "%s"', text_inside)
        end
        return string.format('echo "%s = $%s"', text_inside, text_var)
    end,

    sh = function(text_inside, text_var)
        if not text_var then
            return string.format('echo "%s"', text_inside)
        end
        return string.format('echo "%s = $%s"', text_inside, text_var)
    end,

    java = function(text_inside, text_var)
        if not text_var then
            return string.format('System.out.println("%s");', text_var)
        end
        return string.format('System.out.println("%s = " + %s);', text_inside, text_var)
    end,

    cs = function(text_inside, text_var)
        if not text_var then
            return string.format('System.Console.WriteLine("%s");', text_var)
        end
        return string.format(
            'System.Console.WriteLine("%s = " + %s);',
            text_inside,
            text_var
        )
    end,

    cpp = function(text_inside, text_var)
        if not text_var then
            return string.format('std::cout << "%s" << std::endl;', text_var)
        end
        return string.format(
            'std::cout << "%s = " << %s << std::endl;',
            text_inside,
            text_var
        )
    end,

    ruby = function(text_inside, text_var)
        if not text_var then
            return string.format('pp "%s"', text_inside)
        end
        return string.format('pp "%s = ", %s', text_inside, text_var)
    end,
}

return formatters
