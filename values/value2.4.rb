def make2d(h,w)
  Array.new(h){Array.new(w,0)}
end

def value_2_4(b,a,bcapture,wcapture)
  black = gatherColor(b,1)
  white = gatherColor(b,-1)
  value = make2d(19,19)
  for i in 0..18
    for j in 0..18
      if i > 7 && i < 11 && j > 7 && j < 11
          value[i][j] = 20
      elsif i > 5 && i < 13 && j > 5 && j < 13
          value[i][j] = 10
      elsif i > 2 && i < 16 && j > 2 && j < 16
          value[i][j] = 3
      end
    end
  end
  for i in 0..18
    for j in 0..18
      if b[i][j] != 0
        value[i][j] = 0
      else
        for k in 0..black.length-1 #i,jとすべての黒石とを直線で結ぶ
          count = 1 #等間隔にある点の数
          capacity = 2 #その直線上だと何個まで並べられるか。
          stop = false
          front = []
          back = []
          x = black[k][0] - i
          y = black[k][1] - j
          if [x,y] - [0,1,-1] == []
            value[i][j] -= 5
          else
            for l in 2..4
              if hanninai(i+l*x,j+l*y,18) #外に出るのを防ぐ
                front += [b[i+l*x][j+l*y]]
                case b[i+l*x][j+l*y]
                when 1
                 count += 1
                 capacity += 1
                when 0
                 capacity += 1
                when -1
                  if b[i+(l-1)*x][j+(l-1)*y] == 1
                    stop = true
                    break
                  else
                    break
                  end
                end
              else
                break
              end
            end
            for l in 1..3
              if hanninai(i-l*x,j-l*y,18)
                back += [b[i-l*x][j-l*y]]
                case b[i-l*x][j-l*y]
                when 1
                  count += 1
                  capacity += 1
                when 0
                  capacity += 1
                when -1
                  if l == 1
                    stop = true
                    break
                  elsif b[i-(l-1)*x][j-(l-1)*y] == 1
                    stop = true
                    break
                  else
                    break
                  end
                end
              else
                break
              end
            end
            case count #３，４，５を作る
              when (4..7) #４個並んでいる時
                value[i][j] +=100000
              when 3 #３個並んでいる時
                if !stop && capacity >= 6
                  if front[0] == 0
                    value[i][j] += 100
                  else
                    value[i][j] += 1000
                  end
                elsif capacity >= 5 && a == 1
                  value[i][j] += 30
                end
              when 2
                if capacity >= 6 && !stop && a == 1
                  if back[0] == -1
                    if x <= 2 && y <= 2
                      value[i][j] += 27
                    else
                      value[i][j] += 15
                    end
                  else
                    value[i][j] += 50
                  end
                end
            end
            if front[1] == -1 && front[0] == 1 #黒が取られるのを防ぐ/白が取る
              case wcapture
              when 8
                value[i][j] += 100000
              when 6
                value[i][j] += 1000
              else
                value[i][j] += 120
              end
            end
            if a == 1 #黒番
              if front[0] == -1 && back[0] == 0 #この時ijに置くと取られる
                case wcapture
                when 8
                  value[i][j] -= 100000
                when 6
                  value[i][j] -= 1000
                else
                  value[i][j] -= 100
                end
              elsif back[0] == -1 && front[0] == 0 #この時ijに置くと取られる
                case wcapture
                when 8
                  value[i][j] -= 100000
                when 6
                  value[i][j] -= 1000
                else
                  value[i][j] -= 100
                end
              end
            elsif a == -1 #白番
              if front[0] == 1 && front[1] == 0 #アタリを打つ
                value[i][j] += 10
              end
            end
          end
        end #終了ー黒石を直線で結ぶ
        for k in 0..white.length-1 #i,jとすべての白石とを直線で結ぶ
          count = 1 #等間隔にある点の数
          capacity = 2 #その直線上だと何個まで並べられるか。
          stop = false
          front = []
          back = []
          x = white[k][0] - i
          y = white[k][1] - j
          if [x,y] - [0,1,-1] == []
            value[i][j] -= 5
          else
            for l in 2..4
              if hanninai(i+l*x,j+l*y,18) #外に出るのを防ぐ
                front += [b[i+l*x][j+l*y]]
                case b[i+l*x][j+l*y]
                when -1
                 count += 1
                 capacity += 1
                when 0
                 capacity += 1
                when 1
                  if b[i+(l-1)*x][j+(l-1)*y] == -1
                    stop = true
                    break
                  else
                    break
                  end
                end
              else
                break
              end
            end
            for l in 1..3
              if hanninai(i-l*x,j-l*y,18)
                back += [b[i-l*x][j-l*y]]
                case b[i-l*x][j-l*y]
                when -1
                  count += 1
                  capacity += 1
                when 0
                  capacity += 1
                when 1
                  if l == 1
                    stop = true
                    break
                  elsif b[i-(l-1)*x][j-(l-1)*y] == -1
                    stop = true
                    break
                  else
                    break
                  end
                end
              else
                break
              end
            end
            case count #３，４，５を作る
            when (4..7) #４個並んでいる時
              value[i][j] +=100000
            when 3 #３個並んでいる時
              if !stop && capacity >= 6
                if front[0] == 0
                  value[i][j] += 100
                else
                  value[i][j] += 1000
                end
              elsif capacity >= 5 && a == -1
                value[i][j] += 30
              end
            when 2
              if capacity >= 6 && !stop && a ==-1
                if back[0] == -1
                  if x <= 2 && y <= 2
                    value[i][j] += 27
                  else
                    value[i][j] += 15
                  end
                else
                  value[i][j] += 50
                end
              end
            end
            if front[1] == 1 && front[0] == -1 #白が取られるのを防ぐ/黒が取る
              case bcapture
              when 8
                value[i][j] += 100000
              when 6
                value[i][j] += 1000
              else
                value[i][j] += 120
              end
            end
            if a == -1 #白番
              if front[0] == 1 && back[0] == 0 #この時ijに置くと取られる
                case bcapture
                when 8
                  value[i][j] -= 100000
                when 6
                  value[i][j] -= 1000
                else
                  value[i][j] -= 100
                end
              elsif back[0] == 1 && front[0] == 0 #この時ijに置くと取られる
                case bcapture
                when 8
                  value[i][j] -= 100000
                when 6
                  value[i][j] -= 1000
                else
                  value[i][j] -= 100
                end
              end
            elsif a == 1 #黒番
              if front[0] == -1 && front[1] == 0 #アタリを打つ
                value[i][j] += 10
              end
            end
          end
        end #終了ー白石と直線で結ぶ
      end
    end
  end
  return value
end
