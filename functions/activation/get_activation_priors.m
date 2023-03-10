function [subject,properties] = get_activation_priors(subject,properties)

disp('=================================================================');
disp('BC-V-->> Getting activation priors.');

Headmodel       = subject.Headmodel;
Sc              = subject.Scortex;
activ_params    = properties.activ_params.sssblpp_params;
aSulc           = activ_params.aSulc.value; % baseline of sulci curvature factor
aGiri           = activ_params.aGiri.value; % baseline of giri curvature factor
bSulc           = activ_params.bSulc.value; % scale of sulci curvature factor
bGiri           = activ_params.bGiri.value; % scale of giri curvature factor
IsCurv          = activ_params.IsCurv.value; % 0 (no compensation) 1 (giri and sulci curvature compensation)
IsParcel        = activ_params.IsParcel.value; % 0 (no smoothness) 1 (parcel smoothness)
IsNeigh         = activ_params.IsNeigh.value;
IsField         = activ_params.IsField.value; % 1 (projected Lead Field) 3 (3D Lead Field)
Ke              = Headmodel.Ke;
GridOrient      = Headmodel.GridOrient;
GridAtlas       = Headmodel.GridAtlas;
Atlas           = Sc.Atlas(Sc.iAtlas).Scouts;
Faces           = Sc.Faces;
%%
%% parcel/field options
%%
if(isempty(Atlas))
   IsParcel = 0; 
end

disp('-->> Creating parcel smoother');
if IsParcel == 0
    if (IsField == 1) || (IsField == 2)
        parcellation   = cell(length(Ke)/3,1);
        for area = 1:length(Ke)/3
            parcellation{area}      = area;
        end
    elseif IsField == 3
        parcellation = cell(length(Ke)/3,1);
        for area = 1:length(Ke)/3
            q0                      = 3*(area-1);
            parcellation{area}      = [q0+1;q0+2;q0+3];
        end
    end
elseif IsParcel == 1
    if (IsField == 1) || (IsField == 2)
        parcellation        = cell(length(Atlas),1);
        for area = 1:length(Atlas)
            parcellation{area}      = Atlas(area).Vertices;
        end
    elseif IsField == 3
        parcellation      = cell(length(Atlas),1);
        for area = 1:length(Atlas)
            for node = 1:length(Atlas(area).Vertices)
                q0                  = 3*(Atlas(area).Vertices(node)-1);
                tmp_parcellation    = [q0+1;q0+2;q0+3];
                parcellation{area} = cat(1,parcellation{area},tmp_parcellation);
            end
        end
    end
end
subject.parcellation  = parcellation;

%%
%% neigh/field options
%%
disp('-->> Creating Laplacian & Normals');
regLaplacian    = activ_params.regLaplacian.value;
[D,D3D]         = graph_laplacian(Faces,regLaplacian);
I               = speye(length(D));
Dinv            = I/D;
Dinv            = (Dinv + Dinv)/2;
I               = speye(length(D3D));
D3Dinv          = I/D3D;
D3Dinv          = (D3Dinv + D3Dinv)/2;
if (~IsNeigh)
    if IsField == 1
        W       = speye(length(D));
        Winv    = speye(length(D));
    elseif IsField == 2
        Ninv    = blk_diag(GridOrient',1);
        W       = Ninv;
        Winv    = W';
    elseif IsField == 3
        W       = speye(length(D3D));
        Winv    = speye(length(D3D));
    end
elseif (IsNeigh)
    if IsField == 1
        W       = Dinv;
        Winv    = D;
    elseif IsField == 2
        Ninv    = blk_diag(GridOrient',1);
        DNinv   = Ninv*Dinv;
        W       = DNinv;
        Winv    = D*Ninv';
    elseif IsField == 3
        W       = D3Dinv;
        Winv    = D3D;
    end
end
subject.W       = W;
subject.Winv    = Winv;

%%
%% curv/field options
%%
disp('-->> Creating curvature compensator');
if IsField == 1
    Ke                    = bst_gain_orient(Ke, GridOrient,GridAtlas);
end

if IsCurv == 1
    Curv                  = Sc.Curvature;
    Sulc                  = Sc.SulciMap;
    Curv                  = abs(Curv);
    CurvSulc              = zeros(length(Curv),1);
    CurvGiri              = zeros(length(Curv),1);
    CurvSulc(Sulc == 1)   = aSulc + bSulc.*Curv(Sulc == 1);
    CurvSulc(Sulc == 0)   = 1;
    CurvGiri(Sulc == 0)   = aGiri + bGiri.*Curv(Sulc == 0);
    CurvGiri(Sulc == 1)   = 1;
    if IsField == 1
        Ke_giri               = Ke.*repmat(CurvGiri',size(Ke,1),1);
        Ke_sulc               = Ke.*repmat(CurvSulc',size(Ke,1),1);
    elseif IsField == 2 || IsField == 3
        Sulc3D                = zeros(1,3*length(Sulc));
        CurvSulc3D            = zeros(1,3*length(Curv));
        CurvGiri3D            = zeros(1,3*length(Curv));
        node3 = 1;
        for node = 1:length(Curv)
            CurvSulc3D([node3 node3+1 node3+2]) = repmat(CurvSulc(node),1,3);
            CurvGiri3D([node3 node3+1 node3+2]) = repmat(CurvGiri(node),1,3);
            Sulc3D([node3 node3+1 node3+2])     = repmat(Sulc(node),1,3);
            node3                               = node3 + 3;
        end
        Ke_giri               = Ke.*repmat(CurvGiri3D,size(Ke,1),1);
        Ke_sulc               = Ke.*repmat(CurvSulc3D,size(Ke,1),1);
    end
    subject.Ke_giri = Ke_giri;
    subject.Ke_sulc = Ke_sulc;
end

subject.Ke = Ke;
 
end