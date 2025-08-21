Claude Code hooks are a powerful feature that allows you to \*\*customize and extend Claude Code's behavior\*\* by registering shell commands that execute at various points in its lifecycle \[1\]. These hooks provide \*\*deterministic control\*\* over Claude Code's actions, ensuring that certain operations always occur as expected, rather than relying solely on the LLM to choose to run them \[1, 2\].

\#\#\# What are Claude Code Hooks?  
Hooks are \*\*user-defined shell commands\*\* that are triggered by specific events within Claude Code's workflow \[1, 3\]. They run automatically during the agent loop using your current environment's credentials \[2\].

\#\#\# Key Use Cases for Hooks  
Hooks can be used for a variety of purposes, including \[4\]:  
\*   \*\*Notifications\*\*: Customizing how you are notified when Claude Code requires input or permission.  
\*   \*\*Automatic Formatting\*\*: Running tools like \`prettier\` on TypeScript files or \`gofmt\` on Go files after every file edit.  
\*   \*\*Logging\*\*: Tracking and counting all executed commands for compliance or debugging.  
\*   \*\*Feedback\*\*: Providing automated feedback when Claude Code generates code that doesn't adhere to your codebase conventions.  
\*   \*\*Custom Permissions\*\*: Blocking modifications to sensitive production files or directories.

By implementing hooks, you transform suggestions into \*\*app-level code that executes consistently\*\* \[2\].

\#\#\# Security Considerations  
It is crucial to \*\*consider the security implications of hooks\*\* because they execute arbitrary shell commands on your system with your current environment's credentials \[2, 5\]. Malicious or poorly written hooks could lead to data loss, system damage, or even data exfiltration \[2, 5\]. Always \*\*review your hook implementations thoroughly\*\* before registering them \[2, 6\]. Key security best practices include \[6\]:  
\*   \*\*Validate and sanitize inputs\*\*: Never trust input data blindly.  
\*   \*\*Always quote shell variables\*\*: Use \`"$VAR"\` instead of \`$VAR\`.  
\*   \*\*Block path traversal\*\*: Check for \`..\` in file paths.  
\*   \*\*Use absolute paths\*\*: Specify full paths for scripts.  
\*   \*\*Skip sensitive files\*\*: Avoid modifying or accessing files like \`.env\`, \`.git/\`, or those containing keys.

Claude Code captures a snapshot of hooks at startup and uses this throughout the session. If hooks are modified externally, Claude Code warns you, and changes require review in the \`/hooks\` menu to apply, preventing malicious modifications from affecting your current session \[7\].

\#\#\# Hook Configuration  
Claude Code hooks are configured in your \*\*settings files\*\*, which support a hierarchical structure \[8, 9\]:  
\*   \*\*User settings\*\*: \`\~/.claude/settings.json\` (apply to all projects).  
\*   \*\*Project settings\*\*: \`.claude/settings.json\` (checked into source control and shared with your team).  
\*   \*\*Local project settings\*\*: \`.claude/settings.local.json\` (not committed, for personal preferences and experimentation).  
\*   \*\*Enterprise managed policy settings\*\*: (highest precedence, deployed by IT/DevOps, cannot be overridden) \[8, 10\].

\#\#\#\# Structure of Hooks in \`settings.json\`  
Hooks are organized by \*\*matchers\*\*, and each matcher can have multiple hooks \[9\]:  
\`\`\`json  
{  
  "hooks": {  
    "EventName": \[  
      {  
        "matcher": "ToolPattern", // Only for PreToolUse and PostToolUse  
        "hooks": \[  
          {  
            "type": "command", // Currently only "command" is supported  
            "command": "your-command-here",  
            "timeout": 60 // Optional: timeout in seconds for this specific command  
          }  
        \]  
      }  
    \]  
  }  
}  
\`\`\`  
\*   \*\*\`matcher\`\*\*: A case-sensitive pattern to match tool names (e.g., \`"Write"\`, \`"Edit|Write"\`, \`"Notebook.\*"\`, or \`"\*"\` for all tools) \[9\]. For events like \`UserPromptSubmit\`, \`Notification\`, \`Stop\`, and \`SubagentStop\` that don't use matchers, the matcher field can be omitted \[11\].  
\*   \*\*\`command\`\*\*: The bash command to execute. The environment variable \`$CLAUDE\_PROJECT\_DIR\` is available to reference scripts stored in your project \[11, 12\].

\#\#\# Hook Events  
Hooks run at different points in Claude Code's workflow, each receiving specific data and influencing behavior in unique ways \[3\]:

\*   \*\*\`PreToolUse\`\*\*: Runs \*\*before\*\* Claude Code processes a tool call, after it creates the tool parameters. It can block the tool call and provide feedback to Claude \[3, 12\].  
\*   \*\*\`PostToolUse\`\*\*: Runs \*\*immediately after\*\* a tool successfully completes execution \[3, 13\].  
\*   \*\*\`Notification\`\*\*: Runs when Claude Code sends notifications, such as when it needs user permission or is awaiting input \[3, 13\].  
\*   \*\*\`UserPromptSubmit\`\*\*: Runs when the user submits a prompt, \*\*before Claude processes it\*\*. This allows for prompt validation, adding context, or blocking certain prompts \[14\].  
\*   \*\*\`Stop\`\*\*: Runs when the main Claude Code agent finishes responding, but not if stopped by a user interrupt \[3, 14\].  
\*   \*\*\`SubagentStop\`\*\*: Runs when a Claude Code subagent (a \`Task\` tool call) finishes responding \[3, 14\].  
\*   \*\*\`PreCompact\`\*\*: Runs before Claude Code performs a context compact operation (either \`manual\` from \`/compact\` or \`auto\` due to a full context window) \[14, 15\].  
\*   \*\*\`SessionStart\`\*\*: Runs when Claude Code starts a new session or resumes an existing one. Useful for loading development context \[15\].

\#\#\# Hook Input  
Hooks receive \*\*JSON data via stdin\*\*, containing session information and event-specific details \[15\].  
Common fields include \`session\_id\`, \`transcript\_path\` (path to conversation JSON), and \`cwd\` (current working directory) \[16\].

Examples of event-specific input fields \[16-20\]:  
\*   \*\*\`PreToolUse\`\*\*: Includes \`tool\_name\` (e.g., "Write") and \`tool\_input\` (e.g., \`file\_path\`, \`content\`).  
\*   \*\*\`PostToolUse\`\*\*: Includes \`tool\_name\`, \`tool\_input\`, and \`tool\_response\`.  
\*   \*\*\`Notification\`\*\*: Includes \`message\` (e.g., "Task completed successfully").  
\*   \*\*\`UserPromptSubmit\`\*\*: Includes \`prompt\` (the user's submitted prompt).  
\*   \*\*\`Stop\` / \`SubagentStop\`\*\*: Includes \`stop\_hook\_active\` (boolean indicating if a stop hook is already active).  
\*   \*\*\`PreCompact\`\*\*: Includes \`trigger\` ("manual" or "auto") and \`custom\_instructions\`.  
\*   \*\*\`SessionStart\`\*\*: Includes \`source\` ("startup", "resume", or "clear").

\#\#\# Hook Output  
Hooks communicate status and influence Claude Code's behavior through \*\*exit codes\*\* or \*\*structured JSON output\*\* via \`stdout\` \[20, 21\].

\#\#\#\# Simple: Exit Code  
\*   \*\*Exit code 0 (Success)\*\*: \`stdout\` is shown to the user in transcript mode (Ctrl+R), except for \`UserPromptSubmit\` and \`SessionStart\` hooks where \`stdout\` is added to the context \[21\].  
\*   \*\*Exit code 2 (Blocking Error)\*\*: \`stderr\` is fed back to Claude for automatic processing, blocking the operation (e.g., blocking a tool call in \`PreToolUse\`) \[21, 22\].  
\*   \*\*Other exit codes (Non-blocking Error)\*\*: \`stderr\` is shown to the user, but execution continues \[21\].

\#\#\#\# Advanced: JSON Output  
Hooks can return JSON objects via \`stdout\` for more granular control \[22\].  
\*\*Common JSON Fields (optional)\*\* \[23\]:  
\*   \`"continue": true/false\`: Whether Claude should continue after hook execution (default: \`true\`). If \`false\`, Claude stops processing.  
\*   \`"stopReason": "string"\`: Message shown to the user if \`continue\` is \`false\`.  
\*   \`"suppressOutput": true/false\`: Hides \`stdout\` from transcript mode (default: \`false\`).

\*\*Decision Control for specific events\*\* \[24-28\]:  
\*   \*\*\`PreToolUse\`\*\*: Use \`"permissionDecision": "allow" | "deny" | "ask"\` to control if a tool call proceeds, is blocked, or requires user confirmation.  
\*   \*\*\`PostToolUse\`\*\*: Use \`"decision": "block"\` to automatically prompt Claude with a reason after a tool has completed.  
\*   \*\*\`UserPromptSubmit\`\*\*: Use \`"decision": "block"\` to prevent a prompt from being processed, or include \`"hookSpecificOutput": {"additionalContext": "..."}\` to add context to the prompt.  
\*   \*\*\`Stop\` / \`SubagentStop\`\*\*: Use \`"decision": "block"\` with a \`reason\` to prevent Claude from stopping.  
\*   \*\*\`SessionStart\`\*\*: Use \`"hookSpecificOutput": {"additionalContext": "..."}\` to load context at the start of a session.

\#\#\# Working with MCP Tools  
Claude Code hooks work seamlessly with Model Context Protocol (MCP) tools \[29\]. MCP tool names follow the pattern \`mcp\_\_\<serverName\>\_\_\<toolName\>\` (e.g., \`mcp\_\_memory\_\_create\_entities\`, \`mcp\_\_github\_\_search\_repositories\`) \[29\]. You can target specific MCP tools or entire MCP servers in your hook matchers using this pattern (e.g., \`"mcp\_\_memory\_\_.\*"\`, \`"mcp\_\_.\*\_\_write.\*"\`) \[30\].

\#\#\# Quickstart Example: Logging Bash Commands  
To quickly set up a hook that logs all Bash commands Claude Code runs \[3\]:  
1\.  \*\*Prerequisites\*\*: Install \`jq\` for JSON processing \[31\].  
2\.  \*\*Open Hooks Configuration\*\*: Run \`/hooks\` in Claude Code and select \`PreToolUse\` \[31\].  
3\.  \*\*Add a Matcher\*\*: Select \`+ Add new matcher…\` and type \`Bash\` to match only Bash tool calls \[31\].  
4\.  \*\*Add the Hook\*\*: Select \`+ Add new hook…\` and enter the command:  
    \`jq \-r '"\\(.tool\_input.command) \- \\(.tool\_input.description // "No description")"' \>\> \~/.claude/bash-command-log.txt\` \[32\].  
5\.  \*\*Save Configuration\*\*: Choose \`User settings\` for storage to apply this hook to all projects \[32\].  
6\.  \*\*Verify\*\*: Run \`/hooks\` or check \`\~/.claude/settings.json\` to confirm the configuration \[32\].  
7\.  \*\*Test\*\*: Ask Claude to run a simple command like \`ls\` and then check \`cat \~/.claude/bash-command-log.txt\` to see the logged command \[33\].

\#\#\# Hook Execution Details  
\*   \*\*Timeout\*\*: Hooks have a default 60-second execution limit, configurable per command. A timeout for one command does not affect others \[7\].  
\*   \*\*Parallelization\*\*: All matching hooks run in parallel \[34\].  
\*   \*\*Environment\*\*: Hooks run in the current directory with Claude Code’s environment. The \`CLAUDE\_PROJECT\_DIR\` environment variable provides the absolute path to the project root \[34\].  
\*   \*\*Input\*\*: JSON data via stdin \[34\].  
\*   \*\*Output\*\*: Progress is shown in transcript mode (Ctrl+R) for \`PreToolUse\`, \`PostToolUse\`, and \`Stop\` events \[34\].

\#\#\# Debugging Hooks  
If your hooks are not working as expected, follow these troubleshooting steps \[34, 35\]:  
1\.  \*\*Check configuration\*\*: Run \`/hooks\` to verify your hook is registered.  
2\.  \*\*Verify syntax\*\*: Ensure your JSON settings are valid.  
3\.  \*\*Test commands manually\*\*: Run your hook commands outside of Claude Code first.  
4\.  \*\*Check permissions\*\*: Ensure scripts are executable.  
5\.  \*\*Review logs\*\*: Use \`claude \--debug\` to see detailed hook execution information \[34, 36\].

Common issues include unescaped quotes in JSON strings, incorrect case-sensitive matchers, and commands not found (use full paths for scripts) \[35\].