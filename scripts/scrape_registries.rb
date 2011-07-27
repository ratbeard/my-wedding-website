require 'net/http'
require 'rubygems'
require 'hpricot'
require 'uri'
# class Registry
#   
# end
# 
# class Target < Registry
# 
# end
# 
# 
url = 'http://www.target.com/registry/wedding/013399700666319'
item_selector = '.zebra,.nonZebra'

html = Net::HTTP.get(URI.parse url)
doc = Hpricot(html)

items = doc./(item_selector).map do |item_html|
  {
    :name => item_html./('.description a').text.strip.gsub(',', ' '),
    :want => item_html./('.wantit').text.strip,
    :have => item_html./('.gotit').text.strip,
    :price => item_html./('.price').text.strip[/\$.*/]
  }
end

output = ''
output << "From,Name,Price,Want,Have\n"
items.each do |item|
  output << ['Target', item[:name], item[:price], item[:want],item[:have]].join(',') << "\n"
end



# Crate
url = 'http://www.crateandbarrel.com/Gift-Registry/Guest/View-Registry.aspx?grid=4718512'
item_selector = '.jsItemRow'

html = Net::HTTP.get(URI.parse url)
doc = Hpricot(html)

items = doc./(item_selector).map do |item_html|
  {
    :name => item_html./('.itemTitle').text.strip.gsub(',', ' '),
    :want => item_html./('.itemHas')[0].html,
    :have => item_html./('.itemHas')[1].html,
    :price => item_html./('.regPrice').text
  }
end

items.each do |item|
  output << ['Crate', item[:name], item[:price], item[:want],item[:have]].join(',') << "\n"
end


# Macys
url = 'http://www1.macys.com/registry/wedding/guest/?registryId=466480'
item_selector = '.upcLineItem'

html = Net::HTTP.get(URI.parse url)
doc = Hpricot(html)

items = doc./(item_selector).map do |item_html|
  name_el = item_html./('.quicklook')
  # 2 row styles, depending if the item is sold online
  if name_el.length > 0
    name = name_el.text.strip.gsub(/[\t\r\n, ]/, ' ').squeeze
    # Some items don't have price
    if price = item_html./('.prices span').last
      price = price.html[/\$.*/]
    end
    # Displays as 'would love', 'still need'
    want = item_html./('.requestedQty').text.strip
    need = item_html./('.receivedQty').text.strip
  else # not available online item
    name = item_html./('.productInfo').text.strip.gsub(/[\t\r\n, ]/, ' ').squeeze
    want = item_html./('> td:eq(1)').text.strip
    need = item_html./('> td:eq(2)').text.strip
  end

  need = 0 if need == 'fulfilled'  
  {
    :name => name,
    :want => want,
    :have => want.to_i - need.to_i,
    :price => price
  }
end

items.each do |item|
  output << ['Macys', item[:name], item[:price], item[:want],item[:have]].join(',') << "\n"
end





File.open('registry.csv', 'w') {|f| f.puts output }