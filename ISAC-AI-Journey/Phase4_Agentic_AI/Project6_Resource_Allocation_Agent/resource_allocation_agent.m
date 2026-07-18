%% ISAC Agentic AI Project 6: Autonomous Resource Allocation Agent
% Author: Your Name
% Description: This script sets up an Agentic loop where a local LLM calls
%              custom MATLAB engineering functions as tools to optimize an 
%              ISAC link configuration.
% GitHub Category: Agentic AI / Resource Allocation

clear; clc; close all;

%% 1. Register MATLAB Functions as Agent Tools
disp('--- Registering Local Engineering Tools ---');

% Define Tool 1: Shannon Capacity Calculator
t1 = openAIFunction("calculateShannon", "Calculates communication channel capacity in Mbps.");
t1 = addParameter(t1, "bandwidth_MHz", type="number", description="The transmission bandwidth in MHz.", RequiredParameter=true);
t1 = addParameter(t1, "snr_dB", type="number", description="The signal to noise ratio in dB.", RequiredParameter=true);

% Define Tool 2: Radar Resolution Calculator
t2 = openAIFunction("calculateRadarRes", "Calculates radar range tracking resolution in meters.");
t2 = addParameter(t2, "bandwidth_MHz", type="number", description="The radar waveform bandwidth in MHz.", RequiredParameter=true);

% Define Tool 3: Constraints Checker
t3 = openAIFunction("checkConstraints", "Validates if design parameters pass operational limits.");
t3 = addParameter(t3, "capacity_Mbps", type="number", description="Calculated data rate in Mbps.", RequiredParameter=true);
t3 = addParameter(t3, "resolution_m", type="number", description="Calculated radar resolution in meters.", RequiredParameter=true);

% Group all tools together
isac_tools = [t1, t2, t3];

%% 2. Instantiate the Local Agent Architecture
disp('--- Initializing Local Mistral-Nemo Agent via Ollama ---');
sys_prompt = "You are an automated ISAC Resource Allocation Agent. " + ...
             "Your goal is to optimize bandwidth to find a valid system pass. " + ...
             "Always call tools using the correct parameters and evaluate their responses step-by-step.";

% Connect to local Ollama instance with function calling capability
agent = ollamaChat("mistral-nemo", sys_prompt, Tools=isac_tools);

%% 3. Issue the High-Level Autonomous Engineering Prompt
engineering_goal = "We have an active link with an SNR of 12 dB. " + ...
                   "Test a bandwidth of 30 MHz first. If constraints fail, " + ...
                   "increment bandwidth by 50 MHz steps until checkConstraints passes.";

% Set up the agent interaction memory trace
messages = messageHistory;
messages = addUserMessage(messages, engineering_goal);

%% 4. The Agentic Execution & Reasoning Loop
disp('--- Starting Autonomous Execution Loop ---');
max_turns = 6;
turn = 1;

while turn <= max_turns
    fprintf('\n--- [Agent Turn %d] Processing Reasoning Matrix ---\n', turn);
    
    % Generate next action prediction from the LLM
    [~, responseMessage, responseText] = generate(agent, messages);
    
    % If the agent responded with text and did not invoke a tool, we are finished
    if isempty(responseMessage.ToolCalls)
        fprintf('\n================= AGENT FINAL DECISION =================\n');
        disp(responseText);
        fprintf('========================================================\n');
        break;
    end
    
    % Process the Tool Call invoked by the Agent
    tool_call = responseMessage.ToolCalls(1);
    func_name = tool_call.Function.Name;
    func_args = jsondecode(tool_call.Function.Arguments);
    
    fprintf('>>> Agent decided to execute tool: %s\n', func_name);
    disp(func_args);
    
    % Execute the matching MATLAB function using the agent's arguments
    switch func_name
        case "calculateShannon"
            result = calculateShannon(func_args.bandwidth_MHz, func_args.snr_dB);
        case "calculateRadarRes"
            result = calculateRadarRes(func_args.bandwidth_MHz);
        case "checkConstraints"
            result = checkConstraints(func_args.capacity_Mbps, func_args.resolution_m);
        otherwise
            result = "Error: Unknown tool.";
    end
    
    fprintf('<<< Function Output returned to Agent: %s\n', string(result));
    
    % Append the tool request and the mathematical result back into the agent's memory
    messages = addAssistantMessage(messages, responseMessage);
    messages = addToolMessage(messages, tool_call.Id, string(result));
    
    turn = turn + 1;
end
