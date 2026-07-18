%% ISAC Generative AI Project 5: Local 3GPP Bot
% Author: Your Name
% Description: This script implements a Retrieval-Augmented Generation (RAG)
%              lite workflow. It feeds a raw 3GPP specification text snippet
%              to a local LLM via Ollama to answer structural technical questions.
% GitHub Category: Generative AI / Text-driven Telecom Analytics

clear; clc; close all;

%% 1. Define the 3GPP Technical Document Snippet
% Simulating a paragraph straight out of a 3GPP Release 18/19 ISAC spec
document_context = [...
    '3GPP TS 38.555 Section 4.2: Integrated Sensing and Communication (ISAC) ' ...
    'architectures utilize co-designed wave resource provisioning. For high-accuracy ' ...
    'radar target tracking, the base station must allocate a minimum radar sensing ' ...
    'bandwidth of 150 MHz when operating within the sub-6 GHz spectrum. If the vehicle ' ...
    'velocity exceeds 120 km/h, the system configuration must automatically enable ' ...
    'a multi-beam subcarrier pattern with a 60 kHz Subcarrier Spacing (SCS) ' ...
    'to counter high Doppler spreads. For standard communication-only links, ' ...
    'the default configurations default back to 30 kHz Subcarrier Spacing.'];

%% 2. Connect to the Local Ollama Instance
disp('--- Initializing Local Llama 3.2 Model via Ollama ---');
try
    % Connect to Ollama using the toolbox class wrapper
    bot_agent = ollamaChat("llama3.2:1b", ...
        "You are an expert 3GPP Telecom Standardization Assistant. " + ...
        "Answer the user query based ONLY on the provided document context.");
catch ME
    error('Could not connect to Ollama. Make sure Ollama is running and you executed "ollama pull llama3.2:1b" in cmd.');
end

%% 3. Define the Engineering Inquiry
user_query = 'What is the required Subcarrier Spacing configuration if an ISAC vehicle is traveling at 140 km/h?';

fprintf('\n--- Document Context Loaded ---\n%s\n', document_context);
fprintf('\n--- User Query Sent ---\n%s\n', user_query);

%% 4. Engineer the Prompt Matrix (RAG Context Injection)
engineered_prompt = sprintf([...
    'CONTEXT DOCUMENT:\n%s\n\n' ...
    'QUESTION:\n%s\n\n' ...
    'INSTRUCTION: Formulate a precise engineering answer using the information in the context.'], ...
    document_context, user_query);

%% 5. Generate Response from the AI
disp('--- Querying Local LLM (Processing on CPU) ---');
[~, response] = generate(bot_agent, engineered_prompt);

%% 6. Display the Finalized Extraction
fprintf('\n================= BOT RESPONSE =================\n');
disp(response);
fprintf('================================================\n');

% Save output log to document execution for GitHub portfolio
fid = fopen('bot_output_log.txt', 'w');
if fid ~= -1
    fprintf(fid, 'Query: %s\n\nResponse:\n%s', user_query, response);
    fclose(fid);
    disp('--- Saved output log to bot_output_log.txt ---');
end
