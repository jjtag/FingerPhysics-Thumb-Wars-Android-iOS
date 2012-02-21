#!/bin/ruby

res_name = "res.h"

lines = []

File.open(res_name, 'r').readlines.each do |line|
  puts line.gsub(/@"((\\"|.)+?)"/, 'NSS("\1")')
end
