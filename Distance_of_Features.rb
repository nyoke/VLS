# 距離算出
require 'fileutils'

#画像のタグリストの作成
base_path = ARGV[0]
puts "base_path : #{base_path}"
data_path = ARGV[1]

num_of_cluster = ARGV[2].to_i

puts "***** Caluculate of distance of features *****"

FileUtils.mkdir("#{base_path}/result500_test2") rescue puts "#{base_path}/result500_test2 already exists."

    f_fea = File.open("#{base_path}/UniqFeatures.tsv", "r")
    f_bok = File.open("#{base_path}/bok.tsv", "r")
    f_out = File.open("#{base_path}/distance.tsv", "w")

    distance = Hash.new
    uniq = Hash.new

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
      distance[key] = Hash.new
      uniq.each_key{|key2|
        distance[key][key2] = Array.new
        FileUtils.makedirs("#{base_path}/result500_test2/#{key}/#{key2}") rescue puts "#{base_path}/result500_test2/#{key}/#{key2} already exists."
      }
      FileUtils.makedirs("#{base_path}/result500_test2/#{key}/all") rescue puts "#{base_path}/result500_test2/#{key}/all already exists."
      f_out.print "\t#{key}"
      print "\t#{key}"
    }

    f_out.print "\n"
    print "\n"
	
    #らしさ計算
    while line = f_bok.gets
      sep = line.chomp!.split("\t")

      # 1行目はファイル名
      file_path =  sep.shift
      p file_path
      path = File.dirname(file_path).split("/")
      file_name = File.basename(file_path)
      content = path.pop

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


      f_out.print "#{file_path}"
      print "#{file_path}"
      uniq.each { |key, value|

        sum = 0.0
        value.each_with_index{|hist, index|
          sum += [bok[index], hist].min rescue sum=0.0
        }
        f_out.print "\t#{sum}"
        print "\t#{sum}"

        FileUtils.cp("#{File.dirname(file_path)}/#{File.basename(file_name, ".sift")}.jpg",  "#{base_path}/result500_test2/#{key}/#{content}/#{sprintf("%.10f", sum)}_#{File.basename(file_name, ".sift")}.jpg")
        FileUtils.cp("#{File.dirname(file_path)}/#{File.basename(file_name, ".sift")}.jpg",  "#{base_path}/result500_test2/#{key}/all/#{sprintf("%.10f", sum)}_#{content}_#{File.basename(file_name, ".sift")}.jpg")

      }
      f_out.print "\n"
      print "\n"
    end
puts "***** Done. *****"