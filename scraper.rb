require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'Pry'
require 'csv'

@artist_name = ARGV.join("-").downcase
@artist_name[0] = @artist_name[0].capitalize!

url = 'http://genius.com/artists/' + @artist_name

puts url

page = HTTParty.get(url)

parse_page = Nokogiri::HTML(page)

songs = []

parse_page.css('.u-quarter_top_margin').css('.full_width_button').map do |a|
	url = a[:href]
end

albums = HTTParty.get('http://genius.com'+url)
parse_page = Nokogiri::HTML(albums)

album_array = []

parse_page.css('.album_link').map do |a|
	album_array << 'http://genius.com'+a[:href]
end

puts album_array

lyrics_array = []

album_array.each do |al|
	page = HTTParty.get(al)
	parse_page = Nokogiri::HTML(page)
	parse_page.css('.song_link').map do |a|
		songs << a[:href]
	end

	puts songs 

	songs.each do |song|
		page = HTTParty.get(song)
		parse_page = Nokogiri::HTML(page)
		parse_page.css('.song_body-lyrics').css('.lyrics').css('.referent').map do |a|
			lyric = a.text
			lyrics_array.push(lyric)
		end
	end

	File.open(@artist_name+".txt", "a") do |f|
  		f.puts(lyrics_array)
	end

	songs = []
	lyrics_array = []
end

