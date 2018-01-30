$players = ["ゲスト"]
$versions = [] #対応しているvalueのｖｅｒｓｉｏｎのアルファベット $aみたいな

class Player
    @playerName = ""
    @playerNum = 0
    def setPlayer(name)
        @record = []
        @playerName = name
        @playerNum = $players.length
    end
    def recorda
        return @record
    end
    def record(add)
        @record = add
    end
    def playerName
        return @playerName
    end
    def addRecord(opponent,outcome) #outcomeはその間の勝利数になるようニする @recordには対戦相手ごとに[名前,勝利数]を格納していく
        n = @playerNum
        added = false
        oldr = @record.to_s
        for i in 0..@record.length-1
            if @record[i][0] == opponent
                @record[i][1] += outcome
                added = true
            end
        end
        if @record.length > 0
            if !added
                @record += [[opponent,outcome]]
            end
            newr = @record.to_s
            f = File.open("akuukan_memory.rb","r")
            text = f.read
            f.close
            if n < 0
                text.gsub!("#{$versions[-n-1]}.record(#{oldr})","#{$versions[-n-1]}.record(#{newr})")
            else
                text.gsub!("$p#{@playerNum}.record(#{oldr})","$p#{@playerNum}.record(#{newr})")
            end
        else 
            @record += [[opponent,outcome]]
            f = File.open("akuukan_memory.rb", "r")
            line = ""
            text = ""
            while true
                text += line
                if line == "#####record倉庫\n"
                    if n < 0
                        text += "#{$versions[-n-1]}.record([[\"#{opponent}\", #{outcome}]])\n"
                    else
                        text += "$p#{@playerNum}.record([[\"#{opponent}\", #{outcome}]])\n"
                    end
                end
                begin
                    line = f.readline
                rescue EOFError
                    break
                end
            end
            f.close
        end
        f = File.open("akuukan_memory.rb","w")
        f.write text
        f.close
    end
    def getsRecord(opponent)
        k = -1
        for i in 0..@record.length-1
            if @record[i][0] == opponent
                k = i
            end
        end
        if k == -1
            return 0
        else
            return @record[k][1]
        end
    end
    def showRecord
        total = [0,0]
        if @playerNum < 0
            name = $versions[-@playerNum-1]
        else
            name = "$p#{@playerNum}"
        end
        if @record.length == 0
            puts "\n#{@playerName}はまだ一度も戦っていません。"
        else
            puts
            puts "#{@playerName}の戦績："
            for x in 0..@record.length-1
                total[0] += @record[x][1]
                total[1] += eval(@record[x][0]).getsRecord(name)
                puts "    対#{eval(@record[x][0]).playerName}\n         #{@record[x][1]}勝#{eval(@record[x][0]).getsRecord(name)}敗"
            end
            puts "    ############"
            puts "    合計 #{total[0]}勝#{total[1]}敗"
        end
    end
end

def addPlayer(name)
    n = $players.length
    f = File.open("akuukan_memory.rb", "r")
    line = ""
    text = ""
    while true
        if line == "#####playerここまで\n"
            text += "\n$p#{n} = Player.new\n$p#{n}.setPlayer(\"" + name + "\")\n$players += [\"" + name + "\"]\n"
        end
        text += line
        begin
            line = f.readline
        rescue EOFError
            break
        end
    end
    f.close
    f = File.open("akuukan_memory.rb", "w")
    f.write text
    f.close
    load "akuukan_memory.rb"
    puts "追加が完了しました。🤗"
end

def choosePlayer(mode)
    puts
    case mode
    when 1
        print "先手は"
    when -1
        print "後手は"
    end
    print "どのplayerにしますか？\n"
    for x in 0..$players.length-1
        puts "#{x}. #{$players[x]}"
    end
    while true
        n = gets.chomp.to_i
        if n < $players.length
            return "$p" + n.to_s
        else
            puts "入力が誤っています。"
        end
    end
end

class Version < Player
    @verName = ""
    @fileName = ""
    @funcName = ""
    def setNames(v1,v2)
        @record = []
        @verName = "#{v1}.#{v2}"
        @verVariable = "#{v1},#{v2}"
        @fileName = "akuukan_value" + @verName + ".rb"
        @funcName = "value_#{v1}_#{v2}"
        @playerName = "ver" + @verName
        @playerNum = -$versions.length
    end
    def verName
        return @verName
    end
    def verVariable
        return @verVariable
    end
    def loadFile
        load @fileName
    end
    def value(b,a,bcapture,wcapture)
        send(@funcName,b,a,bcapture,wcapture)
    end
end
    
def addVersion(v1,v2)
    if $versions == []
        name = "$a"
    else
        alphabet = $versions[-1]
        name = alphabet.next #versionsの最後の要素の次のアルファベット
    end
    f = File.open("akuukan_memory.rb", "r")
    line = ""
    text = ""
    while true
        if line == "#####versionここまで\n"
            text += "\n#{name} = Version.new\n$versions += [\"" + name + "\"]\n" + name + ".setNames(#{v1},#{v2})\n"
        end
        text += line
        begin
            line = f.readline
        rescue EOFError
            break
        end
    end
    f.close
    f = File.open("akuukan_memory.rb", "w")
    f.write text
    f.close
    load "akuukan_memory.rb"
    puts "追加が完了しました。🤗"
end

def chooseVersion(mode)
    puts
    print "どのversionを"
    case mode
    when 0
        print "相手"
    when 1
        print "先手"
    when 2
        print "後手"
    end
    print "にしますか？次の中から選んでください。\n"
    for x in 0..$versions.length-1
        puts "#{$versions[x][1]}. ver#{eval($versions[x]).verName}"
    end
end

def deleteLastVersion
    name = $versions[-1]
    f = File.open("akuukan_memory.rb","r")
    text = ""
    line = ""
    while true
        if line == "#{name} = Version.new\n"
            line = f.readline
            line = f.readline
        else
            text += line
        end
        begin
            line = f.readline
        rescue EOFError
            break
        end
    end
    f.close
    f = File.open("akuukan_memory.rb","w")
    f.write(text)
    f.close
    f = File.open("akuukan_memory.rb","r")
    text = ""
    line = ""
    load "akuukan_memory.rb"
    puts "削除が完了しました。😎"
end

def deleteAllVersion
    f = File.open("akuukan_memory.rb", "r")
    line = ""
    text = ""
    while true
        text += line
        if line == "#####version倉庫\n"
            while line != "#####versionここまで\n"
                line = f.readline
            end
            text += "#####versionここまで\n"
        end
        begin
            line = f.readline
        rescue EOFError
            break
        end
    end
    f.close
    f = File.open("akuukan_memory.rb", "w")
    f.write text
    f.close
    load "akuukan_memory.rb"
    puts "削除が完了しました。😎"
end

def reset
    f = File.open("akuukan_memory.rb", "w")
    f.write("require \"./akuukan_player.rb\"\n$players = [\"ゲスト\"]\n$versions = []\n$reqcapture = 10 #なっんことったら上がりにするか\n\n#####player倉庫\n#####playerここまで\n\n#####version倉庫\n#####versionここまで\n\n#####record倉庫\n#####recordここまで")
    f.close
    load "akuukan_memory.rb"
end