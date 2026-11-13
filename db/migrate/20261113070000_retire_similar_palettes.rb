class RetireSimilarPalettes < ActiveRecord::Migration[8.1]
  # These four looked too much like Ember and Autumn Harvest; anyone using one moves to the default.
  RETIRED = %w[terracotta pastel amber spruce].freeze

  def up
    execute "UPDATE users SET palette = 'ember' WHERE palette IN (#{RETIRED.map { |key| connection.quote(key) }.join(', ')})"
  end

  def down
    # nothing to restore: the old choice was not kept
  end
end
