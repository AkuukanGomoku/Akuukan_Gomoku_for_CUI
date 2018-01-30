require "./memory.rb"
board = Array.new(25).map{Array.new(25,2)} #空いてるますが0、黒マス白マスがそれぞれ1,-1、盤面の外は2
for i in 0..18
    for j in 0..18
        board[i][j] = 0
    end
end
a = 1 #どっちの番かを指す 1が黒番　-1が白番　先手は黒
gameSet = false #ゲームセットのお条件満たしたらしたらtrueになる
gameMode = 0 #0が二人プレー 1,-1が一人プレー 1が先手、-1が後手 2がコンピューター同士
te = 0 #何手目か
change = [] #盤面の変化の過程を記録
ver = ["$a","",""] #相手のVERSION
player = ["$p0","",""]
$winner = 0
def value(b,a,bcapture,wcapture,ver)
    if ver == 1
        return value_2_1(b,a,bcapture,wcapture)
    elsif ver == 2
        return value_2_3(b,a,bcapture,wcapture)
    end
end

def integer_string?(str) #文字列が整数かどうか判定する関数　入力を受け付ける時のためだけに導入
    Integer(str)
    true
rescue ArgumentError
    false
end

def hanninai(x,y,r) #xとyがともに0以上r以下であるかを調べる関数
    return (x >= 0 && y >= 0 && x <= r && y <= r)
end

def player(a,gM) #プレーヤーのターンの時のみtrue
    return (gM == 0 || gM == a)
end

def display(b,a,gS,gM)
    d = Array.new(19).map{Array.new(0)}
    m = 0
    placeable = []
    for i in 0..18
        for j in 0..18
            if gS
                case b[i][j]
                when 1
                    d[i][j] = "⚫️"
                when -1
                    d[i][j] = "⚪️"
                else
                    d[i][j] = "＋"
                end
            else
                case b[i][j]
                when 1
                    d[i][j] = " ⚫️ "
                when -1
                    d[i][j] = " ⚪️ "
                when 0
                    if m < 10
                        d[i][j] = "  #{m} "
                    elsif m < 100
                        d[i][j] = " #{m} "
                    else
                        d[i][j] = "#{m} "
                    end
                    m = m + 1
                    placeable = placeable + [[i,j]]
                end
            end
        end
    end
    for r in 0..18
        for s in 0..18
            print d[r][s]
        end
        if gS
            print "\n"
        else
            puts
            puts
        end
    end
    if gS
    else
        if a == 1 && gM == 0
            print "黒番です。置きたい場所の数字を入力してEnterを押してください。\n"
        elsif a == -1 && gM == 0
            print "白番です。置きたい場所の数字を入力してEnterを押してください。\n"
        elsif gM == a
            print "あなたの番です。置きたい場所の数字を入力してEnterを押してください。\n"
        else
            print "私の番です。\n"
        end
        return placeable, m
    end
end

def gatherColor(b,a) #その色の目の場所を記録していく
    c = []
    for i in 0..18
        for j in 0..18
            if b[i][j] == a
                c = c + [[i,j]]
            end
        end
    end
    c
end

def put_and_search(i,j,b,a,bcapture,wcapture,te,c)
    b[i][j] = a
    if te < c.length #本来ここでは等しい
        c = c[0..te-1] #置く前に本来これから起こるはずだった未来を消去し、新しい未来を切り開く
    end
    c += [[[i,j,0,a]]] #マス（i,j）が0だったのだが、それをaにしたという意味
    black = gatherColor(b,1)
    white = gatherColor(b,-1)
    gomoku = false
    if black.length > 0
        for k in 0..black.length-1 #i,jとすべての黒石とを直線で結ぶ
            count = 0 #等間隔にある点の数
            x = black[k][0] - i
            y = black[k][1] - j
            if [x,y] - [0,1,-1] != [] #[x,y]と[0,1,-1]の差集合が空集合でない時
                if a == 1 && hanninai(x.abs,y.abs,18.0/4.0) #計算量を減らすためにx,yの範囲を指定 .absは絶対値を表す
                    for l in 2..5
                        if b[i+l*x][j+l*y] == 1
                            count = count + 1
                        else
                            break
                        end
                    end
                    for l in 1..5
                        if b[i-l*x][j-l*y] == 1
                            count = count + 1
                        else
                            break
                        end
                    end
                    if count >= 3
                        gomoku = true
                    end
                elsif a == -1 && hanninai(x.abs,y.abs,18.0/3.0) && b[i+2*x][j+2*y] == 1 && b[i+3*x][j+3*y] == -1 #白黒黒白と並んだ時
                    b[i+x][j+y] = 0
                    b[i+2*x][j+2*y] = 0
                    c[-1] += [[i+x,j+y,1,0],[i+2*x,j+2*y,1,0]]
                    wcapture = wcapture + 2
                    if wcapture < 10
                        puts "＿人人人人人人人人人人人人人人人人人人人人人人人人人＿"
                        puts "＞黒石が2つ奪われました!!あと#{10-wcapture}個取られると負けです!!＜"
                        puts "￣Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^￣"
                    end
                end
            end
        end
    end
    if white.length > 0
        for k in 0..white.length-1 #i,jとすべての白石とを直線で結ぶ
            x = white[k][0] - i
            y = white[k][1] - j
            if [x,y] - [0,1,-1] != []
                if a == -1 && hanninai(x.abs,y.abs,18.0/4.0)
                    for l in 2..5
                        if b[i+l*x][j+l*y] == -1
                            count = count + 1
                        else
                            break
                        end
                    end
                    for l in 1..5
                        if b[i-l*x][j-l*y] == -1
                            count = count + 1
                        else
                            break
                        end
                    end
                    if count >= 3
                        gomoku = true
                    else
                        count = 0
                    end
                elsif a == 1 && hanninai(x.abs,y.abs,18.0/3.0) && b[i+2*x][j+2*y] == -1 && b[i+3*x][j+3*y] == 1 #黒白しろくろ
                    b[i+x][j+y] = 0
                    b[i+2*x][j+2*y] = 0
                    c[-1] += [[i+x,j+y,-1,0],[i+2*x,j+2*y,-1,0]]
                    bcapture = bcapture + 2
                    if bcapture < 10
                        puts "＿人人人人人人人人人人人人人人人人人人人人人人人人人＿"
                        puts "＞白石が2つ奪われました!!あと#{10-bcapture}個取られると負けです!!＜"
                        puts "￣Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^Y^￣"
                    end
                end
            end
        end    
    end
    return gomoku, b, bcapture, wcapture, c
end

def back_and_forth(b,a,bcapture,wcapture,te,c,forth)
    if forth
        for k in 0..c[te].length-1
            b[c[te][k][0]][c[te][k][1]] = c[te][k][3]
            if k == 2 && a == 1
                bcapture += 2
            elsif k == 2 && a == -1
                wcapture += 2
            end
        end
        te += 1
    else
        te -= 1
        for k in 0..c[te].length-1
            b[c[te][k][0]][c[te][k][1]] = c[te][k][2]
            if k == 2 && a == 1
                wcapture -= 2
            elsif k == 2 && a == -1
                bcapture -= 2
            end
        end
    end
    a = -a
    return b, a, bcapture, wcapture, te, c
end

def bestChoice(b,a,v)
    choices = []
    maxvalue = 0
    for i in 0..18
        for j in 0..18
            if v[i][j] > maxvalue
                choices = [[i,j]]
                maxvalue = v[i][j]
            elsif v[i][j] == maxvalue
                choices += [[i,j]]
            end
        end
    end
    #puts maxvalue
    r = rand(0..choices.length-1)
    #print choices
    return choices[r]
end

def oneTurn(b,a,bcapture,wcapture,gS,gM,req,te,c,ver)
    placeable, m = display(b,a,gS,gM)
    if player(a,gM)
        while true
            n = gets.chomp
            puts
            if n == "+" && ((te < c.length && gM == 0) || te+1 < c.length)
                b, a, bcapture, wcapture, te, c = back_and_forth(b,a,bcapture,wcapture,te,c,true)
                if gM !=  0
                    b, a, bcapture, wcapture, te, c = back_and_forth(b,a,bcapture,wcapture,te,c,true) #COMのターンの分も進む。
                end
                placeable, m = display(b,a,gS,gM)
            elsif n == "-" && ((te > 0 && gM == 0) || te-1 > 0)
                b, a, bcapture, wcapture, te, c = back_and_forth(b,a,bcapture,wcapture,te,c,false)
                if gM != 0
                    b, a, bcapture, wcapture, te, c = back_and_forth(b,a,bcapture,wcapture,te,c,false) #COMのターンの分も戻る。
                end
                placeable, m = display(b,a,gS,gM)
            elsif integer_string?(n) && Integer(n) >= 0 && Integer(n) < m
                n = Integer(n)
                break
            elsif n == "+"
                puts "これ以上進めません。"
            elsif n == "-"
                puts "これ以上戻れません。"
            else
                puts "0以上#{m-1}以下の半角数字で入力してください。"
            end
        end
        gomoku, b, bcapture, wcapture, c = put_and_search(placeable[n][0],placeable[n][1],b,a,bcapture,wcapture,te,c)
    else
        if gM != 2
            sleep(1)
        end

        v = eval(ver[a]).value(b,a,bcapture,wcapture)
=begin
        for r in 0..18
            for s in 0..18
                if b[r][s] == 1
                    print " ⚫️ "
                elsif b[r][s] == -1
                    print " ⚪️ "
                elsif v[r][s] < 10 && v[r][s] >= 0
                    print "  #{v[r][s]} "
                elsif v[r][s] < 100 && v[r][s] > -10
                    print " #{v[r][s]} "
                elsif v[r][s] < 1000 && v[r][s] > -100
                    print "#{v[r][s]} "
                else
                    print v[r][s]
                end
            end
            puts
            puts
        end
=end
        bch = bestChoice(b,a,v)
        #puts bch
        gomoku, b, bcapture, wcapture, c = put_and_search(bch[0],bch[1],b,a,bcapture,wcapture,te,c)
    end
    te += 1
    if (a == 1 && gomoku) || bcapture >= 10
        gS = true
        $winner = a
        if bcapture >= 10
            puts
            print "#{bcapture-10+req}個取ったので"
        else
            puts
            print "五目並んだので"
        end
        print "黒の勝利！！(#{te}手)\n" 
        display(b,a,gS,gM)    
    elsif (a == -1 && gomoku) || wcapture >= 10
        gS = true
        $winner = a
        if wcapture >= 10
            puts
            print "#{wcapture-10+req}個取ったので"
        else
            puts
            print "五目並んだので"
        end
        print "白の勝利！！(#{te}手)\n"
        display(b,a,gS,gM)
    end
    a = -a
    return b, a, bcapture, wcapture, gS, te, c
end

#####ここからUI
input = "?"
puts "\n亜空間五目並べにようこそ😄"

while true
    puts
    puts "以下から数字を選んで入力し、Enterを押してください。"
    puts "1. 対戦する"
    puts "2. COM同士を戦わせる"
    puts "3. 設定/その他"
    puts "0. 終了"
    input = gets.chomp
    if integer_string?(input) && [Integer(input)] - [0,1,2,3] == []
        case Integer(input)
        when 1
            while true
                puts "以下から数字を選んで入力し、Enterを押してください。"
                puts "1. 一人プレー"
                puts "2. 二人プレー" 
                puts "0. 戻る"
                g1 = gets.chomp.to_i
                case g1
                when 1
                    if $versions.length == 0
                        puts "\nまず設定からCOMを追加してください。"
                        g1 = 0
                        break
                    end
                    puts "先手がよければ1を、後手が良ければ2を入力し、Enterを押してください。"
                    while true
                        g2 = gets.chomp.to_i
                        case g2
                        when 1,2
                            arr = [0,1,-1] #行数減らす工夫
                            gameMode = arr[g2]
                            break
                        else
                            puts "半角数字の1か2を入力してください"
                        end
                    end
                    player[gameMode] = choosePlayer(0)
                    puts
                    chooseVersion(0)
                    print "入力しEnterを押してください。\n"
                    while true
                        ver0 = gets.chomp 
                        if ["$" + ver0] - $versions == []
                            player[2/g2] = "$" + ver0
                            ver[2/g2] = "$" + ver0
                            eval("$" + ver0).loadFile
                            break
                        else
                            puts "対応するアルファベットを入力してください"
                        end
                    end
                    break
                when 2
                    player[1] = choosePlayer(1)
                    player[-1] = choosePlayer(-1)
                    gameMode = 0
                    break
                when 0
                    break
                else
                    puts "半角数字の1か2を入力してください"
                end
            end
            if g1 != 0
                break
            end
        when 2
            if $versions.length == 0
                puts "\nまず設定からCOMを追加してください。"
            else
                gameMode = 2
                while ver - $versions != []
                    chooseVersion(1)
                    ver0 = gets.chomp
                    player[1] = "$" + ver0
                    ver[1] = "$" + ver0
                    chooseVersion(2)
                    ver0 = gets.chomp
                    player[-1] = "$" + ver0
                    ver[-1] = "$" + ver0
                    if ver - $versions != []
                        puts "入力が誤っています。"
                    end
                end
                start = Time.now
                eval(ver[1]).loadFile
                eval(ver[2]).loadFile
                break
            end
        when 3
            while true
                puts
                puts "設定メニュー"
                puts "1. プレーヤーの追加"
                puts "2. COMの追加/削除"
                puts "3. ルール変更"
                puts "4. 戦績確認"
                puts "5. 初期化"
                puts "0. 戻る"
                input = gets.chomp
                if integer_string?(input) && [Integer(input)] - [0,1,2,3,4,5] == []
                    case Integer(input)
                    when 1
                        puts "追加するプレーヤーの名前を入力してください。"
                        name = gets.chomp
                        addPlayer(name)
                    when 2
                        while true
                            puts "以下から数字を選んで入力し、Enterを押してください。"
                            puts "1. 追加"
                            if $versions.length != 0
                                puts "2. 一つ削除"
                                puts "3. 全て削除"
                            end 
                            puts "0. 戻る"
                            input = gets.chomp
                            if integer_string?(input) && [Integer(input)] - [0,1,2,3] == []
                                case Integer(input)
                                when 1 
                                    puts "追加したいバージョンの番号を、「.」の前と後に分けて入力してください"
                                    v1 = gets.chomp.to_i
                                    v2 = gets.chomp.to_i
                                    addVersion(v1,v2)
                                when 2
                                    if $versions.length != 0
                                        puts "最後に追加したversion#{eval($versions[-1]).verName}を削除します。よろしければEnterを押してください。"
                                        puts "1. はい"
                                        puts "0. いいえ"
                                        i = gets.chomp.to_i
                                        if i == 1
                                            deleteLastVersion
                                        end
                                    end
                                when 3
                                    if $versions.length != 0
                                        puts "全てのversionを削除します。よろしいですか？(value関数のファイルそのものは消えません。)"
                                        puts "1. はい"
                                        puts "0. いいえ"
                                        i = gets.chomp.to_i
                                        if i == 1
                                            deleteAllVersion
                                        end
                                    end
                                when 0
                                    break
                                end
                            else
                                puts "入力が誤っています。"
                            end
                        end
                    when 3
                        puts "何個奪ったら勝ちにしますか?"
                        while true
                            n = gets.chomp.to_i
                            if integer_string?(n)
                                f = File.open("akuukan_memory.rb","r")
                                text = f.read
                                f.close
                                text.gsub!("$reqcapture = #{$reqcapture}" ,"$reqcapture = #{n}")
                                f = File.open("memory.rb","w")
                                f.write(text)
                                f.close
                                $reqcapture = n
                                puts "変更しました。👍"
                                break
                            else
                                puts "入力が誤っています。"
                            end
                        end
                        break
                    when 4
                        while true
                            puts "\n誰の戦績を確認しますか？"
                            for x in 0..$versions.length-1
                                puts "#{$versions[x][1]}. ver#{eval($versions[x]).verName}"
                            end
                            for x in 1..$players.length-1
                                puts "#{x}. #{$players[x]}"
                            end
                        puts "0. 戻る"
                            who = gets.chomp
                            if integer_string?(who) && Integer(who) != 0
                                name = "$p" + who
                            elsif who == "0"
                                break
                            elsif ["$" + who] - $versions == []
                                name = "$" + who
                            else
                                puts "入力が誤っています。"
                            end
                            eval(name).showRecord
                        end
                    when 5
                        puts "初期化します。よろしいですか？"
                        puts "1. はい"
                        puts "0. いいえ"
                        i = gets.chomp.to_i
                        if i == 1
                            reset
                            puts "初期化しました。😇"
                        end
                    when 0
                        break
                    end
                else
                    puts "入力が誤っています。"
                end
            end
        when 0
            exit
        end
    else
        puts "入力が誤っています。"
    end
end

bcapture = 10 - $reqcapture #黒番の人がとった白石の数　maxは10
wcapture = 10 - $reqcapture

while !gameSet
    board, a, bcapture, wcapture, gameSet, te, change = oneTurn(board,a,bcapture,wcapture,gameSet,gameMode,$reqcapture,te,change,ver)
end
if $winner != 0 && player - ["$p0"] != []
    eval(player[$winner]).addRecord(player[-$winner],1)
    eval(player[-$winner]).addRecord(player[$winner],0)
end

if gameMode == 2
    puts "#{Time.now - start}秒"
end

