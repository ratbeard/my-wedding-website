require 'net/http'
require 'rubygems'
require 'hpricot'
require 'uri'

class Scrapper
  def run
    registries = [Target.new, Crate.new, Macys.new]
    output = Registry.csv_header
    
    registries.each do |registry|
      registry.run
      csv = registry.to_csv
      puts "==#{registry.class.name}==", csv
      output << csv
    end
    
    File.open('registry.csv', 'w') do |f| 
      f.puts output
    end    
  end
end

class Registry
  def run
    html = Net::HTTP.get(URI.parse self.class.url)
    @doc = Hpricot(html)
    @item_els = @doc./(self.class.item_selector)
    @items = @item_els.map {|el| parse_item(el)  }
  end
  
  def parse_item(el)
    raise "override me"
  end
  
  
  def to_csv(options={})
    output = ''
    @items.each do |item|
      output << "%s,%s,%s,%s,%s\n" % [self.class.name, item[:name], item[:price], item[:want],item[:have]]
    end
    output
  end
  
  def self.csv_header
    "From,Name,Price,Want,Have\n"
  end
  
  def self.url(value=nil)
    @url = value if value
    @url
  end  
  
  def self.item_selector(value=nil)
    @item_selector = value if value
    @item_selector
  end
end


class Target < Registry
  url  'http://www.target.com/registry/wedding/013399700666319'
  item_selector '.zebra,.nonZebra'
  
  def parse_item(el)
    {
      :name => el./('.description a').text.strip.gsub(',', ' '),
      :want => el./('.wantit').text.strip,
      :have => el./('.gotit').text.strip,
      :price => el./('.price').text.strip[/\$.*/]
    }
  end
end


class Crate < Registry
  url 'http://www.crateandbarrel.com/Gift-Registry/Guest/View-Registry.aspx?grid=4718512'
  item_selector '.jsItemRow'
  
  def parse_item(el)
    {
      :name => el./('.itemTitle').text.strip.gsub(',', ' '),
      :want => el./('.itemHas')[0].html,
      :have => el./('.itemHas')[1].html,
      :price => el./('.regPrice').text
    }
  end
end


class Macys < Registry
  url 'http://www1.macys.com/registry/wedding/guest/?registryId=466480'
  item_selector '.upcLineItem'
  
  def parse_item(el)
    name_el = el./('.quicklook')
    
    # 2 row styles, depending if the item is sold online
    if name_el.length > 0
      name = name_el.text.strip.gsub(/[\t\r\n, ]/, ' ').squeeze
      # Some items don't have price
      if price = el./('.prices span').last
        price = price.html[/\$.*/]
      end
      # Displays as 'would love', 'still need'
      want = el./('.requestedQty').text.strip
      need = el./('.receivedQty').text.strip
    else # not available online item
      name = el./('.productInfo').text.strip.gsub(/[\t\r\n, ]/, ' ').squeeze
      want = el./('> td:eq(1)').text.strip
      need = el./('> td:eq(2)').text.strip
    end

    need = 0 if need == 'fulfilled'  
    {
      :name => name,
      :want => want,
      :have => want.to_i - need.to_i,
      :price => price
    }  
  end
end


Scrapper.new.run