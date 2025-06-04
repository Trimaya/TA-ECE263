function summarizedViolations = RuleCheckerPlusPlus(data)
    totalViolations = 0;
    
    % Use a containers.Map to collect violations by type.
    % The stored value for each key is a struct with:
    %  - iterations (array of violation iteration numbers)
    %  - penaltySum (total penalty points for that violation type)
    %  - count (number of occurrences)
    violationDict = containers.Map();
    
    % Example data partitioning
    A1p = data(1:3,:);
    A1u = data(4:5,:);
    A2p = data(6:8,:);
    A2u = data(9:10,:);
    A3p = data(11:13,:);
    A3u = data(14:15,:);
    
    A12min = 1;
    A13min = 1;
    A23min = 1;
    
    for i = 1:size(data,2)
        % Determine airspace and compute distances
        airspace1 = get_airspace(A1p(1,i), A1p(2,i));
        airspace2 = get_airspace(A2p(1,i), A2p(2,i));
        airspace3 = get_airspace(A3p(1,i), A3p(2,i));
        distance12 = distance(A1p(:,i), A2p(:,i));
        distance23 = distance(A2p(:,i), A3p(:,i));
        distance13 = distance(A1p(:,i), A3p(:,i));
        
        %% Distance violation checks
        if airspace1 ~= 'T' && airspace2 ~= 'T'
            if distance12 < A12min
                A12min = distance12;
            end
            if distance12 < 0.25
                key = sprintf('Distance violation between A1 (in %s) and A2 (in %s)', airspace1, airspace2);
                violationDict = addViolation(violationDict, key, i);
                totalViolations = totalViolations + 1;
            end
        end
        if airspace2 ~= 'T' && airspace3 ~= 'T'
            if distance23 < A23min
                A23min = distance23;
            end
            if distance23 < 0.25
                key = sprintf('Distance violation between A2 (in %s) and A3 (in %s)', airspace2, airspace3);
                violationDict = addViolation(violationDict, key, i);
                totalViolations = totalViolations + 1;
            end
        end
        if airspace1 ~= 'T' && airspace3 ~= 'T'
            if distance13 < A13min
                A13min = distance13;
            end
            if distance13 < 0.25
                key = sprintf('Distance violation between A1 (in %s) and A3 (in %s)', airspace1, airspace3);
                violationDict = addViolation(violationDict, key, i);
                totalViolations = totalViolations + 1;
            end
        end
        
        %% Velocity violation checks (High velocity violations)
        [limv1, limvomega1] = get_velocity(1,1,airspace1);
        [limv2, limvomega2] = get_velocity(1,1,airspace2);
        [limv3, limvomega3] = get_velocity(1,1,airspace3);
        
        if A1u(1,i) > limv1
            key = sprintf('High Linear Velocity violation of A1 while in %s', airspace1);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A1u(2,i) > limvomega1
            key = sprintf('High Angular Velocity violation of A1 while in %s', airspace1);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A2u(1,i) > limv2
            key = sprintf('High Linear Velocity violation of A2 while in %s', airspace2);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A2u(2,i) > limvomega2
            key = sprintf('High Angular Velocity violation of A2 while in %s', airspace2);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A3u(1,i) > limv3
            key = sprintf('High Linear Velocity violation of A3 while in %s', airspace3);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A3u(2,i) > limvomega3
            key = sprintf('High Angular Velocity violation of A3 while in %s', airspace3);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        
        %% Velocity violation checks (Low linear velocity violations)
        [limv1_low, ~] = get_velocity(0,0,airspace1);
        [limv2_low, ~] = get_velocity(0,0,airspace2);
        [limv3_low, ~] = get_velocity(0,0,airspace3);
        
        if A1u(1,i) < limv1_low
            key = sprintf('Low Linear Velocity violation of A1 while in %s', airspace1);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A2u(1,i) < limv2_low
            key = sprintf('Low Linear Velocity violation of A2 while in %s', airspace2);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
        if A3u(1,i) < limv3_low
            key = sprintf('Low Linear Velocity violation of A3 while in %s', airspace3);
            violationDict = addViolation(violationDict, key, i);
            totalViolations = totalViolations + 1;
        end
    end  % End of iteration loop
    
    %% Summarize and report results including penalty points
    violationKeys = violationDict.keys;
    totalPenaltyPoints = 0;
    fprintf('\n\n===== Summary of Violations =====\n');
    for idx = 1:length(violationKeys)
        keyStr = violationKeys{idx};
        record = violationDict(keyStr);
        iterSummary = summarizeIterationList(record.iterations);
        fprintf('[Iteration %s] %s | Count: %d, Penalty: %d points\n',...
                iterSummary, keyStr, record.count, record.penaltySum);
        totalPenaltyPoints = totalPenaltyPoints + record.penaltySum;
    end
    fprintf('\nTotal penalty: %d points\n', totalPenaltyPoints);
    
    summarizedViolations = totalPenaltyPoints;
end

%% Helper function to accumulate a violation into the dictionary.
function violDict = addViolation(violDict, key, iteration)
    penalty = getPenalty(key);  % Determine penalty based on airspace in key string.
    if violDict.isKey(key)
        record = violDict(key);
        record.iterations(end+1) = iteration;
        record.penaltySum = record.penaltySum + penalty;
        record.count = record.count + 1;
        violDict(key) = record;
    else
        record.iterations = iteration;
        record.penaltySum = penalty;
        record.count = 1;
        violDict(key) = record;
    end
end

%% Helper function to decide the penalty for a violation.
% If the violation key contains '(in X)' anywhere, assign 50 points; otherwise 5 points.
function p = getPenalty(key)
    if contains(key, '(in X)')
        p = 50;
    else
        p = 5;
    end
end

%% Helper function to summarize iteration ranges from a list of iterations.
function summary = summarizeIterationList(iterations)
    iterations = sort(iterations);
    summaryParts = {};
    startIdx = iterations(1);
    previous = iterations(1);
    
    for k = 2:length(iterations)
        if iterations(k) == previous + 1
            previous = iterations(k);
        else
            if startIdx == previous
                summaryParts{end+1} = sprintf('%d', startIdx);
            else
                summaryParts{end+1} = sprintf('%d-%d', startIdx, previous);
            end
            startIdx = iterations(k);
            previous = iterations(k);
        end
    end
    
    % Append final range/group.
    if startIdx == previous
        summaryParts{end+1} = sprintf('%d', startIdx);
    else
        summaryParts{end+1} = sprintf('%d-%d', startIdx, previous);
    end
    
    summary = strjoin(summaryParts, ', ');
end
