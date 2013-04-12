#!/opt/local/bin/ruby -w
# -*- coding: utf-8 -*-
##########################################
# BoKを作成
# ----------------------------------------
# <改訂履歴>
# 2011.06.10 ver 0.01
# ----------------------------------------
##########################################

#require 'rubygems'
require 'yaml'
require 'pp'

if !ARGV[0] || !ARGV[1]
  puts "usage: ruby MakeBok.rb [image_key_pair_list.tsv] [classify.tsv]"
  exit
end

hash_id_path = ARGV[0] # hash値とdocument_idのリスト
classify_path = ARGV[1] #各document_idがどのvisual wordに属するかを記したリスト

documentid2vword = Hash.new

#classify.tsv読み込み
File::open(classify_path){ |f|
  f.each_with_index{|line, i|
    sep = line.chomp!.split("\t")
    
    if !sep[0] || !sep[1]
      STDERR.puts "document_id or visualword_id error!: line=#{i} [#{sep[0]}, #{sep[1]}]"
    end
    documentid2vword["#{sep[0]}"] = sep[1].to_i
  }
}

# image_key_pair_list.tsvを読み込んでBoK作成
File::open(hash_id_path){ |f|
  f.each{|line|
    sep = line.chomp!.split("\t")

    hash = sep.shift
    histogram = Hash.new

    sep.each{|document_id|
      if documentid2vword.key?(document_id)
        histogram[documentid2vword[document_id]] += 1 rescue histogram[documentid2vword[document_id]] = 1
      else
        STDERR.puts "visualword not found: #{hash} of #{document_id}"
      end
    }

    print hash
    histogram.sort.each {|key, value| print "\t#{key}\t#{value}"}
    print "\n"
  }
}

