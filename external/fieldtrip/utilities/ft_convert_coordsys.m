function [obj] = ft_convert_coordsys(obj, target, opt, template)

% FT_CONVERT_COORDSYS changes the coordinate system of the input object to
% the specified coordinate system. The coordinate system of the input
% object is determined from the structure field object.coordsys, or need to
% be determined interactively by the user.
%
% Use as
%   [object] = ft_convert_coordsys(object)
% to only determine the coordinate system, or
%   [object] = ft_convert_coordsys(object, target)
%   [object] = ft_convert_coordsys(object, target, opt)
%   [object] = ft_convert_coordsys(object, target, opt, template);
% to determine and convert the coordinate system.
%
% The optional input argument opt determines the behavior when converting
% to the spm coordinate system. 
%
% The following input objects are supported
%   anatomical mri, see FT_READ_MRI
%   anatomical or functional atlas, see FT_PREPARE_ATLAS
%   (not yet) electrode definition
%   (not yet) gradiometer array definition
%   (not yet) volume conductor definition
%   (not yet) dipole grid definition
%
% Possible target coordinate systems are 'spm'.
%
% Note that the conversion will be an automatic one, which means that it
% will be an approximate conversion, not taking into account differences in
% individual anatomies/differences in conventions where to put the
% fiducials.
%
% See also FT_DETERMINE_COORDSYS

% Copyright (C) 2005-2011, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_convert_coordsys.m 7220 2012-12-18 08:40:18Z jansch $

if ~isfield(obj, 'coordsys') || isempty(obj.coordsys)
  % determine the coordinate system of the input object
  obj = ft_determine_coordsys(obj, 'interactive', 'yes');
end

% set default behavior to use an approximate alignment, followed by a call
% to spm_normalise for a better quality alignment
if nargin<3
  opt = 2;
end

if isdeployed && (opt==1 || opt==2)
  needtemplate = true;
else
  needtemplate = false;
end

if needtemplate && nargin<4
  error('you need to specify a template filename for the coregistration');
end

hastemplate = nargin>3;

if nargin>1 && ~strcmpi(target, obj.coordsys)
  % convert to the desired coordinate system
  switch target
    case {'spm' 'mni' 'tal'}
      switch obj.coordsys
        case {'ctf' 'bti' '4d'}
          fprintf('Converting the coordinate system from %s to %s\n', obj.coordsys, target);
          if hastemplate
            obj = align_ctf2spm(obj, opt, template);
          else
            obj = align_ctf2spm(obj, opt);
          end
        case {'itab' 'neuromag'}
          fprintf('Converting the coordinate system from %s to %s\n', obj.coordsys, target);
          if hastemplate
            obj = align_ctf2spm(obj, opt, template);
          else
            obj = align_itab2spm(obj, opt);
          end
        otherwise
      end %switch obj.coordsys
    otherwise
      error('conversion from %s to %s is not yet supported', obj.coordsys, target);
  end %switch target
end
