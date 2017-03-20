# coding: utf-8


=begin

#doit
webサイトから選手一覧を取得
CSVで保存できる。

todo
球団一つでやりたい（粒度を大きくしたい）
DBに保存したい。

=end


require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'active_record'

ActiveRecord::Base.establish_connection(
    "adapter" =>"sqlite3",
    "database" => "./baseball.db"
)

class Player_year_score < ActiveRecord::Base 
end

#ユーザデータをＤＢにいれるぞ
def playerDataDBInsert()
  
SQL

end
#なげえよおまえ！
#文字列を分割して空白消すやつ
def node_text_split_reject_blank(node,sepa="\n")
  node.inner_text.split(sepa).compact.reject(&:empty?)
end
#投手のページからデータを取得
def getPlayerData(uri,playerName)
  getDoc(uri).xpath('//div[@id="3yrsstat"]').each do |node|
    p node_text_split_reject_blank(node.css("tr.yjMS"))

    node.css("tr.yjM").map{|n|
      row = node_text_split_reject_blank(n)
      Player_year_score.create(:year => row[0],:term_name => row[1],:defense_rate => row[3],:game_number => row[4],:win => row[5],:lose => row[6],:hold_save => row[7],:pitching_time => row[8],:hit => row[9],:homerun => row[9],:strikeout => row[10],:four => row[11],:dead => row[12],:point => row[13])
      p Player_year_score.all
    }
    
=begin
    node.css("tr.yjM").each do |n|
      row = node_text_split_reject_blank(n)
      file = File.open("./playerCsv/#{playerName}.csv","a+:UTF-8")
      file.write(n.inner_text.gsub("\n",",") + " \n")
      file.close
    end
=end
  end
  #サーバへの瞬間的負荷の軽減
  sleep(1)
end
#ドキュメント取得は統一しよう
def getDoc(uri)
  charset = nil
  html = open(uri) do |f|
    charset = f.charset
    f.read
  end
  return Nokogiri::HTML.parse(html, nil, charset)
end


baseUri = "https://baseball.yahoo.co.jp"
uri = baseUri + "/npb/teams/6/memberlist?type=p"

playerUri = []
FileUtils.rm(Dir.glob("./playerCsv/*.csv"))
#投手の一覧を取得
getDoc(uri).xpath('//td/a').each do |node|
  playerUri.push(baseUri + node.attribute('href').value)
  getPlayerData(baseUri + node.attribute('href').value,node.inner_text)

end

