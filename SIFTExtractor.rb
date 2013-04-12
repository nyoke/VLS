#!/opt/local/bin/ruby -w
# -*- coding: utf-8 -*-
#require 'rubygems'
require 'yaml'
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
dirlist = Dir::glob(image_path + "/**/*.jpg")

#dirlist全てのファイルについてSIFT特徴量を算出
dirlist.each{|d|
  print "#{d} : call SiftExtractor"
  
  sift_path = File::dirname(d) + "/" + File::basename(d, '.*')
  #SiftExtractor呼び出し
  system("./SIFTExtractor #{d} #{sift_path}.sift")
  puts ": puts #{sift_path}.sift : done."
}

p 'SIFT Execute Finish!'