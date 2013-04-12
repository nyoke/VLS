# 距離算出
require 'fileutils'

#画像のタグリストの作成
base_path = ARGV[0]
puts "base_path : #{base_path}"
data_path = ARGV[1]

num_of_cluster = ARGV[2].to_i

puts "***** Caluculate of distance of features *****"

FileUtils.mkdir("#{base_path}/average") rescue puts "#{base_path}/average already exists."

    f_fea = File.open("#{base_path}/UniqFeatures.tsv", "r")
    f_bok = File.open("#{base_path}/bok.tsv", "r")
    f_out = File.open("#{base_path}/average/distance_average_500.tsv", "w")

    distance = Hash.new
    uniq = Hash.new
    average = Hash.new

    #固有特徴読み込み
    while line = f_fea.gets
      sep = line.chomp!.split("\t")
      content = sep.shift
      uniq[content] = Array.new(num_of_cluster, 0.0)
	  
	  sum = 0     
      while sep.length != 0
        bin = sep.shift.to_i
        hist = sep.shift.to_f
        uniq[content][bin] = hist
        sum += hist
      end
        #正規化
        uniq[content].each_with_index{|hist,index|
          uniq[content][index] /= sum
        }
    end

	#ヘッダ書き込み
    uniq.each_key{|key|
      f_out.print "\t#{key}"
      print "\t#{key}"
    }
    f_out.print "\n"


    #らしさ計算
    while line = f_bok.gets
      sep = line.chomp!.split("\t")
	  
      # 1行目はファイル名
      file_path =  sep.shift
      p file_path
      path = File.dirname(file_path).split("/")
      file_name = File.basename(file_path)
      content = path.pop
        
	  #averageの初期化
	  average[content] = Hash.new{|hash,key|
	  	hash[key] = 0} if average[content] == nil
      
      bok= Array.new(num_of_cluster, 0.0)
      sum = 0
      while sep.length != 0
        bin = sep.shift.to_i - 1
        hist = sep.shift.to_f
        bok[bin] = hist
        sum += hist
      end
      #正規化
      bok.each_with_index{|hist,index|
        bok[index] /= sum
      }
     
      uniq.each { |key, value|
        sum = 0.0
        value.each_with_index{|hist, index|
          sum += [bok[index], hist].min rescue sum=0.0
        }
        average[content][key] += sum
      }
     end
     
      #ファイルに書き出し
      uniq.each_key do |cont|
      		f_out.print "#{cont}"
      		uniq.each_key do |cont2|
      			f_out.print "\t#{average[cont][cont2]/30.0}"
      		end
      		f_out.print "\n"
      end
     
puts "***** Done. *****"