# Stub file to conform gem name (rb-readline)
# It forces require of bundled readline instead of any already existing
# in your Ruby installation. It will avoid any possible warning caused
# by double require.
unless $LOADED_FEATURES.any? { |f| f =~ /readline\.rb$/ }
  require File.join(File.dirname(__FILE__), 'readline')
end
