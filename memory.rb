require "./akuukan_player.rb"
$players = ["ゲスト"]
$versions = []
$reqcapture = 10 #なっんことったら上がりにするか

#####player倉庫
#####playerここまで

#####version倉庫

$a = Version.new
$versions += ["$a"]
$a.setNames(2,1)

$b = Version.new
$versions += ["$b"]
$b.setNames(2,3)


$c = Version.new
$versions += ["$c"]
$c.setNames(2,4)
#####versionここまで

#####record倉庫
#####recordここまで