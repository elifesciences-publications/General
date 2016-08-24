function [blockSizes, blockInds] = GetContiguousBlocks(values)
        % Given a set of values, returns the sizes of contiguous blocks and the
        %   block start indices
        blockInds = 1;
        blockSizes = [];
        count = 1;
        for jj = 1:length(values)-1
            if (values(jj+1)-values(jj))==1
                count = count+1;
            else
                blockSizes = [blockSizes; count];
                count = 1;
                blockInds =[blockInds; jj+1];
            end
        end        
        blockSizes = [blockSizes; count];
    end