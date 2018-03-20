require 'csv'
require 'net/http'
require 'uri'
require 'addressable/uri'
require 'json'

csv = CSV.parse(open('./all_uiks_addresses.csv').read.force_encoding('utf-8').encode('utf-8'), headers: true)

CSV.open("add_uik_addresses_with_coordinates.csv", "w") do |csv_data|
  csv_data << ["№ УИК", "Адрес голосования", "Координаты"]
  csv.each_with_index do |row, i|
    uik = row[0]
    address = row[1]
    coordinates = ''

    if address != nil && address != ''
      building = address.split(',')
      4.times {building.delete_at(0)}
      address_for_url = building.join.strip!.gsub(' ', '+')

      url = Addressable::URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{address_for_url}+Петербург&key=AIzaSyBq9hfEojEzm_Fg2bzuQ9XK9t133gr0YGU").normalize
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(Net::HTTP::Get.new(uri.request_uri))

      if JSON.parse(response.body)['results'].first
        coordinates = JSON.parse(response.body)['results'].first.dig('geometry', 'location', 'lat').to_s + ' ' + JSON.parse(response.body)['results'].first.dig('geometry', 'location', 'lng').to_s
      else
        coordinates = 'Неправильный адрес'
      end
    end

    csv_data << [uik, address, coordinates]
  end
end
