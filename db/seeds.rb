# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Room.delete_all

rooms = Room.create([{roomnum:1, name:"Crimson Tide", cname:"满江红", capacity:15, location:"Floor 10", devices:3 },\
                     {roomnum:2, name:"Sandybrook", cname:"浣溪沙", capacity:15, location:"Floor 10", devices:3 },\
                     {roomnum:3, name:"Fisher Pride", cname:"渔家傲", capacity:15, location:"Floor 10", devices:3 },\
                     {roomnum:4, name:"Garden Spring", cname:"沁园春", capacity:15, location:"Floor 10", devices:3 },\
                     {roomnum:5, name:"Plum Blossom", cname:"一剪梅", capacity:15, location:"Floor 10", devices:3 },\
                     {roomnum:6, name:"Ocean Songs", cname:"水调歌头", capacity:8, location:"Floor 10", devices:3 },\
                     {roomnum:7, name:"Fair Lady", cname:"念奴娇", capacity:5, location:"Floor 10", devices:2 },\
                     {roomnum:8, name:"BoF", cname:"蝶恋花", capacity:10, location:"Floor 10", devices:2 },\
                     {roomnum:9, name:"Buddha Hymns", cname:"菩萨蛮", capacity:10, location:"Floor 10", devices:3 },\
                     {roomnum:11, name:"Boat Song", cname:"渔舟唱晚", capacity:15, location:"Floor 11", devices:3 },\
                     {roomnum:12, name:"Mountain Creek", cname:"高山流水", capacity:15, location:"Floor 11", devices:3 },\
                     {roomnum:13, name:"Flying Daggers", cname:"十面埋伏", capacity:15, location:"Floor 11", devices:3 },\
                     {roomnum:14, name:"Spring Snow", cname:"阳春白雪", capacity:15, location:"Floor 11", devices:3 },\
                     {roomnum:15, name:"Silver Cloud", cname:"彩云追月", capacity:15, location:"Floor 11", devices:3 }])