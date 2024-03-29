#!/opt/local/bin/ruby -w
# -*- coding: utf-8 -*-

####################################################################################
# クラスタリングのためにkey-point数をまびく
# ----------------------------------------
# <改訂履歴>
# 2011.06.10 ver 0.01
# ----------------------------------------
####################################################################################
fr = File.open(ARGV[0],'r')
fw = File.open("_#{ARGV[0]}", 'w')

fr.each_with_index{|line, i| fw.print(line) if i%ARGV[1].to_i == 0}

fr.close
fw.close

