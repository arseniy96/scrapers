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

CSV.open("election_results_spb3.csv", "w") do |csv_data|
  csv_data << records

  select1 = browser.select_list(name: 'gs')
  submit1 = browser.button(name: 'go')
  select1.options.each_with_index do |option1, i|
    if i > 16
      select1.select option1.text
      submit1.click # go to ТИК

      select2 = browser.select_list(name: 'gs')
      submit2 = browser.button(name: 'go')
      select2.options.each_with_index do |option2, j|
        unless j == 0
          row = []
          uik = option2.text.split(' ').first
          row << uik
          select2.select option2.text
          submit2.click # go to УИК

          browser.trs(class: 'trReport').each_with_index do |tr, k|
            if k != 0 and k != 5
              tr.td.link.click
              if k < 5
                row << browser.table(id: 'table-1').tbody.tr.td.text.to_s
              elsif k == 6
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
      browser.back
    end
  end
end

browser.close