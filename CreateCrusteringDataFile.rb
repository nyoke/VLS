#!/opt/local/bin/ruby -w
# -*- coding: utf-8 -*-
#require 'rubygems'
require 'yaml'
require 'pp'
####################################################################################
# 引数として渡された画像ファイルのSIFT特徴量を算出する
# 設定ファイルから
# 　画像ファイル保存先ディレクトリ：image_path
# 　SIFT特徴量保存先ディレクトリ：sift_path
# ----------------------------------------
# <改訂履歴>
# 2011.03.10 ver 0.01
# ----------------------------------------
###################################################################################
# 一番目の引数は画像のルートパスを指定する
image_path = ARGV[0]

#image_path以下の jpegファイルをリストアップ
dirlist = Dir::glob(image_path + "/**/*.sift")

#出力ファイルをopen
f_inter = File.open("image_key_pair_list.tsv",'w')
f_result = File.open("input.tsv", 'w')

sift_id = 0
sift_ids = Array.new
scale = Hash.new

#dirlist全てのファイルについてSIFT特徴量を算出
dirlist.each{|sift_path|
  begin
  	#SIFTファイルをオープン
    f_sift = File.open(sift_path)
  rescue
    puts "#{sift_path} not found."
    exit
  end
  
  print "#{sift_path}>"
  # 1行目取得（keypoint数 ¥t 次元数)
  keypoint_num = f_sift.gets.chomp!.split("\t")[0]
  print "#{keypoint_num}>"

  # SIFTファイルの1行ごとの構成(x座標 \t y座標 \t scale \t angle \t SIFT×128 \n)
  while line = f_sift.gets
    line.chomp! #改行コードを取り除く
    sep = line.split("\t") #¥tで分割
	
	sep.delete_at(0)	#x座標の情報を取り除く
	sep.delete_at(0)	#y座標の情報を取り除く
	sep.delete_at(1)	#angleの情報を取り除く
	
	scale[sep.shift.to_f] = sep

    raise "次元数がおかしい" if sep.length != 128
  end
  
  #scaleをキーにして降順にソートする
  sort_scale = scale.sort{|a,b| b[0] <=> a[0]}
  
  100.times do |i|
   #配列が空の場合ループを抜ける
    break if sort_scale.empty?
     
  	sift_ids.push(sift_id)
  	sift_id += 1
     
    # inputファイルを書き出す
    f_result.print(sift_id)
    
    buff = sort_scale.shift[1]
    
    128.times do |i|
    	 f_result.print("\t#{i}\t#{buff[i]}")
   	end
    f_result.print("\n")
   end
    
  f_sift.close
  
  # 各画像にどのIDが割り当てられたかを保存
  f_inter.print "#{sift_path}\t"
  f_inter.puts sift_ids.join("\t")
  sift_ids.clear
  puts "done."
}

p ' Finish!'