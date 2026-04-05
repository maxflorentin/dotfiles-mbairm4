return {
  "Maxteabag/sqlit",
  cmd = {
    "Sqlit",
    "SqlitQuery",
    "SqlitConnections",
  },
  opts = {
    -- Configuración por defecto de sqlit
    -- El plugin usa las mismas conexiones que vim-dadbod si están disponibles
    keybindings = {
      -- Puedes personalizar los keybindings aquí si el plugin lo soporta
    },
  },
  keys = {
    -- Atajos de teclado para abrir sqlit rápidamente
    { "<leader>sq", "<cmd>Sqlit<cr>", desc = "Open Sqlit" },
    { "<leader>sc", "<cmd>SqlitConnections<cr>", desc = "Sqlit Connections" },
  },
  config = function(_, opts)
    -- Configuración adicional si es necesaria
    if opts then
      -- Aquí irían configuraciones específicas
    end
  end,
}
