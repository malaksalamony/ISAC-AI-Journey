# Phase 3, Project 5: Local 3GPP Standardization Bot (NLP / RAG-Lite)

This repository DOES NOT contain **MATLAB** Large Language Models (LLMs) Add-ons.

Ollama runs as a local web server on your laptop, it hosts a standardized HTTP REST API. We can completely bypass the official Add-On by using MATLAB's built-in network features: webwrite to send prompts, jsonencode to format your text, and jsondecode to unpack the AI's response. 


## Problem Statement
3GPP standardization texts span thousands of pages of deeply complex engineering guidelines and parameters. Manually browsing documentation to find operational constraints for Integrated Sensing and Communications (ISAC) is inefficient. This project applies an unsupervised context injection structure (Retrieval-Augmented Generation / RAG-Lite) to extract mandatory system parameter configurations using local AI compute hardware.

## Execution Architecture
- **Local LLM Engine:** Communicates directly with a local `Llama-3.2-1B` neural weights configuration wrapped via an **Ollama** back-end link.
- **Context Realization:** Injects raw text parameters concerning dynamic ISAC configurations directly into the prompt context payload window.
- **Zero Cloud Footprint:** Runs 100% locally on standard laptop CPUs, ensuring corporate privacy protection for trade specification documentation parsing.

## Execution Requirements
1. Install [Ollama](https://ollama.com).
2. Download the local model via shell: `ollama pull llama3.2:1b`.
3. Execute `local_3gpp_bot.m` to observe deterministic text extraction.
