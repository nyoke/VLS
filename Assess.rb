# -*- coding: utf-8 -*-
require 'pp'

class Assess
  
  # イニシャライザー
  def initialize(uniq_path,codebook_path,cluster_size)
    @uniq_path = uniq_path
    @codebook_path = codebook_path
    @cluster_size = cluster_size.to_i
    
    
    # 固有特徴量の読み込み
    f_uniq = File.open(@uniq_path)
    @uniq = Hash.new
    uniq_total = Hash.new
    
    while line = f_uniq.gets
      line.chomp!
      
      sep = line.split("\t")
      tag_name = sep.shift
      @uniq[tag_name] = Array.new(@cluster_size, nil)
      
      uniq_total[tag_name] = 0.0
      while sep.count != 0
        bin = sep.shift.to_i
        count = sep.shift.to_f
        @uniq[tag_name][bin] = count
        uniq_total[tag_name] += count
      end
    end
    f_uniq.close
    
    # 固有特徴量の正規化
    @uniq.each_key do |key|
      @uniq[key].map! do |count|
        count /= uniq_total[key]
      end
    end

    # codebookの読み込み
    f_cent = File.open(@codebook_path)
    @codebook = Array.new(@cluster_size).map!{ Array.new(128,0.0)}
    
    while line = f_cent.gets
      line.chomp!
      sep = line.split("\t")
      k = sep.shift.to_i - 1
      while sep.count != 0
        dim = sep.shift.to_i
        value = sep.shift.to_f
        @codebook[k][dim] = value
      end 
    end
    f_cent.close
  end

  ############################
  #　らしさを評価するメソッド
  def assess(image_path,tag)
    
    puts "* target[ #{image_path} ], tag[ #{tag} ] ***"
    
    ##### Step 1.
    # Sift計算
    puts "  - Step 1. Caclulating SIFT feature(s)"
    system("./SiftExtractor",image_path,"tmp.sift")
    
    #sift読み込み
    f_sift = File.open("tmp.sift","r")
    
    # １行目取得 (keypoint数 ¥t 次元数)
    keypoint_num = f_sift.gets.chomp!.split("\t")[0]
    
    #siftを格納する配列を作成
    sift = Array.new(keypoint_num.to_i).map!{ Array.new(128,nil) }
    
    # f_siftからSIFT特徴量を読み込む
    sift_id = 0
    while line = f_sift.gets
      line.chomp! #改行コードを取り除く
      sep = line.split("\t") #¥tで分割
      4.times{ sep.delete_at(0) }
        
      raise "次元数がおかしい: #{sep.length}"  if sep.length != 128
      
      # sift配列へ書き込み
      sum = 0.0
      sep.each_with_index do |sep_data, sep_index|
        sum += sep_data.to_f
        sift[sift_id][sep_index] = sep_data.to_f
      end
      # 正規化する
      # sift[sift_id].map!{ |sift_data| sift_data /= sum }

      sift_id += 1
    end
    f_sift.close

    #### Step 2.
    # BoKの作成
    puts "  - Step 2. Making BoK"
    bok = Array.new(@cluster_size, 0.0)

    # 計算したcosine類似度を保存しておく配列
    cosine = Array.new(@cluster_size, nil)
    
    sift.each do |sift_data|
      
      # cosine類似度 ( cent1*data1+...+ centn*datan)/|cent|*|data|
      @codebook.each_with_index do |cent, cent_index|
        # |cent|*|data|の計算
        norm_cent = cent.inject(0.0){ |sum, value| sum + value**2 } 
        norm_sift = sift_data.inject(0.0){ |sum, value| sum + value**2 }
        norms = norm_cent * norm_sift

        # ( cent1*data1+...+ centn*datan)の計算部分，内積を求めてる
        sum = (0..127).inject(0.0){ |sum, i| sum + cent[i] * sift_data[i] }

        # ( cent1*data1+...+ centn*datan)/|cent|*|data| を計算してcosine配列に納格
        cosine[cent_index] = sum / Math.sqrt(norms)

      end

      # cosine配列について，最も類似度の高い(1)に近い要素番号を探す
      max_index = 0
      max = Float::MIN
      cosine.each_with_index do |cosine_value, cosine_index|
        if max < cosine_value
          max_index = cosine_index
          max = cosine_value
        end
      end

      # 一番近いインデックスに投票してBoKを更新
      bok[max_index] += 1.0
    end
    
    #BoKを正規化する
    @cluster_size.times{ |i| bok[i] /= keypoint_num.to_f }
    
    sum = 0
    bok.each{ |e|  sum += e}
    puts sum

    ##### Step 3.
    # 固有特徴量とBoKとの距離計算
    puts "  - Step 3. Caclulating distance between uniqfeature and BoK"

    if tag == "all" then
      result = Hash.new
      @uniq.each_key do |key|
        sum = 0.0
        @cluster_size.times{ |i| sum += [@uniq[key][i],bok[i]].min }
        result[key] = sum
      end
      return result
    else
      sum = 0.0
      @cluster_size.times{ |i| sum += [@uniq[tag][i],bok[i]].min }
      return sum
    end    
  end
end

# main
assess = Assess.new(ARGV[0],ARGV[1],ARGV[2]) #固有特徴量(UniqFeatures.tsv),codebook(centroid.tsv),クラスタ数
#pp assess.assess(ARGV[3],ARGV[4]) # 画像のパス,評価したいタグ(allですべて)
#image_path以下の jpegファイルをリストアップ
dirlist = Dir::glob(ARGV[3] + "/**/*.jpg")
likeness = Hash.new
dirlist.each do |path|
  tag = File::basename(File::dirname(path))
  likeness[tag] = Hash.new if likeness[tag] != nil
  result = assess.assess(path, ARGV[4])
  pp result
end

