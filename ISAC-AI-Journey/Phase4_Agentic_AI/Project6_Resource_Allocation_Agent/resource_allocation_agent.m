%% ISAC Agentic AI Project 6: Autonomous Resource Allocation Agent (Native API Edition)
% Author: Malak ElSalamouny
% Description: Native ReAct engineering agent loop communicating via raw JSON scripts.
% GitHub Category: Agentic AI / Resource Allocation

clear; clc; close all;

%% 1. Establish System Configuration Prompts
% We instruct the LLM to format its actions as parsed JSON blocks so MATLAB can split them.
system_instruction = [...
    'You are an expert ISAC Resource Allocation Agent. You have access to three tools:\n' ...
    '1. calculateShannon: inputs {"bandwidth_MHz": X, "snr_dB": Y}. Returns capacity_Mbps.\n' ...
    '2. calculateRadarRes: inputs {"bandwidth_MHz": X}. Returns resolution_m.\n' ...
    '3. checkConstraints: inputs {"capacity_Mbps": X, "resolution_m": Y}. Returns status.\n\n' ...
    'CRITICAL RULE: You can only call ONE tool per turn. Your output must consist of exactly ' ...
    'ONE valid JSON object. Do not stack multiple JSON objects or combine tools in a single response.\n\n' ...
    'To use a tool, reply with exactly this structure and nothing else:\n' ...
    '{"thought": "Your reasoning here", "tool": "tool_name", "args": {"param": value}}\n\n' ...
    'When checkConstraints returns "PASSED", then and only then, finish by replying with this single structure:\n' ...
    '{"thought": "Final wrap up", "tool": "final_decision", "args": {"message": "Success Summary"}}\n'];


conversation_history = system_instruction;

% High level target objective
engineering_goal = ['\nGoal: The system has an active link with an SNR of 12 dB. ' ...
                    'Test a bandwidth of 30 MHz first. If constraints fail, increment ' ...
                    'bandwidth by 50 MHz steps until checkConstraints passes. Begin now.'];

conversation_history = [conversation_history, engineering_goal];

%% 2. Configure HTTP Target
url = 'http://localhost:11434/api/generate';
options = weboptions('MediaType', 'application/json', 'Timeout', 60);

%% 3. Main Agentic Reasoning & Tool-Execution Loop
disp('--- Launching Dependency-Free Agent Interaction Matrix ---');
max_turns = 5;
turn = 1;

while turn <= max_turns
    fprintf('\n--- [Turn %d] Requesting Model Action ---\n', turn);
    
    % Assemble payload using the cumulative text memory tree
    payload = struct('model', 'llama3.2:1b', 'prompt', conversation_history, 'stream', false);
    
    try
        json_output = webwrite(url, jsonencode(payload), options);
        raw_agent_reply = json_output.response;
    catch ME
        error('Agent request failed: %s', ME.message);
    end
    
    % Strip formatting tags if the local LLM wraps its JSON response in markdown blocks
    raw_agent_reply = strrep(raw_agent_reply, '```json', '');
    raw_agent_reply = strrep(raw_agent_reply, '```', '');
    raw_agent_reply = strtrim(raw_agent_reply);
    
    % Parse the AI's execution block
    try
        agent_action = jsondecode(raw_agent_reply);
        fprintf('Thought Process: %s\n', agent_action.thought);
    catch
        fprintf('Warning: Model deviated from JSON tracking notation. Raw response:\n%s\n', raw_agent_reply);
        break;
    end
    
    % Evaluate if the agent has reached a successful optimization state
    if strcmp(agent_action.tool, 'final_decision')
        fprintf('\n================= AGENT AUTONOMOUS TERMINATION =================\n');
        disp(agent_action.args.message);
        fprintf('================================================================\n');
        break;
    end
    
    % Execute the requested local MATLAB script tool
    executed_tool = agent_action.tool;
    tool_args = agent_action.args;
    tool_result = "";
    
   
    switch executed_tool
        case 'calculateShannon'
            % DEFENSIVE FIX: Check if the LLM mismatched the casing of snr_dB
            target_snr = 12; % Default fallback to your engineering goal prompt
            if isfield(tool_args, 'snr_dB')
                target_snr = tool_args.snr_dB;
            elseif isfield(tool_args, 'snr_db')
                target_snr = tool_args.snr_db;
            elseif isfield(tool_args, 'snr')
                target_snr = tool_args.snr;
            end
            
            % Check for bandwidth variations as well
            target_bw = 30;
            if isfield(tool_args, 'bandwidth_MHz')
                target_bw = tool_args.bandwidth_MHz;
            elseif isfield(tool_args, 'bandwidth_mhz')
                target_bw = tool_args.bandwidth_mhz;
            end
            
            % Execute tool safely with resolved variables
            res_val = calculateShannon(target_bw, target_snr);
            tool_result = sprintf('capacity_Mbps = %.2f', res_val);

        case 'calculateRadarRes'
            res_val = calculateRadarRes(tool_args.bandwidth_MHz);
            tool_result = sprintf('resolution_m = %.4f', res_val);
        case 'checkConstraints'
            tool_result = checkConstraints(tool_args.capacity_Mbps, tool_args.resolution_m);
        otherwise
            tool_result = "Error: Selected function identifier not found.";
    end
    
    fprintf('>>> Action Executed: %s. Output: %s\n', executed_tool, tool_result);
    
    % Append the thought matrix, the tool call, and the script result back to the conversation tree
    conversation_history = sprintf('%s\nAgent: %s\nEnvironment Tool Response: %s', ...
        conversation_history, raw_agent_reply, tool_result);
    
    turn = turn + 1;
end
