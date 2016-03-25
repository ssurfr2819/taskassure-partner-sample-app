# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.01'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
#Rails.application.config.assets.precompile += %w( jquery-1.5.2.min.js )
Rails.application.config.assets.precompile += %w( jquery.validate.min.js ) 
Rails.application.config.assets.precompile += %w( validation.js )
Rails.application.config.assets.precompile += %w( jquery.tokeninput.js )
Rails.application.config.assets.precompile += %w( facebox.js )
Rails.application.config.assets.precompile += %w( lightbox.css )
Rails.application.config.assets.precompile += %w( lightbox1.js )
Rails.application.config.assets.precompile += %w( jcarousellite_1.0.1c5.js )
Rails.application.config.assets.precompile += %w( token-input.css )
Rails.application.config.assets.precompile += %w( facebox.css )
Rails.application.config.assets.precompile += %w( transition.js )
Rails.application.config.assets.precompile += %w( tooltip.js )
Rails.application.config.assets.precompile += %w( popover.js )
Rails.application.config.assets.precompile += %w( bootstrap-datetimepicker.js )
Rails.application.config.assets.precompile += %w( bootstrap-datetimepicker.min.css )
Rails.application.config.assets.precompile += %w( copyvalidation.js )
