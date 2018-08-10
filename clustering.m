% �M�ŵe��
clear ; close all; clc

styles = {'b+'; 'c+'; 'm+'; 'y+'; 'g+'; 'k+'; 'r+'; 'bs'; 'cs'; 'gs'};

% �H���ͥ͸s���˥��ƾ�
X = [];   % �˥��ƾ�
m = 100;  % �C�s���ƾڶq
n = 5;   % �s���ƥ�
r = 3;    % �ƾ����
for i = 1:n
  X(m*(i-1)+1:m*i,:) = rand(1, 2) * (r-1) + rand(m, 2);
  y(m*(i-1)+1:m*i) = i;
end

% ��ܭ�˥��ƾ�
figure(1);
for i = 1:n
  index = find(y == i);
  hold on;
  plot(X(index,1), X(index,2), styles{i}, 'MarkerSize', 5);
  hold off;
end
printf("samples...(enter to next)...\n");
pause;

figure(2);
plot(X(:,1), X(:,2), styles{1}, 'MarkerSize', 5);
printf("for reference...(enter to next)...\n");
pause;

for k = 1:size(styles)
  printf("clustering (k=%d)...\n", k);
  
  % �H���ͦ��аO�I
  Landmark = rand(k, 2) * r;
  figure(3);
  hold on;
  plot(Landmark(:,1), Landmark(:,2), 'ko', 'MarkerSize', 10);
  hold off;

  prev_error = 0;
  curr_error = 1;
  while (curr_error - prev_error) .^ 2 >= 0.1
    % �p��˥��ƾڨ�аO�I�~�t, �Ω��ݸs��
    for i = 1:k
      ERROR(:, i) = sum((X - Landmark(i,:)) .^ 2, 2);
    end
    prev_error = curr_error;
    curr_error = sum(sum(ERROR, 1), 2);
    [v, y] = min(ERROR, [], 2);

    % ��ܤ������G
    figure(3);
    plot(Landmark(:,1), Landmark(:,2), 'r.', 'MarkerSize', 30);

    for i = 1:k
      index = find(y == i);
      hold on;
      plot(X(index,1), X(index,2), styles{i}, 'MarkerSize', 5);
      hold off;
    end
    
    % ��s�аO�I
    for i = 1:k
      index = find(y == i);
      if size(index) > 0
        Landmark(i,:) = mean(X(index,:));
      else
        Landmark(i,:) = rand(1, 2) * r;
      endif
    end
    
    pause(0.1);
  end
  printf("next...");
  pause;
end
printf("END");