require 'watir'
require 'csv'
require 'net/http'
require 'uri'
require 'addressable/uri'
require 'json'

browser = Watir::Browser.new

browser.goto 'http://www.st-petersburg.vybory.izbirkom.ru/region/st-petersburg?action=show&root_a=784014001&vrn=100100084849062&region=78&global=true&type=0&sub_region=78&root=1000075&prver=0&pronetvd=null&tvd=100100084849201'
records = ["УИК",
           "Информация о числе избирателей, включенных в список избирателей на основании поданных заявлений о включении в список избирателей по месту нахождения",
           "Информация о числе избирателей из Реестра избирателей, подлежащих исключению из списка избирателей",
           "Информация о числе избирателей, оформивших заявления о включении в список избирателей по месту нахождения не ранее чем за четыре дня до дня голосования и не позднее 14 часов по местному времени в день, предшествующий дню голосования, исключенных из списка избирателей по месту жительства",
           "Информация о числе избирателей, оформивших заявления о включении в список избирателей по месту нахождения не ранее чем за четыре дня до дня голосования и не позднее 14 часов по местному времени в день, предшествующий дню голосования, включенных в список избирателей по месту нахождения",
           "Предварительные сведения об участии избирателей в выборах",
           "Итоги голосования"]

CSV.open("election_results.csv", "w") do |csv_data|
  csv_data << records

  sel = browser.select_list(name: 'gs')
  submit1 = browser.button(name: 'go')
  sel.select "12 Территориальная избирательная комиссия №12"
  submit1.click # go to ТИК

  select = browser.select_list(name: 'gs')
  submit2 = browser.button(name: 'go')
  select.options.each_with_index do |option, i|
    unless i == 0
      row = []
      uik = option.text.split(' ').first
      row << uik
      select.select option.text
      submit2.click # go to УИК

      browser.trs(class: 'trReport').each_with_index do |tr, i|
        if i != 0 and i != 5
          tr.td.link.click
          if i < 5
            row << browser.table(id: 'table-1').tbody.tr.td.text.to_s
          elsif i == 6
            row << browser.tables.last.inner_html.to_s
          else
            row << browser.tables[8].inner_html.to_s
          end
          browser.back
        end
      end
      csv_data << row
      browser.back
    end
  end
end

browser.close