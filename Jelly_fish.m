function Jelly_fish()
fig = figure;
fig.WindowButtonDownFcn = @myBDCallback;
fig.KeyPressFcn = @simulation_break;
fig.Position = [200 100 900 600];
fig.Color = [0.098 0.098 0.439];

n = 30;
[X0,Y0,Z0] = sphere(n);

S = 0.1;

rate = 0.7;


X0(Z0 < -0.5) = NaN;
Y0(Z0 < -0.5) = NaN;
Z0(Z0 < -0.5) = NaN;

X = S*linspace(rate,1,length(X0)).'.*X0;
Y = S*linspace(rate,1,length(X0)).'.*Y0;
Z = S*Z0;

jellyfish = surf(X,Y,Z);
hold on

jellyfish.FaceAlpha = 0.4;
jellyfish.EdgeAlpha = 0;

mycolormap = [linspace(1,0,n/2).' ones(n/2,1) ones(n/2,1)];
colormap(mycolormap)


h = -2.3:0.01:-0.5;

z = S*h;

v = 2;

for j = 0:n
    A(j+1) = rand;
    B(j+1) = rand;
    H(j+1) = 0.05*rand;
    x = A(j+1)*S*exp(h).*sin(h*pi);
    y = B(j+1)*S*exp(h).*cos(h*pi).*sin(h*pi);
    tentacle{j+1} = plot3(x - (x(end) - X(11,j+1)),y - (y(end) - Y(11,j+1)),z,'Color',[0 1 1 0.1],'LineWidth',2*S);
end

feed = scatter3(1,4.5,1,10,'yellow','filled');


axis([-3 3 -inf inf -2 2]*3)
daspect([1 1 1])
view(0,0)
axis off
yohaku
camlight

X_position = 0;
Y_position = 4.5;
Z_position = 0;
origin = [X_position Y_position Z_position];


V = 0.02;

direction = [X_position - feed.XData(1) Y_position - feed.YData(1) Z_position - feed.ZData(1)];
theta1 = atan(feed.XData(1)/feed.ZData(1))*360/(2*pi);
rotate(jellyfish,direction,theta1,origin)
for j = 0:n
    rotate(tentacle{j+1},direction,theta1,origin)
end

%video = VideoWriter("jelly_fish.avi",'Uncompressed AVI');
%open(video)

fin = 0;
i = 0;
while fin == 0    
    i = i + 1
    
    rotate(jellyfish,direction,-theta1,origin)
    for j = 0:n
        rotate(tentacle{j+1},direction,-theta1,origin)
    end
    ratei = rate*abs(sin(i*pi/90)) + 1;
    X = S*linspace(ratei,1,length(X0)).'.*X0;
    Y = S*linspace(ratei,1,length(X0)).'.*Y0;
    Z = S*Z0;

    distance = sqrt((X_position - feed.XData).^2 + (Y_position - feed.YData).^2 + (Z_position - feed.ZData).^2);
    [M,idx] = min(distance);

    if M < 0.5
        feed.XData(idx) = [];
        feed.YData(idx) = [];
        feed.ZData(idx) = [];
        S = S + 0.05;
    end

    jellyfish.XData = X + X_position;
    jellyfish.YData = Y + Y_position;
    jellyfish.ZData = Z + Z_position;

    feed.ZData(feed.ZData > -5.9) = feed.ZData(feed.ZData > -5.9) - 0.01;
    

    for j = 0:n
        x = A(j+1)*S*exp(h).*sin(h*pi + v*i*H(j+1));
        y = B(j+1)*S*exp(h).*cos(h*pi + v*i*H(j+1)).*sin(h*pi + v*i*H(j+1));
        tentacle{j+1}.XData = x - (x(end) - X(11,j+1)) + X_position;
        tentacle{j+1}.YData = y - (y(end) - Y(11,j+1)) + Y_position;
        tentacle{j+1}.ZData = S*h + Z_position;
        tentacle{j+1}.LineWidth = 2*S;
    end
    
    if M > 0.5
        X_position = X_position - V*(X_position - feed.XData(idx))/M;
        Y_position = Y_position - V*(Y_position - feed.YData(idx))/M;
        Z_position = Z_position - V*(Z_position - feed.ZData(idx))/M;

        origin = [X_position Y_position Z_position];
   
        rotate(jellyfish,direction,theta1,origin)
        for j = 0:n
            rotate(tentacle{j+1},direction,theta1,origin)
        end
        theta1 = atan(feed.XData(idx)/feed.ZData(idx))*360/(2*pi);
        direction = [X_position - feed.XData(idx) Y_position - feed.YData(idx) Z_position - feed.ZData(idx)];
    end
    drawnow
    %frame = getframe(gcf);
    %writeVideo(video,frame)
end
%close(video)
    function myBDCallback(~,~)
        Cp = get(gca, 'CurrentPoint');
        xx = Cp(1,1);
        yy = Y_position;
        zz = Cp(1,3);

        feed.XData = [feed.XData xx + 0.2*(2*rand(1,5) - 1)];
        feed.YData = [feed.YData yy + 0.2*(2*rand(1,5) - 1)];
        feed.ZData = [feed.ZData zz + 0.2*(2*rand(1,5) - 1)];
    end

    function simulation_break(~, evantdata)
        if strcmp(evantdata.Key, 'escape')
            fin = 1;
        end
    end

end