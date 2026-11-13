namespace :import do
  desc "Replace all data with a mongodump of the old Mise (DIR=path/to/cookindb [UPLOADS=path] [IMAGES=0] [CONFIRM=wipe])"
  task mongo: :environment do
    dir = ENV["DIR"] or abort "Give the dump folder: bin/rails import:mongo DIR=path/to/cookindb"
    abort "Not a folder: #{dir}" unless File.directory?(dir)
    abort "This replaces everything in the #{Rails.env} database. Run again with CONFIRM=wipe to go ahead." if Rails.env.production? && ENV["CONFIRM"] != "wipe"

    puts MongoImport.new(dir, uploads: ENV["UPLOADS"], images: ENV["IMAGES"] != "0").run
  end
end
