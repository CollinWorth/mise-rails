namespace :images do
  desc "Make the card and hero versions of every recipe photo now, so nobody waits for them on the first view"
  task variants: :environment do
    prepared = 0
    Recipe.with_attached_image.find_each do |recipe|
      next unless recipe.image.attached? && recipe.image.variable?

      %i[card hero].each { |name| recipe.image.variant(name).processed }
      prepared += 1
    rescue ActiveStorage::FileNotFoundError, Vips::Error => error
      warn "Skipped #{recipe.name.inspect}: #{error.message}"
    end
    puts "Prepared #{prepared} photos."
  end
end
