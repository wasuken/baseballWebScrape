# coding: utf-8


require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'active_record'

ActiveRecord::Base.establish_connection(
  "adapter" =>"sqlite3",
  "database" => "./baseball.db"
)
#この雑なまとめ方
class Fielder_score < ActiveRecord::Base
end
class Player < ActiveRecord::Base
end
class Pitcher_score  < ActiveRecord::Base
end

#選手のページからデータを取得
def insertPlayerData(uri,playerName,id,type)
  doc = getDoc(uri)
  doc.xpath('//div[@id="3yrsstat"]').each do |node|
    node.css("tr.yjM").each do |n|
      row = n.css("td").map(&:inner_text).compact.reject(&:empty?)
      #職人が一つ一つ手で入力しました。
      if type === "p"
        Pitcher_score.create(:p_id => id,
                             :year => row[0],
                             :term_name => row[1],
                             :defense_rate => row[2],
                             :game_number => row[3],
                             :win => row[4],
                             :lose => row[5],
                             :hold_save => row[6],
                             :pitching_time => row[7],
                             :hit => row[8],
                             :homerun => row[9],
                             :strikeout => row[10],
                             :four => row[11],
                             :dead => row[12],
                             :point => row[13])
      else
        Fielder_score.create(:p_id => id,
                             :year => row[0],
                             :term_name => row[1],
                             :batting_rate => row[2],
                             :game_number => row[3],
                             :stroke_cnt => row[4],
                             :hit => row[5],
                             :homerun => row[6],
                             :hit_point => row[7],
                             :score => row[8],
                             :struck_out => row[9],
                             :four => row[10],
                             :dead => row[11],
                             :sacrifice => row[12],
                             :sacrifice_fly => row[13],
                             :steal_base => row[14])
      end
    end
  end
  #サーバへの瞬間的負荷の軽減
  sleep(1)
end
#ドキュメント取得
def getDoc(uri)
  begin
  charset = nil
  html = open(uri) do |f|
    charset = f.charset
    f.read
  end
  rescue  => exception
    case exception
    when OpenURI::HTTPError
      puts "ページが見つかりません。#{uri}"
    when URI::InvalidURIError
      puts "URLが入力されていません。"
    else
      puts exception.to_s + "(#{exception.class})"
    end
    return nil
  end
  return Nokogiri::HTML.parse(html, nil, charset)
end

def player_get(type,term_num)
  baseUri = "https://baseball.yahoo.co.jp"
  uri = baseUri + "/npb/teams/#{term_num}/memberlist?type=#{type}"

  playerUri = []
  doc = getDoc(uri)
  team_name = doc.xpath('//title').first.inner_text.split("-")[1]
  position = type === "p"? "投手" : "野手"
  #投手の一覧を取得
  p_id = 0
  doc.xpath('//td/a').each do |node|
    playerUri.push(baseUri + node.attribute('href').value)
    reco = Player.find_by(:name => node.inner_text)
    if !reco
      Player.create(:name => node.inner_text,:current_team => team_name,:position => position)
      reco = Player.find_by(:name => node.inner_text)
    end
    p_id = reco[:p_id]
    insertPlayerData(baseUri + node.attribute('href').value,node.inner_text,p_id,type)
  end
end
#すべてのチームの選手の年度別の情報を取得する
def all_team_player_year_score
  #ここまでいびつなアレならいっそ特定ページからリンクを拾うようにしてもいいかも
  term_nums = [1,2,3,4,5,6,7,8,9,11,12,376]
  start_time = Time.now
  term_nums.each do |i|
    ["p","b"].map do |type|
      player_get(type,i)
      p "球団#{i}: #{Time.now - start_time}s"
    end
  end
  p "終了 #{Time.now - start_time}s"
end
all_team_player_year_score
