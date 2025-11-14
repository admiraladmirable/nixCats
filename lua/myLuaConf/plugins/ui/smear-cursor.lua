return {
  {
    'smear-cursor-nvim',
    for_cat = { cat = 'general', default = true },
    event = 'DeferredUIEnter',
    after = function(plugin, opts)
      require('smear_cursor').setup {
        stiffness = 0.8,
        trailing_stiffness = 0.6,
        stiffness_insert_mode = 0.7,
        trailing_stiffness_insert_mode = 0.7,
        distance_stop_animating = 0.5,
      }
    end,
  },
}
