function theta = computeAngleBetweenAdjacentFaces(arr_py)
    % Convert Python list to MATLAB array
    arr_mat = cellfun(@(x) cell2mat(cellfun(@double, cell(x), 'UniformOutput', false)), cell(arr_py), 'UniformOutput', false);
    arr_mat = vertcat(arr_mat{:});
    
    % Get only the relevant rows by eliminating isolated control points at the
    % ends of curves containing the design variables
    first_col = arr_mat(:, 1);
    [unique_ids, ~, id_indices] = unique(first_col, 'stable');
    id_counts = accumarray(id_indices, 1);
    repeated_ids = unique_ids(id_counts > 1);
    arr_mat_mod = arr_mat(ismember(first_col, repeated_ids), :);
    arr_mat_mod(:, 5) = []; % Remove the coincidence ID, this does not play any role for this analysis
    
    % Extract relevant columns
    ids = arr_mat_mod(:, 1);
    groups = arr_mat_mod(:, 2);
    data = arr_mat_mod(:, end-2:end); % Last three columns
    
    % Find unique IDs and their indices
    [unique_ids, ~, id_indices] = unique(ids);
    
    % Average the data for each unique ID
    arr_matAveraged = arrayfun(@(col) accumarray(id_indices, data(:, col), [], @mean), 1:size(data, 2), 'UniformOutput', false);
    arr_matAveraged = [arr_matAveraged{:}];
    
    % Define a custom function to get the first element
    firstElement = @(x) x(1);
    
    % Combine the results with the unique IDs and their corresponding groups
    % Use 'first' to get the first occurrence of the group for each unique ID
    group_for_each_id = accumarray(id_indices, groups, [], firstElement);
    
    % Concatenate the results
    arr_matAveraged = [unique_ids, group_for_each_id, arr_matAveraged];
    
    % Get number of pairs
    pairIds = arr_matAveraged(:, 2);
    pairIdsUnique = unique(pairIds);
    numPairs = numel(pairIdsUnique);
    theta = zeros(numPairs, 1);
    for ii = 1:numPairs
        jj = find(pairIdsUnique(ii) == pairIds);
        if numel(jj) ~= 2
            error("A group of more than 2 adjacent surfaces found")
        end
        norVct1 = arr_matAveraged(jj(1), end-2:end);
        norVct2 = arr_matAveraged(jj(2), end-2:end);

        % Compute the cross product between the two vectors
        crossProd = cross(norVct1, norVct2);

        % Compute the dot product between the two vectors
        scalProd = norVct1*transpose(norVct2);

        % Compute the angle in radians
        thetaRad = atan2(norm(crossProd), scalProd);

        % Determine the sign using the z-component of the cross product
        thetaSgn = sign(crossProd(3)); % Assuming z-axis as reference

        % Compute the signed angle in degrees
        theta(ii, 1) = rad2deg(thetaSgn*thetaRad);
    end

end
