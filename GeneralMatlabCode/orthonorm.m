function orthoNormBasis = orthonorm(varargin)
b=varargin{:};
u1=unitvec(varargin{1});
u2= unitvec(varargin{2} - proj(varargin{2},u1));
u3 =unitvec(varargin{3}-(proj(varargin(2),u1) + proj(varargin{3},u2)));
orthoNormBasis=[u1 u2 u3]