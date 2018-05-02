classdef LinOpMultiPoseConv<  LinOp
    %% LinOpConv : Convolution operator
    %  Matlab Linear Operator Library
    %
    % -- Example:
    % Obj = LinOpConv(psf, index)
    % Convolution operator with  PSF psf along the dimension
    % indexed in INDEX (all by default)
    %
    % Please refer to the LINOP superclass for general documentation about
    % linear operators class
    % See also LinOp DFT Sfft iSFFT
    
    %     Copyright (C) 2015 F. Soulez ferreol.soulez@epfl.ch
    %
    %     This program is free software: you can redistribute it and/or modify
    %     it under the terms of the GNU General Public License as published by
    %     the Free Software Foundation, either version 3 of the License, or
    %     (at your option) any later version.
    %
    %     This program is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    properties (SetAccess = protected, GetAccess = public)
        psf
        pose
        symmetry
        mtf
        index
        Notindex
        ndms
        HtH0
        Hty0
    end
    methods
        function this = LinOpMultiPoseConv(psf,pose,symmetry,index)
            if nargin <= 2
                symmetry = '';
            end
            if nargin <= 3
                index = [];
            end
            this.name ='LinOp Multi-Poses Convolution';
            this.isInvertible=false;
            
            assert(isnumeric(psf),'The psf should be a');
            this.psf = psf;
            if ~isreal(psf), this.iscomplex= true; end
            this.pose = pose;
            this.sizeout =[];
            this.sizein = [];
            
            this.ndms = length(this.sizein);
            % Special case for vectors as matlab thought it is matrix ;-(
            if this.ndms==2 && (this.sizein(2) ==1 || this.sizein(1) ==1)
                this.ndms = 1;
            end
            
            if (~isempty(symmetry))
                this.symmetry=symmetry;
            end
            if (~isempty(index))
                assert(isvector(index) && length(index)<= this.ndms && max(index)<= this.ndms,'The index should be a conformable  to sz');
                this.index = index;
                dim = 1:this.ndms;
                Iidx = true(this.ndms,1);
                Iidx(index) = 0;
                this.Notindex = dim(Iidx);
            else
                this.index = 1:this.ndms;
                this.Notindex = [];
            end
            
            this.mtf = Sfft(this.psf, this.Notindex);
            
            if all(this.mtf)
                this.isInvertible=true;
            else
                this.isInvertible=false;
            end
            
            % -- Norm of the operator
            this.norm=max(abs(this.mtf(:)));
            
        end
        function precompute(this,y) 
            this.sizeout=size(y);
            this.sizein=[size(y,1),size(y,2),size(y,3)];
            nbPoses = size(y,4);
            this.HtH0 = 0;
            this.Hty0 = 0;
            
            if strcmp(this.symmetry,'C9') || strcmp(this.symmetry,'C20') %% TEMPORARY CODE: HAS TO BE GENERALIZED TO EVERY CN
                if strcmp(this.symmetry,'C9'),N=9;end
                if strcmp(this.symmetry,'C20'),N=20;end
                
                poseC = new_poses_symmetryC(this.pose,N);
                for i=1:nbPoses*N
                    k = mod(i-1,nbPoses)+1;
                    yr = bigfluo_apply_pose_inverse(y(:,:,:,k), poseC(i,:));
                    psfr = bigfluo_apply_pose_inversePSF(this.psf, poseC(i,:));
                    sizePad=(size(yr)-size(psfr))/2;
                    psfr=padarray(psfr,sizePad);

                    H=LinOpConv(fftn(psfr));         

                    this.HtH0 = this.HtH0 + abs(conj(H.mtf).*H.mtf);
                    this.Hty0 = this.Hty0 + conj(H.mtf).*fftn(fftshift(yr));%H'*yr;
                end
                this.HtH0=this.HtH0/(nbPoses*N);
                this.Hty0=this.Hty0/(nbPoses*N);
            else            
                for i=1:nbPoses
                    yr = bigfluo_apply_pose_inverse(y(:,:,:,i), this.pose(i,:));
                    psfr = bigfluo_apply_pose_inversePSF(this.psf, this.pose(i,:));
                    sizePad=(size(yr)-size(psfr))/2;
                    psfr=padarray(psfr,sizePad);

                    H=LinOpConv((psfr));         

                    this.HtH0 = this.HtH0 + abs(conj(H.mtf).*H.mtf);
                    this.Hty0 = this.Hty0 + conj(H.mtf).*fftn(fftshift(yr));%H'*yr;
                end
                this.HtH0=this.HtH0/nbPoses;
                this.Hty0=this.Hty0/nbPoses;
            end    
        end
    end
	methods (Access = protected)
        function y = apply_(this,x) %TODO
            assert( isequal(size(x),this.sizein),  'x does not have the right size: [%d, %d, %d]',this.sizein);
            
            this.sizeout=size(x);
            this.sizein=[size(x,1),size(x,2),size(x,3)];
            nbPoses = size(x,4);
            y = 0;
            
            if strcmp(this.symmetry,'C9') || strcmp(this.symmetry,'C20') %% TEMPORARY CODE: HAS TO BE GENERALIZED TO EVERY CN
                if strcmp(this.symmetry,'C9'),N=9;end
                if strcmp(this.symmetry,'C20'),N=20;end
                
                poseC = new_poses_symmetryC(this.pose,N);
                for i=1:nbPoses*N
                    k = mod(i-1,nbPoses)+1;
                    yr = bigfluo_apply_pose_inverse(x(:,:,:,k), poseC(i,:));
                    psfr = bigfluo_apply_pose_inversePSF(this.psf, poseC(i,:));
                    sizePad=(size(yr)-size(psfr))/2;
                    psfr=padarray(psfr,sizePad);

                    H=LinOpConv(fftn(psfr));         

                    y = y + conj(H.mtf).*fftn(fftshift(yr));%H'*yr;
                end
                y=y/(nbPoses*N);
            else            
                for i=1:nbPoses
                    yr = bigfluo_apply_pose_inverse(x(:,:,:,i), this.pose(i,:));
                    psfr = bigfluo_apply_pose_inversePSF(this.psf, this.pose(i,:));
                    sizePad=(size(yr)-size(psfr))/2;
                    psfr=padarray(psfr,sizePad);

                    H=LinOpConv((psfr));         

                    y = y + conj(H.mtf).*fftn(fftshift(yr));%H'*yr;
                end
                y=y/nbPoses;
            end    
    
        end

        function y = adjoint_(this,x) %TODO
%             assert( isequal(size(x),this.sizeout),  'x does not have the right size: [%d, %d]',this.sizeout);
%             y = iSfft( conj(this.mtf) .* Sfft(x, this.Notindex), this.Notindex );
%             if (~this.iscomplex)&&isreal(x)
%                 y = real(y);
%             end
        end
        function y = HtH_(this,x) %TODO
%             assert( isequal(size(x),this.sizein),  'x does not have the right size: [%d, %d]',this.sizein);
%             y = iSfft( (real(this.mtf).^2 + imag(this.mtf).^2) .* Sfft(x, this.Notindex), this.Notindex );
%             if (~this.iscomplex)&&isreal(x)
%                 y = real(y);
%             end
        end
        function y = HHt_(this,x)
            y=this.HtH(x);
        end
        function y=inverse_(this,x) % TODO
%             if this.isinvertible
%             assert( isequal(size(x),this.sizein),  'x does not have the right size: [%d, %d, %d]',this.sizein);
%             y = iSfft( 1./this.mtf .* Sfft(x, this.Notindex), this.Notindex );       
%             else
%                 error('Operator not invertible');
%             end
        end
        function y=adjointInverse_(this,x) %TODO
%             if this.isinvertible
%             assert( isequal(size(x),this.sizeout),  'x does not have the right size: [%d, %d]',this.sizeout);
%             y = iSfft( 1./conj(this.mtf) .* Sfft(x, this.Notindex), this.Notindex );
%             else
%                 error('Operator not invertible');
%             end
        end
    end
end
