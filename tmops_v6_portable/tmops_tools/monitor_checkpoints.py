#!/usr/bin/env python3
# 📁 FILE: /home/anthonycalek/projects/tmops_framework/CODE/tmops_v6_portable/tmops_tools/monitor_checkpoints.py
# 🎯 PURPOSE: Checkpoint monitoring utility with exponential backoff and logging for TeamOps workflow coordination
# 🤖 AI-HINT: Use to monitor TeamOps checkpoint files during workflow execution with configurable polling and logging
# 🔗 DEPENDENCIES: checkpoint files, pathlib, JSON, argparse, datetime
# 📝 CONTEXT: Part of TeamOps coordination system for monitoring workflow progress and managing instance communication
# tmops_tools/monitor_checkpoints.py
# Checkpoint monitoring with exponential backoff and logging

import os
import sys
import time
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, Any

class CheckpointMonitor:
    """Monitor and manage TeamOps checkpoints with logging and exponential backoff"""
    
    def __init__(self, feature: str, instance_role: str):
        """
        Initialize the checkpoint monitor
        
        Args:
            feature: The feature name being worked on
            instance_role: The role of this instance (orchestrator, tester, impl, verify)
        """
        self.feature = feature
        self.role = instance_role
        self.checkpoint_dir = Path(f"../.tmops/{feature}/runs/current/checkpoints")
        self.log_file = Path(f"../.tmops/{feature}/runs/current/logs/{instance_role}.log")
        
        # Ensure directories exist
        self.checkpoint_dir.mkdir(parents=True, exist_ok=True)
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        
        self.log(f"CheckpointMonitor initialized for {feature}/{instance_role}")
    
    def wait_for_checkpoint(self, checkpoint_pattern: str, timeout: int = 300) -> str:
        """
        Poll for a checkpoint file with exponential backoff
        
        Args:
            checkpoint_pattern: Glob pattern to match checkpoint files (e.g., "001-*.md")
            timeout: Maximum time to wait in seconds (default 5 minutes)
        
        Returns:
            The content of the found checkpoint
        
        Raises:
            TimeoutError: If no matching checkpoint is found within timeout
        """
        start_time = time.time()
        wait_time = 2  # Initial wait time in seconds
        max_wait = 10  # Maximum wait time between checks
        
        self.log(f"Waiting for checkpoint matching: {checkpoint_pattern}")
        
        while time.time() - start_time < timeout:
            # Check for matching checkpoints
            matching_files = list(self.checkpoint_dir.glob(checkpoint_pattern))
            
            if matching_files:
                checkpoint_file = matching_files[0]  # Take the first match
                self.log(f"Found checkpoint: {checkpoint_file.name}")
                
                content = checkpoint_file.read_text()
                return content
            
            # Log periodic status
            elapsed = int(time.time() - start_time)
            if elapsed % 30 == 0 and elapsed > 0:  # Log every 30 seconds
                self.log(f"Still waiting for {checkpoint_pattern} ({elapsed}s elapsed)")
            
            # Wait with exponential backoff
            time.sleep(wait_time)
            wait_time = min(wait_time * 1.5, max_wait)
        
        # Timeout reached
        error_msg = f"Timeout: No checkpoint matching {checkpoint_pattern} after {timeout}s"
        self.log(error_msg, level="ERROR")
        raise TimeoutError(error_msg)
    
    def create_checkpoint(self, name: str, content: str, metadata: Optional[Dict[str, Any]] = None):
        """
        Create a checkpoint file with proper formatting
        
        Args:
            name: The checkpoint filename (e.g., "003-tests-complete.md")
            content: The main content of the checkpoint
            metadata: Optional metadata to include in the checkpoint
        """
        checkpoint_path = self.checkpoint_dir / name
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Build the checkpoint content
        formatted_content = f"""# Checkpoint: {name}

**From:** {self.role}
**To:** {"orchestrator" if self.role != "orchestrator" else "working instances"}
**Timestamp:** {timestamp}
**Feature:** {self.feature}

## Content

{content}
"""
        
        # Add metadata if provided
        if metadata:
            formatted_content += "\n## Metadata\n\n```json\n"
            formatted_content += json.dumps(metadata, indent=2)
            formatted_content += "\n```\n"
        
        # Write the checkpoint
        checkpoint_path.write_text(formatted_content)
        self.log(f"Created checkpoint: {name}")
    
    def list_checkpoints(self) -> list:
        """
        List all checkpoints in the current run
        
        Returns:
            List of checkpoint filenames
        """
        checkpoints = sorted([f.name for f in self.checkpoint_dir.glob("*.md")])
        self.log(f"Found {len(checkpoints)} checkpoints")
        return checkpoints
    
    def get_checkpoint_content(self, name: str) -> Optional[str]:
        """
        Read the content of a specific checkpoint
        
        Args:
            name: The checkpoint filename
        
        Returns:
            The checkpoint content, or None if not found
        """
        checkpoint_path = self.checkpoint_dir / name
        
        if checkpoint_path.exists():
            return checkpoint_path.read_text()
        
        self.log(f"Checkpoint not found: {name}", level="WARNING")
        return None
    
    def log(self, message: str, level: str = "INFO"):
        """
        Write a message to the instance log file
        
        Args:
            message: The message to log
            level: Log level (INFO, WARNING, ERROR)
        """
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        
        # Ensure log directory exists
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Append to log file
        with open(self.log_file, 'a') as f:
            f.write(log_entry)
        
        # Also print to console if it's an error
        if level == "ERROR":
            print(f"ERROR: {message}", file=sys.stderr)
    
    def get_run_info(self) -> Dict[str, Any]:
        """
        Get information about the current run
        
        Returns:
            Dictionary with run information
        """
        run_dir = self.checkpoint_dir.parent
        
        info = {
            "feature": self.feature,
            "run_dir": str(run_dir),
            "checkpoints": self.list_checkpoints(),
            "log_file": str(self.log_file)
        }
        
        # Check for previous run context
        prev_run_file = run_dir / "PREVIOUS_RUN.txt"
        if prev_run_file.exists():
            info["previous_run"] = prev_run_file.read_text().strip()
        
        return info


def main():
    """Command-line interface for checkpoint monitoring"""
    parser = argparse.ArgumentParser(description="Monitor TeamOps checkpoints")
    parser.add_argument("feature", help="Feature name")
    parser.add_argument("role", help="Instance role (orchestrator, tester, impl, verify)")
    
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Wait command
    wait_parser = subparsers.add_parser("wait", help="Wait for a checkpoint")
    wait_parser.add_argument("pattern", help="Checkpoint pattern to wait for")
    wait_parser.add_argument("--timeout", type=int, default=300, help="Timeout in seconds")
    
    # Create command
    create_parser = subparsers.add_parser("create", help="Create a checkpoint")
    create_parser.add_argument("name", help="Checkpoint name")
    create_parser.add_argument("content", help="Checkpoint content")
    
    # List command
    subparsers.add_parser("list", help="List all checkpoints")
    
    # Info command
    subparsers.add_parser("info", help="Get run information")
    
    args = parser.parse_args()
    
    # Create monitor instance
    monitor = CheckpointMonitor(args.feature, args.role)
    
    # Execute command
    if args.command == "wait":
        try:
            content = monitor.wait_for_checkpoint(args.pattern, args.timeout)
            print(f"Found checkpoint matching {args.pattern}")
            print("-" * 40)
            print(content)
        except TimeoutError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
    
    elif args.command == "create":
        monitor.create_checkpoint(args.name, args.content)
        print(f"Created checkpoint: {args.name}")
    
    elif args.command == "list":
        checkpoints = monitor.list_checkpoints()
        if checkpoints:
            print("Checkpoints:")
            for cp in checkpoints:
                print(f"  - {cp}")
        else:
            print("No checkpoints found")
    
    elif args.command == "info":
        info = monitor.get_run_info()
        print(json.dumps(info, indent=2))
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()