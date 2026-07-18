# Phase 4, Project 6: Autonomous Resource Allocation Agent (Native REST API Edition)

This repository contains a dependency-free **MATLAB** implementation of an autonomous optimization agent. It wraps standard mathematical radio-frequency (RF) scripts into a schema-defined tool environment managed entirely via a local LLM reasoning engine over native HTTP POST channels.

## Problem Statement
Optimizing dual-functional variables in Integrated Sensing and Communications (ISAC) typically requires complex multi-objective optimization algorithms. This project demonstrates an alternative paradigm: giving an **AI Agent** access to simple, modular, deterministic engineering tools, a definitive boundary goal, and a dynamic execution feedback loop. 

Because this project bypasses the official MATLAB LLM Toolbox to ensure 100% platform portability, it implements custom **ReAct (Reasoning and Acting)** prompt frameworks and JSON-safeguarded parsing loops to handle raw LLM text outputs.

## Agent System Capabilities & Tools
The architecture registers three local standalone MATLAB functions (`.m` files) as executable tools exposed to the agent:
1. **`calculateShannon.m`**: Computes native communication channel data rates (Capacity in Mbps) using transmission bandwidth and SNR conditions.
2. **`calculateRadarRes.m`**: Computes spatial radar range-tracking resolution values based on operating frequencies.
3. **`checkConstraints.m`**: Validates whether the current design states pass standard operational requirements (≥ 100 Mbps throughput and ≤ 1.2 m radar step accuracy).

## Execution Architecture
- **Zero-Dependency Core:** Interoperates with local AI pipelines using MATLAB's native web connectivity primitives (`webwrite`, `jsonencode`, and `jsondecode`), dropping any reliance on external toolboxes.
- **Local Computational Footprint:** Orchestrates logic loops locally using a `mistral-nemo` model operating over a localized **Ollama** server port link.
- **Defensive Engineering Design:** Features structural fallback blocks using MATLAB's `isfield` functionality to catch and realign loose parameter nomenclature variants (e.g., handling variations like `snr_dB` vs. `snr_db`) automatically.

## Sample Operational Trace
The agent executes an autonomous **Plan → Act → Observe** state tracking sequence to balance parameters dynamically:

```text
--- [Turn 1] Requesting Model Action ---
Thought Process: Initial Bandwidth Test
>>> Action Executed: calculateShannon. Output: capacity_Mbps = 122237.56

--- [Turn 2] Requesting Model Action ---
Thought Process: Evaluating Radar Constraints
>>> Action Executed: calculateRadarRes. Output: resolution_m = 0.82

--- [Turn 3] Requesting Model Action ---
Thought Process: Checking overall system status...
>>> Action Executed: checkConstraints. Output: PASSED: Targets achieved.

================= AGENT AUTONOMOUS TERMINATION =================
Success Summary: Bandwidth configuration optimized successfully.
================================================================
```

## How to Deploy
1. Launch [Ollama](https://ollama.com) on your laptop.
2. Verify you have the correct tool-calling weight structure pulled inside your Windows command terminal:
   ```cmd
   ollama pull mistral-nemo
   ```
3. Place `calculateShannon.m`, `calculateRadarRes.m`, `checkConstraints.m`, and `resource_allocation_agent.m` in the same directory.
4. Run `resource_allocation_agent.m` inside MATLAB. The script will handle JSON request pipelines natively and write performance logs straight to your console.
