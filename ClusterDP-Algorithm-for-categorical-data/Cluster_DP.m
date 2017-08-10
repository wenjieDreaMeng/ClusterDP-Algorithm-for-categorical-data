function [cl] = Cluster_DP(Data,dist,ClusterNum)

%   doc��       Clustering by fast search and find of density peaks
%   Modify:     2017.2.21
%   Author:     wenjie

global fid;
isShowPicture = 0;          %   �Ƿ���Ҫ��ʾ����ͼ��0��ʾ����ʾ��1��ʾ��ʾ����ͼ


%   ������ĶԳƵ�������ת��Ϊ��һ��Ϊi,�ڶ���Ϊj��������Ϊd��ij������ʽ
xx = [];
[row,col] = size(dist);
for i = 1:row
    for j = i+1:col;
        xx = [xx;[i,j,dist(i,j)]];
    end
end

ND = max(xx(:,2));                      %   ��������
NL = max(xx(:,1));
if NL > ND
    ND = NL;
end
maxd = max(max(dist));              %   �ܶ����ĵ㣬����max(dij)��Ϊ��õ��deltaֵ
nneigh = zeros(1,row);

for bindwidth = 0.1:0.1:0.9
    rho = CateSampleDensity(Data(:,[1:size(Data,2)-1]),bindwidth);
    fprintf(fid,'bindwidth is %.1f \n',bindwidth);
    
    [rho_sorted,ordrho] = sort(rho,'descend');
    delta(ordrho(1)) = -1.;             %   �ܶ����ĵ㣬deltaֵ��Ϊ-1
    nneigh(ordrho(1)) = 0;
    
    %   ���ÿ�����ݽڵ��deltaֵ����������ܶȵ����С����
    for i = 2:ND
        delta(ordrho(i)) = maxd;
        for j = 1:i-1
            if(dist(ordrho(i),ordrho(j)) < delta(ordrho(i)))
                delta(ordrho(i)) = dist(ordrho(i),ordrho(j));
                %   nneigh�������ÿ�����ݽڵ�ľ�������ܶȵ�ı��
                nneigh(ordrho(i)) = ordrho(j);
            end
        end
    end
    delta(ordrho(1)) = max(delta(:));
    
    if isShowPicture == 1
        scrsz = get(0,'ScreenSize');
        figure('Position',[0 0 scrsz(3) scrsz(4)]);
    end
    
    for i=1:ND
        gamma(i) = rho(i) * delta(i);             %   ���ÿһ�����rho��delta�ĳ˻�,���մӴ�С���ɵõ��������ĵ�
    end
    
    if isShowPicture == 1
        %   ��ͼ����Decision Graphͼ
        subplot(2,1,1);
        plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
        title ('Decision Graph','FontSize',15.0)
        xlabel ('\rho')
        ylabel ('\delta')
    end
    
    %   ordrho��¼��rho_sorted�ڶ�Ӧ��gamma�е�����
    [rho_sorted,ordrho] = sort(gamma,'descend');
    %   ClusterCenterInd��¼��gamma��ǰClusterNum����Ϊ�������ĵ�����
    ClusterCenterInd = ordrho([1:ClusterNum]);
    
    %   cl��ע����������Ϊ�ڼ����������ĵ�,-1Ϊ�Ǿ������ĵ�
    for i = 1:ND
        if ismember(i,ClusterCenterInd) == 0        %   ��i����ClusterCenterInd�е�Ԫ��ʱ
            cl(i) = -1;
        else
            cl(i) = find(i == ClusterCenterInd);    %   ��i��ClusterCenterInd�е�Ԫ��ʱ,��¼���ǵڼ�����������
        end
    end
    
    %   ���¾������ĵ���������,��i���������ĵ�ΪԴ�����еĵڼ�������
    for i = 1:ClusterNum
        icl(i) = ClusterCenterInd(i);
    end
    
    %   ���ݴ��ݹ����ҵ�ÿһ���Ǿ������ĵ��������ڵľ�������
    while ismember(-1,cl) == 1
        for i = 1:ND
            if cl(ordrho(i)) == -1
                cl(ordrho(i))=cl(nneigh(ordrho(i)));
            end
        end
    end
    
    for i = 1:ClusterNum
        nc = 0;
        nh = 0;
        for j = 1:ND
            %   nc��ʾ��i�����������������������Cluster Core������������Clister Hole�е�����������
            if (cl(j)==i)
                nc = nc + 1;
            end
        end
    end
    
    if isShowPicture == 1
        %   ��Decision Graph�л����������ĵ㣬��ɫ����
        cmap = colormap;
        for i = 1:ClusterNum
            ic = int8((i*64.)/(ClusterNum*1.));
            subplot(2,1,1)
            hold on
            plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',5,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
        end
    end
    
    if isShowPicture == 1
        subplot(2,1,2)
        Y1 = mdscale(dist, 2, 'criterion','metricsstress');
        plot(Y1(:,1),Y1(:,2),'o','MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k');
        title ('2D Nonclassical multidimensional scaling','FontSize',15.0);
        xlabel ('X');
        ylabel ('Y');
        
        for i = 1:ND
            A(i,1) = 0.;
            A(i,2) = 0.;
        end
        for i = 1:ClusterNum
            nn = 0;
            ic = int8((i*64.)/(ClusterNum*1.));
            for j = 1:ND
            end
            if isShowPicture == 1
                hold on
                plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
            end
        end
    end
    
    [Cluster_DP_AC,Cluster_DP_PR,Cluster_DP_RE,Cluster_DP_CV] = AC_PR_RE(cl,Data(:,size(Data,2)));
    [Cluster_DP_NMI] = NMI(cl,Data(:,size(Data,2)));
    [Cluster_DP_ARI] = AdjustedRandIndex(cl,Data(:,size(Data,2)));
    fprintf(fid,'DP_Average_AC  = %8.4f		DP_Average_NMI = %8.4f      DP_Average_ARI = %8.4f	  	',Cluster_DP_AC,Cluster_DP_NMI,Cluster_DP_ARI);
    fprintf(fid,'DP_Average_PR = %8.4f      DP_Average_RE = %8.4f\n',Cluster_DP_PR,Cluster_DP_RE);
end

end
