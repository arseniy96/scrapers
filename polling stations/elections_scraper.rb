require 'watir'
require 'csv'
require 'net/http'
require 'uri'
require 'addressable/uri'
require 'json'

browser = Watir::Browser.new

browser.goto 'http://www.st-petersburg.vybory.izbirkom.ru/region/st-petersburg?action=ik&vrn=4784001195858'

tiks = ['4784009153000', '4784018143444',
        '4784021117118', '4784017152031', '4784019154493', '4784012159595', '4784010176982', '4784015153149', '4784006269961',
        '4784024158204', '4784016167610', '4784022171789', '4784025169376', '4784026165553', '4784027166331', '4784028159834',
        '4784029163655', '4784030141581']

CSV.open("elections3.csv", "w") do |csv_data|
  csv_data << ["№ ТИК", "№ УИК", "Адрес 1", "Адрес 2", "Члены избирательной комиссии", "Координаты"]
  tiks.each_with_index do |tik, i|
    browser.goto "http://www.st-petersburg.vybory.izbirkom.ru/region/st-petersburg?action=ik&vrn=#{tiks[i]}"
    sleep 1.5
    browser.div(id: 'tree').ul.li.ul.lis[i + 12].ul.lis.each do |li|
      li.link.click
      sleep 0.3
      uik = browser.div(class: 'center-colm').h2.text.split('№').last
      address1 = browser.span(id: 'address_ik').span.text
      address2 = browser.span(id: 'address_voteroom').span.text
      table = browser.div(class: 'table margtab').inner_html
      building = address2.split(',')
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

      csv_data << [i + 13, uik, address1, address2, table, coordinates]
    end
    # browser.div(id: 'tree').ul.li.ul.lis.each_with_index do |tik, i|
    #   tik.link.click
    #   f.write("ТИК № #{i + 1}\n")
    #   sleep 1
    #   browser.div(id: 'tree').ul.li.ul.lis[i].ul.lis.each do |li|
    #     li.link.click
    #     sleep 0.4
    #     address = browser.span(id: 'address_voteroom').span.text
    #     f.write("#{address}\n")
    #     # browser.back
    #   end
    #   f.write("\n\n")
    # end
  end
end

# browser.div(id: 'tree').ul.li.ul.lis.each_with_index do |tik, i|
#   tik.link.click
#   f.write("ТИК № #{i + 1}\n")
#   sleep 1
#   browser.div(id: 'tree').ul.li.ul.lis[i].ul.lis.each do |li|
#     li.link.click
#     sleep 0.4
#     address = browser.span(id: 'address_voteroom').span.text
#     f.write("#{address}\n")
#     # browser.back
#   end
#   f.write("\n\n")
# end

# browser.div(id: 'tree').ul.li.ul.lis.first.ul.lis.each do |li|
#   li.link.click
#   first_address = browser.span(id: 'address_voteroom').span.text
#   puts first_address
#   browser.back
#   #.first.link.click
# end

# first_address = browser.span(id: 'address_voteroom').span.text
# puts first_address
browser.close
f.close