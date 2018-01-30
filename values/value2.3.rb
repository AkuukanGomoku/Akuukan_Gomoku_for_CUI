def value_2_3(b,a,bcapture,wcapture)
    value = Array.new(19).map{Array.new(19,0)}
    for i in 0..18
        for j in 0..18
            value[i][j] = 0
            if b[i][j] == 0
                if i > 6 && i < 12 && j > 6 && j < 12
                    value[i][j] += 9
                elsif i > 4 && i < 14 && j > 4 && j < 14
                    value[i][j] += 6
                elsif i > 1 && i < 17 && j > 1 && j < 17
                    value[i][j] += 3
                end
                black = gatherColor(b,1)
                white = gatherColor(b,-1)
                gomoku = false
                if black.length > 0
                    for k in 0..black.length-1 #i,jとすべての黒石とを直線で結ぶ
                        count = 0 #等間隔にある点の数
                        capacity = 0 #その直線上だと何個まで並べられるか。
                        x = black[k][0] - i
                        y = black[k][1] - j
                        if [x,y] - [0,1,-1] != [] #[x,y]と[0,1,-1]の差集合が空集合でない時
                            for l in 2..5
                                narabu = true #石の並びが途切れたらfalseになり、countを増やさなくする
                                if hanninai(i+l*x,j+l*y,18) #外に出たらエラー起きちゃうからそれを防ぐ
                                    case b[i+l*x][j+l*y]
                                    when 1
                                        if narabu
                                            count += 1
                                        end
                                        capacity += 1
                                    when 0
                                        capacity += 1
                                    else
                                        break
                                    end
                                else
                                    break
                                end
                            end
                            for l in 1..5
                                narabu = true
                                if hanninai(i-l*x,j-l*y,18)
                                    case b[i-l*x][j-l*y]
                                    when 1
                                        if narabu
                                            count += 1
                                        end
                                        capacity += 1
                                    when 0
                                        capacity += 1
                                        narabu = false
                                    else
                                        break
                                    end
                                else
                                    break
                                end
                            end
                            if a == 1
                                if capacity >= 3
                                    case count
                                    when (3..10)
                                        gomoku = true
                                        value[i][j] += 100000
                                    when 2
                                        value[i][j] += 500
                                    when 1
                                        value[i][j] += 10
                                    else
                                        value[i][j] += 1
                                    end
                                end
                                if hanninai(i+2*x,j+2*y,18) && b[i+2*x][j+2*y] == -1 && hanninai(i-x,j-y,18) #この時ijに置くと相手に取られる
                                    value[i][j] /= 2
                                elsif hanninai(i+3*x,j+3*y,18) && b[i+2*x][j+2*y] == 1 && b[i+3*x][j+3*y] == -1 #相手に取られるのを阻止
                                    case wcapture
                                    when 8
                                        value[i][j] += 50000
                                    when 6
                                        value[i][j] += 800
                                    when 4
                                        value[i][j] += 400
                                    when 2
                                        value[i][j] += 400
                                    else
                                        value[i][j] += 400
                                    end
                                end
                            elsif a == -1 && hanninai(i+3*x,j+3*y,18) && b[i+2*x][j+2*y] == 1 && b[i+3*x][j+3*y] == -1 #白黒黒白と並んべる時
                                case wcapture
                                when 8
                                    value[i][j] += 100000
                                when 6
                                    value[i][j] += 1100
                                when 4
                                    value[i][j] += 600
                                when 2
                                    value[i][j] += 600
                                else
                                    value[i][j] += 600
                                end
                            else
                                case count
                                when (3..10)
                                    value[i][j] += 50000 #白が相手の五目を阻止
                                when 2
                                    value[i][j] += 499
                                when 1 
                                    value[i][j] += 9
                                end
                            end
                        else
                            value[i][j] -= 1
                        end
                    end
                end
                if white.length > 0
                    for k in 0..white.length-1 #i,jとすべての白石とを直線で結ぶ
                        count = 0 #等間隔にある点の数
                        capacity = 0 #その直線上だと何個まで並べられるか
                        x = white[k][0] - i
                        y = white[k][1] - j
                        if [x,y] - [0,1,-1] != []
                            for l in 2..5
                                if hanninai(i+l*x,j+l*y,18)
                                    case b[i+l*x][j+l*y]
                                    when -1
                                        if narabu
                                            count += 1
                                        end
                                        capacity += 1
                                    when 0
                                        capacity += 1
                                    else
                                        break
                                    end
                                else
                                    break
                                end
                            end
                            for l in 1..5
                                if hanninai(i-l*x,j-l*y,18)
                                    case b[i-l*x][j-l*y]
                                    when -1
                                        if narabu
                                            count += 1
                                        end
                                        capacity += 1
                                    when 0
                                        capacity += 1
                                    else
                                        break
                                    end
                                else
                                    break
                                end
                            end
                            if a == -1
                                if capacity >= 3
                                    case count
                                    when (3..10)
                                        gomoku = true
                                        value[i][j] += 100000
                                    when 2
                                        value[i][j] += 500
                                    when 1
                                        value[i][j] += 10
                                    else
                                        value[i][j] += 1
                                    end
                                end
                                if hanninai(i+2*x,j+2*y,18) && b[i+2*x][j+2*y] == 1 && hanninai(i-x,j-y,18) #この時ijに置くと相手に取られる
                                    value[i][j] /= 2
                                elsif hanninai(i+3*x,j+3*y,18) && b[i+2*x][j+2*y] == -1 && b[i+3*x][j+3*y] == 1 #相手に取られるのを阻止
                                    case bcapture
                                    when 8
                                        value[i][j] += 50000
                                    when 6
                                        value[i][j] += 800
                                    when 4
                                        value[i][j] += 400
                                    when 2
                                        value[i][j] += 400
                                    else
                                        value[i][j] += 400
                                    end
                                end
                            elsif a == 1 && hanninai(i+3*x,j+3*y,18) && b[i+2*x][j+2*y] == -1 && b[i+3*x][j+3*y] == 1 #黒白白黒と並んべる時
                                case bcapture
                                when 8
                                    value[i][j] += 100000
                                when 6
                                    value[i][j] += 1100
                                when 4
                                    value[i][j] += 600
                                when 2
                                    value[i][j] += 600
                                else
                                    value[i][j] += 600
                                end
                            else
                                case count
                                when (3..10)
                                    value[i][j] += 50000 #白が相手の五目を阻止
                                when 2
                                    value[i][j] += 499
                                when 1 
                                    value[i][j] += 9
                                end
                            end
                        else
                            value[i][j] -= 1
                        end
                    end    
                end
            end
        end
    end
    return value
end