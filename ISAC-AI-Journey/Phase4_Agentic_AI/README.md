# Phase 4, Project 6: Autonomous Resource Allocation Agent (Agentic AI)

This repository contains a **MATLAB** implementation of an autonomous optimization agent. It exposes custom RF communication scripts as schema-defined tools to a local LLM reasoning engine.

## Problem Statement
Optimizing dual-functional variables in Integrated Sensing and Communications (ISAC) typically requires complex multi-objective optimization algorithms. This project demonstrates an alternative paradigm: giving an **AI Agent** access to simple deterministic engineering tools, a definitive boundary goal, and a dynamic execution feedback loop.

## Agent Architecture Elements
- **Tool Definitions:** Converts standard MATLAB functions into tool definitions using `openAIFunction` and `addParameter` hooks.
- **Local Tool Infrastructure:** Operates locally on a `mistral-nemo` model using an **Ollama** framework.
- **Reasoning Loop Loop:** Executes a **Plan $\rightarrow$ Act $\rightarrow$ Observe** progression. The model inspects failures returned by constraints execution and calculates programmatic variables until achieving performance requirements.

## Prerequisites
- MATLAB (R2024a or newer required for local tool calling architecture)
- Deep Learning Toolbox
- Large Language Models (LLMs) with MATLAB Add-On Toolbox
