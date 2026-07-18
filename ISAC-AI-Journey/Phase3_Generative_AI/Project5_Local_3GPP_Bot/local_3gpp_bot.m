%% ISAC Generative AI Project 5: Local 3GPP Bot (Native REST API Edition)
% Author: Malak ElSalamouny
% Description: Queries local Ollama directly via HTTP POST and native JSON structures.
% GitHub Category: Generative AI / Text-driven Telecom Analytics

clear; clc; close all;

%% 1. Technical Document Snippet
document_context = [...
    '3GPP TS 38.555 Section 4.2: Integrated Sensing and Communication (ISAC) ' ...
    'architectures utilize co-designed wave resource provisioning. For high-accuracy ' ...
    'radar target tracking, the base station must allocate a minimum radar sensing ' ...
    'bandwidth of 150 MHz when operating within the sub-6 GHz spectrum. If the vehicle ' ...
    'velocity exceeds 120 km/h, the system configuration must automatically enable ' ...
    'a multi-beam subcarrier pattern with a 60 kHz Subcarrier Spacing (SCS) ' ...
    'to counter high Doppler spreads. For standard communication-only links, ' ...
    'the default configurations default back to 30 kHz Subcarrier Spacing.'];

user_query = 'What is the required Subcarrier Spacing configuration if an ISAC vehicle is traveling at 140 km/h?';

%% 2. Setup Native Prompt Structure
engineered_prompt = sprintf([...
    'You are an expert 3GPP Telecom Assistant. Answer the question based ONLY on the context.\n\n' ...
    'CONTEXT DOCUMENT:\n%s\n\n' ...
    'QUESTION:\n%s\n\n' ...
    'ANSWER:'], document_context, user_query);

%% 3. Formulate the REST API Call parameters
url = 'http://localhost:11434/api/generate';

% CRITICAL FIX: Raise timeout from 60 seconds to 300 seconds (5 minutes)
options = weboptions('MediaType', 'application/json', 'Timeout', 300);

% SPEED OPTIMIZATION: We add a 'options' struct inside the payload to limit 
% the model's generation window, making it process much faster on your CPU.
llm_hyperparameters = struct(...
    'num_predict', 100, ...   % Stop generating text after ~75 words (keeps answers concise)
    'temperature', 0.1);      % Lower temperature makes the model faster and more deterministic

% Build the request body payload
request_payload = struct(...
    'model', 'llama3.2:1b', ...
    'prompt', engineered_prompt, ...
    'stream', false, ...
    'options', llm_hyperparameters); % Inject the speed optimizations

%% 4. Dispatch the HTTP POST Request
disp('--- Sending Request directly to Local Ollama API ---');
disp('--- (Processing on CPU: Please wait, this may take 1-2 minutes) ---');
try
    % Send payload and automatically decode JSON response string to a MATLAB struct
    json_response = webwrite(url, jsonencode(request_payload), options);
    response = json_response.response;
    
    % Display output layout
    fprintf('\n================= BOT RESPONSE =================\n');
    disp(response);
    fprintf('================================================\n');
    
catch ME
    error('API Query failed. Make sure Ollama is open and running llama3.2:1b. Error details: %s', ME.message);
end
