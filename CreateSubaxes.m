function varargout = CreateSubaxes(varargin)
%CreateSubaxes Opens a figure window and returns the handles of subaxes created
%   based on input info
%
% axHandles = CreateSubaxes(figHandle,axSpecs)
% axHandles = CreateSubaxes(figHandle, axSpecs1, axSpecs2,...)
% Inputs:
% figHandle - Handle of the figure on which to create subaxes
% axSpecs   - 4 element vector : axSpecs(1) - scaling factor along x-dim
%             axSpecs(2) = scaling factor along y-dim
%             axSpecs(3)= translation along x-dim
%             axSpecs(4) = translation along y-dim
%
% For e.g., axHandle = CreateSubaxes(figHandle, [0.5 0.4 0.3 0.2]) returns
% the axes handle for an axes plotted on figure with handle = figHandle
% with the axis being 0.5 times as big as the originial default matlab axes
% along the x-dim, 0.4 times as big along the y-dim and translated by 0.3 &
% 0.4 along the x, and y dimensions in the same units as scaling.
%
% Written by Avinash Pujala, JRC, 2015

figure(varargin{1})
clf

if nargin < 2
    error('Must specify axes positions!')
end

if numel(varargin{2}) ~= 4
    error('2nd input must have 4 elements!')
end
ax = zeros(nargin-1,1);
for jj = 1:nargin-1
    ax(jj) = axes; box off
    set(ax(jj),'tickdir','out')
    axPos = get(ax(jj),'position');
    axVec = varargin{jj+1};
    axPos_out = axPos;
    % 1st scale the axes
    axPos_out(3) = (axPos(3))*axVec(1);
    axPos_out(4) = (axPos(4))*axVec(2);
%     set(ax(jj),'position',axPos_out)
    % Next translate the axes
    axPos_out(1) = ((axPos(3))*axVec(3)) + axPos(1);
    axPos_out(2) = ((axPos(4))*axVec(4)) + axPos(2);
    set(ax(jj),'position',axPos_out)
   end
varargout{1} = ax;
end

