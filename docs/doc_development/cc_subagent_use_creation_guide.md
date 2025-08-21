Claude Code subagents are specialized AI assistants that can be invoked to handle specific types of tasks within Claude Code. They improve problem-solving efficiency by offering task-specific configurations, including customized system prompts, tools, and their own separate context windows.

Here's a guide to creating Claude Code subagents:

### **What are Subagents?**

Subagents are pre-configured AI personalities that Claude Code can delegate tasks to. Each subagent is designed with:

* A **specific purpose and area of expertise**.  
* Its **own context window**, separate from the main conversation, which helps keep the main conversation focused on high-level objectives.  
* **Configurable tool access**, allowing you to limit powerful tools to specific subagent types.  
* A **custom system prompt** that guides its behavior.

When Claude Code identifies a task that aligns with a subagent's expertise, it can delegate that task, allowing the specialized subagent to work independently and return results.

### **Key Benefits of Using Subagents**

* **Context Preservation**: Subagents operate in their own isolated context, preventing the main conversation from becoming cluttered with task-specific details.  
* **Specialized Expertise**: They can be fine-tuned with detailed instructions for specific domains, leading to higher success rates for designated tasks.  
* **Reusability**: Once created, subagents can be reused across different projects and shared among team members for consistent workflows.  
* **Flexible Permissions**: Subagents can have different tool access levels, allowing for granular control over what each subagent can do.

### **Quick Start: Creating Your First Subagent**

To quickly create a subagent, use the built-in interface:

1. **Open the subagents interface**: Run the command `/agents` in Claude Code.  
2. **Select 'Create New Agent'**: Choose whether you want to create a **project-level** or **user-level** subagent.  
3. **Define the subagent**:  
   * It's **recommended to generate the initial subagent with Claude** and then customize it to your specific needs.  
   * **Describe your subagent in detail** and specify when it should be used.  
   * **Select the tools** you want to grant access to. If omitted, the subagent inherits all tools from the main thread.  
   * You can edit the system prompt in your own editor by pressing `e` if generating with Claude.  
4. **Save and use**: Your new subagent will be available. Claude will either use it automatically when appropriate, or you can invoke it explicitly.

### **Subagent Configuration**

Subagents are defined in **Markdown files with YAML frontmatter**.

**File Locations and Priority**:

* **Project subagents**: Stored in `.claude/agents/` within your project directory. These are specific to your project and can be shared with your team. They **take precedence** over user subagents in case of name conflicts.  
* **User subagents**: Stored in `~/.claude/agents/` in your home directory. These are available across all your projects but are private to you.

**File Format and Fields**: Each subagent file follows this structure:

\---  
name: your-sub-agent-name  
description: Description of when this subagent should be invoked  
tools: tool1, tool2, tool3 \# Optional \- inherits all tools if omitted  
\---  
Your subagent's system prompt goes here. This can be multiple paragraphs  
and should clearly define the subagent's role, capabilities, and approach  
to solving problems.  
Include specific instructions, best practices, and any constraints  
the subagent should follow.

* **`name`** (Required): A unique identifier using lowercase letters and hyphens.  
* **`description`** (Required): A natural language description of the subagent’s purpose, crucial for automatic delegation.  
* **`tools`** (Optional): A comma-separated list of specific tools. If omitted, the subagent inherits all tools available to the main thread, including MCP tools.

**Tool Access**:

* You can omit the `tools` field to have the subagent inherit all tools from the main Claude Code thread.  
* Alternatively, you can specify individual tools for more granular control.  
* The `/agents` command provides an interactive interface listing all available tools, including MCP server tools, to make selection easier.

### **Managing Subagents**

* **Using the `/agents` command (Recommended)**: This interactive menu allows you to view, create, edit, and delete custom subagents. It also helps manage tool permissions.  
* **Direct file management**: You can manually create or modify subagent Markdown files in `.claude/agents/` (for project-specific) or `~/.claude/agents/` (for user-specific).

### **Using Subagents Effectively**

* **Automatic Delegation**: Claude Code can proactively delegate tasks based on your request, the subagent's `description`, and the current context. To encourage this, include phrases like "use PROACTIVELY" or "MUST BE USED" in the subagent's description.  
* **Explicit Invocation**: You can explicitly request a specific subagent by mentioning its name in your command, e.g., "Use the code-reviewer subagent to check my recent changes".

### **Example Subagents**

The sources provide examples of subagents for different roles:

* **Code reviewer**: An expert in code quality, security, and maintainability, often used immediately after code modification.  
* **Debugger**: A specialist in root cause analysis for errors, test failures, and unexpected behavior.  
* **Data scientist**: An expert in SQL and BigQuery analysis for data analysis tasks and queries.

### **Best Practices for Subagents**

* **Start with Claude-generated agents**: Generate an initial subagent with Claude and then refine it. This provides a strong foundation that you can customize.  
* **Design focused subagents**: Create subagents with a single, clear responsibility. This improves performance and predictability.  
* **Write detailed prompts**: Include specific instructions, examples, and constraints in the subagent's system prompt to ensure better performance.  
* **Limit tool access**: Only grant tools essential for the subagent's purpose to improve security and focus.  
* **Version control**: For project subagents, **check them into version control** (`.claude/agents/`) so your team can benefit from and collaborate on them.

### **Advanced Usage**

* **Chaining subagents**: For complex workflows, you can instruct Claude to chain multiple subagents, e.g., "First use the code-analyzer subagent to find performance issues, then use the optimizer subagent to fix them".  
* **Dynamic subagent selection**: Claude Code intelligently selects subagents based on context, so clear and action-oriented descriptions are vital for optimal results.

### **Performance Considerations**

* While subagents help preserve the main conversation context, starting a subagent initiates with a clean slate. This means they **may add latency as they gather necessary context** for their tasks.

