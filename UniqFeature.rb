#!/opt/local/bin/ruby -w
# -*- coding: utf-8 -*-
require 'fileutils'

#画像のタグリストの作成
base_path = ARGV[0]
puts "base_path : #{base_path}"
data_path = ARGV[1]

num_of_cluster = ARGV[2].to_i

tag_name_list = Hash.new
#data_pathより使用するタグ名を取得する
Dir.glob("#{data_path}*") { |filename|  tag_name_list[File.basename(filename)] = filename  if File.directory?(filename)  }

# 固有特徴量の算出
puts "***** Caluculate of unique features *****"

    f_bok = File.open("#{base_path}/bok.tsv", "r")
    f_out = File.open("#{base_path}/UniqFeatures.tsv", "w")
    puts "[bok : #{base_path}/bok.tsv] [out : #{base_path}/UniqFeatures.tsv]"

    histogram = Hash.new
   
    while line = f_bok.gets
      sep = line.chomp!.split("\t") rescue break
      
      # 1行目はファイル名
      file_name = sep.shift
      content = File.dirname(file_name).split("/")
      content = content.pop
      
      histogram[content] = Array.new(num_of_cluster, 0.0) if !histogram[content]

      while sep.length != 0
        bin = sep.shift.to_i - 1
        hist = sep.shift.to_i
        histogram[content][bin] += hist
      end
    end
    f_bok.close
    histogram.each{|key, value|

      f_out.print "#{key}"
      print "#{key}"
      value.each_with_index{|data, index|

        f_out.print "\t#{index}\t#{data}"
        print "\t#{index}\t#{data}"
      }
      f_out.print "\n"
      print "\n"
    }
    f_out.close
    
puts "***** Done. *****"