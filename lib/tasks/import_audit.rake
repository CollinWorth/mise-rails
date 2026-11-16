# Measures how well the recipe import works on real pages: bin/rails import:audit
#   FILE=test/corpus/recipe_urls.txt  the pages to try (one URL per line)
#   THRESHOLD=98                      exit with an error below this pass rate (percent)
#   ONLY=text                         only lines containing this text
# A page counts only if it looks like a recipe page (it carries recipe data or a recipe card); one that doesn't is skipped. A recipe page passes when the import finds a name, at least 1 ingredient, at least 1 step, and no leftover HTML.
require "import_audit"

namespace :import do
  desc "Try the recipe import on a list of real pages and report the pass rate"
  task audit: :environment do
    file = Rails.root.join(ENV.fetch("FILE", "test/corpus/recipe_urls.txt"))
    urls = file.readlines(chomp: true).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }
    urls = urls.select { |url| url.include?(ENV["ONLY"]) } if ENV["ONLY"]
    results = urls.map { |url| ImportAudit.check(url) }

    results.group_by(&:status).each { |status, rows| puts "#{status.to_s.ljust(8)} #{rows.size}" }
    results.select { |row| row.status == :fail }.each { |row| puts "FAIL #{row.url}\n     #{row.reason}" }
    judged = results.reject { |row| row.status == :skipped }
    rate = judged.empty? ? 0 : (100.0 * judged.count { |row| row.status == :pass } / judged.size)
    puts format("\nPass rate: %.1f%% of %d recipe pages (%d skipped), %d checked against the page's own ingredient list", rate, judged.size, results.size - judged.size, ImportAudit.cross_checked)
    abort "Below the #{ENV.fetch('THRESHOLD', 98)}% bar." if ENV["THRESHOLD"] && rate < ENV["THRESHOLD"].to_f
  end
end
