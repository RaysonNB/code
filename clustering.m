% 清空畫面
clear ; close all; clc

function drawPoint(data, mkstyle, mksize, redraw = true)
  if redraw == false
    hold on;
  endif
  if size(data)(2) == 2
    plot(data(:, 1), data(:, 2), mkstyle, 'MarkerSize', mksize);
  elseif size(data)(2) == 3
    plot3(data(:, 1), data(:, 2), data(:, 3), mkstyle, 'MarkerSize', mksize);
  endif
  if redraw == false
    hold off;
  endif
endfunction

X = [];                       % 樣本數據
m = [50; 50; 150; 200; 500];  % 每群集數據量
n = size(m);                  % 群集數目
r = [15; 8; 8; 15; 15];       % 數據集中度
R = 50;                       % 數據邊界
d = 3;                        % 維度
marker_style = 'o';
marker_size = 5;

% 隨機生生群集樣本數據
for i = 1:n
  X(end + 1:end + m(i), :) = rand(1, d) * (R - r(i)) + rand(m(i), d) * r(i);
  y(end + 1:end + m(i)) = i;
end

% 顯示原樣本數據
figure(1, 'position', [0, 550, 600, 450]);
drawPoint(X(1,:), marker_style, marker_size);
for i = 1:n
  indices = find(y == i);
  drawPoint(X(indices, :), marker_style, marker_size, false);
end
pause(1);

% 顯示無差別樣本數據
figure(2, 'position', [600, 550, 600, 450]);
drawPoint(X, marker_style, marker_size);
pause(1);

for k = 1:n
  printf("clustering (k=%d)...\n", k);
  
  % 生成標記點
  if k == 1
    % 只有一個群集時為全部樣本重心位置
    Landmark(k, :) = mean(X);
  else
    % 在最大的群集旁邊加一個新群集
    [max_value, max_index] = max(max_error);
    Landmark(k, :) = Landmark(max_index, :) + rand(1, d) * 0.01;
  endif

  % 不斷修正標記點位置直到誤差小於1e-4
  prev_error = 0;
  curr_error = 1;
  while (curr_error - prev_error) .^ 2 >= 1e-4
    % 計算樣本數據到標記點誤差, 及所屬群集
    for i = 1:k
      ERROR(:, i) = sum((X - Landmark(i, :)) .^ 2, 2);
    end
    prev_error = curr_error;
    curr_error = sum(sum(ERROR, 1), 2);
    [v, Y] = min(ERROR, [], 2);

    % 顯示標記點及分類結果
    figure(3, 'position', [0, 50, 600, 450]);
    drawPoint(Landmark, 'r.', 40);
    
    for i = 1:k
      indices = find(Y == i);
      drawPoint(X(indices, :), marker_style, marker_size, false);
      % 計算每個群集最遠的一點的距離
      max_error(i) = max(sum((X(indices, :) - Landmark(i, :)) .^ 2, 2));
    end
    
    % 更新標記點
    for i = 1:k
      indices = find(Y == i);
      if size(indices) > 0
        Landmark(i, :) = mean(X(indices, :));
      else
        % 該標記點完全沒有點時再隨機分配位置
          Landmark(i, :) = rand(1, d) * R;
      endif
    end
    
    pause(0.1);
  end
  pause(1);
end

printf("END...");
