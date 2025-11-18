return {
  {
    'diffview',
    for_cat = { cat = 'general', default = true },
    event = 'DeferredUIEnter',
    after = function(plugin, opts)
      require('diffview').setup {}
    end,
  },
}
