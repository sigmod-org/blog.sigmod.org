# Find authors in _data/authors.yml by name or key, ignoring case and accents.
#
#   ruby tools/find_author.rb stoyanovich
#   ruby tools/find_author.rb ozsu          # finds "M. Tamer Özsu"
#   ruby tools/find_author.rb               # lists everyone
#
# Prints one line per person: the key to use in a post's front matter, the
# name, and whether a headshot is set. Combined bylines imported from the old
# blog (entries with `members`) are skipped: never use them for new posts.

require "yaml"

def plain(text)
  text.to_s.unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").downcase
end

query = plain(ARGV.join(" "))
authors = YAML.load_file(File.join(__dir__, "..", "_data", "authors.yml"))
hits = authors.reject { |_, info| info["members"] }
              .select { |key, info| plain("#{key} #{info["name"]}").include?(query) }

if hits.empty?
  puts "No author matches \"#{ARGV.join(" ")}\". Try the surname only, or add a new entry."
  exit 1
end

width = hits.keys.map(&:length).max
hits.sort_by { |_, info| plain(info["name"]) }.each do |key, info|
  photo = info["avatar"].to_s.empty? ? "no photo" : "photo"
  puts "#{key.ljust(width)}  #{info["name"]}  (#{photo})"
end
