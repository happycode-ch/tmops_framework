#!/usr/bin/env python3
# tmops_tools/extract_metrics.py
# Extract metrics from checkpoints and generate reports

import os
import sys
import json
import re
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List, Optional

class MetricsExtractor:
    """Extract and analyze metrics from TeamOps checkpoint files"""
    
    def __init__(self, feature: str, run_dir: Optional[str] = None):
        """
        Initialize the metrics extractor
        
        Args:
            feature: The feature name
            run_dir: Specific run directory (default: current)
        """
        self.feature = feature
        
        if run_dir:
            self.checkpoint_dir = Path(f"../.tmops/{feature}/runs/{run_dir}/checkpoints")
        else:
            self.checkpoint_dir = Path(f"../.tmops/{feature}/runs/current/checkpoints")
        
        self.metrics_file = self.checkpoint_dir.parent / "metrics.json"
        
        if not self.checkpoint_dir.exists():
            raise ValueError(f"Checkpoint directory not found: {self.checkpoint_dir}")
    
    def extract_all_metrics(self) -> Dict[str, Any]:
        """
        Extract metrics from all checkpoints in the run
        
        Returns:
            Dictionary containing all extracted metrics
        """
        metrics = {
            "feature": self.feature,
            "timestamp": datetime.now().isoformat(),
            "run_directory": str(self.checkpoint_dir.parent.name),
            "phases": {
                "discovery": {},
                "testing": {},
                "implementation": {},
                "verification": {}
            },
            "timeline": [],
            "summary": {}
        }
        
        # Process each checkpoint file
        checkpoints = sorted(self.checkpoint_dir.glob("*.md"))
        
        for checkpoint_file in checkpoints:
            self._process_checkpoint(checkpoint_file, metrics)
        
        # Calculate summary metrics
        self._calculate_summary(metrics)
        
        return metrics
    
    def _process_checkpoint(self, checkpoint_file: Path, metrics: Dict[str, Any]):
        """
        Process a single checkpoint file and extract metrics
        
        Args:
            checkpoint_file: Path to the checkpoint file
            metrics: Dictionary to update with extracted metrics
        """
        content = checkpoint_file.read_text()
        filename = checkpoint_file.name
        
        # Extract timestamp
        timestamp_match = re.search(r'\*\*Timestamp:\*\* (.+)', content)
        timestamp = timestamp_match.group(1) if timestamp_match else "Unknown"
        
        # Add to timeline
        metrics["timeline"].append({
            "checkpoint": filename,
            "timestamp": timestamp
        })
        
        # Extract phase-specific metrics
        if "discovery" in filename:
            self._extract_discovery_metrics(content, metrics["phases"]["discovery"])
        
        elif "tests-complete" in filename:
            self._extract_test_metrics(content, metrics["phases"]["testing"])
        
        elif "impl-complete" in filename:
            self._extract_implementation_metrics(content, metrics["phases"]["implementation"])
        
        elif "verify-complete" in filename:
            self._extract_verification_metrics(content, metrics["phases"]["verification"])
    
    def _extract_discovery_metrics(self, content: str, phase_metrics: Dict[str, Any]):
        """Extract metrics from discovery phase checkpoints"""
        # Extract file counts
        files_match = re.search(r'Files discovered: (\d+)', content, re.IGNORECASE)
        if files_match:
            phase_metrics["files_discovered"] = int(files_match.group(1))
        
        # Extract directory structure depth
        dirs_match = re.search(r'Directories: (\d+)', content, re.IGNORECASE)
        if dirs_match:
            phase_metrics["directories_found"] = int(dirs_match.group(1))
    
    def _extract_test_metrics(self, content: str, phase_metrics: Dict[str, Any]):
        """Extract metrics from test phase checkpoints"""
        # Extract test count
        tests_match = re.search(r'Tests (?:written|created): (\d+)', content, re.IGNORECASE)
        if tests_match:
            phase_metrics["tests_written"] = int(tests_match.group(1))
        
        # Extract test files
        test_files = re.findall(r'(?:test|spec)[/_][\w/]+\.(?:py|js|ts|go|rs)', content)
        if test_files:
            phase_metrics["test_files"] = test_files
            phase_metrics["test_file_count"] = len(test_files)
        
        # Extract coverage if mentioned
        coverage_match = re.search(r'Coverage: (\d+(?:\.\d+)?)%', content, re.IGNORECASE)
        if coverage_match:
            phase_metrics["coverage_percent"] = float(coverage_match.group(1))
        
        # Check if all tests are failing (as they should initially)
        if re.search(r'all tests (?:fail|failing)', content, re.IGNORECASE):
            phase_metrics["initial_state"] = "all_failing"
    
    def _extract_implementation_metrics(self, content: str, phase_metrics: Dict[str, Any]):
        """Extract metrics from implementation phase checkpoints"""
        # Extract test results
        passing_match = re.search(r'(?:Tests |Passing:? )(\d+)/(\d+)', content, re.IGNORECASE)
        if passing_match:
            phase_metrics["tests_passing"] = int(passing_match.group(1))
            phase_metrics["tests_total"] = int(passing_match.group(2))
            phase_metrics["pass_rate"] = (phase_metrics["tests_passing"] / phase_metrics["tests_total"] * 100)
        
        # Extract files modified/created
        files_created = re.findall(r'Created: ([\w/]+\.[\w]+)', content)
        files_modified = re.findall(r'Modified: ([\w/]+\.[\w]+)', content)
        
        if files_created:
            phase_metrics["files_created"] = files_created
        if files_modified:
            phase_metrics["files_modified"] = files_modified
        
        phase_metrics["total_files_changed"] = len(files_created) + len(files_modified)
        
        # Extract lines of code if mentioned
        loc_match = re.search(r'Lines (?:of code|added): (\d+)', content, re.IGNORECASE)
        if loc_match:
            phase_metrics["lines_of_code"] = int(loc_match.group(1))
        
        # Check for performance metrics
        perf_match = re.search(r'Performance: ([\d.]+)(?:ms|s)', content, re.IGNORECASE)
        if perf_match:
            phase_metrics["performance"] = perf_match.group(1)
    
    def _extract_verification_metrics(self, content: str, phase_metrics: Dict[str, Any]):
        """Extract metrics from verification phase checkpoints"""
        # Extract issue counts
        issues_match = re.search(r'Issues found: (\d+)', content, re.IGNORECASE)
        if issues_match:
            phase_metrics["issues_found"] = int(issues_match.group(1))
        
        # Extract edge cases
        edge_cases_match = re.search(r'Edge cases: (\d+)', content, re.IGNORECASE)
        if edge_cases_match:
            phase_metrics["edge_cases_identified"] = int(edge_cases_match.group(1))
        
        # Extract quality assessment
        if re.search(r'Quality:? (?:Good|High|Excellent)', content, re.IGNORECASE):
            phase_metrics["quality_assessment"] = "high"
        elif re.search(r'Quality:? (?:Poor|Low|Needs improvement)', content, re.IGNORECASE):
            phase_metrics["quality_assessment"] = "low"
        else:
            phase_metrics["quality_assessment"] = "medium"
        
        # Check for security concerns
        if re.search(r'Security (?:issues|concerns)', content, re.IGNORECASE):
            phase_metrics["security_concerns"] = True
        else:
            phase_metrics["security_concerns"] = False
        
        # Extract recommendations count
        recommendations = re.findall(r'(?:Recommend|Suggestion):', content, re.IGNORECASE)
        phase_metrics["recommendations_count"] = len(recommendations)
    
    def _calculate_summary(self, metrics: Dict[str, Any]):
        """
        Calculate summary statistics from phase metrics
        
        Args:
            metrics: The metrics dictionary to update
        """
        summary = metrics["summary"]
        
        # Testing phase summary
        if metrics["phases"]["testing"]:
            test_phase = metrics["phases"]["testing"]
            summary["total_tests"] = test_phase.get("tests_written", 0)
            summary["test_coverage"] = test_phase.get("coverage_percent", 0)
        
        # Implementation phase summary
        if metrics["phases"]["implementation"]:
            impl_phase = metrics["phases"]["implementation"]
            summary["test_pass_rate"] = impl_phase.get("pass_rate", 0)
            summary["files_changed"] = impl_phase.get("total_files_changed", 0)
        
        # Verification phase summary
        if metrics["phases"]["verification"]:
            verify_phase = metrics["phases"]["verification"]
            summary["issues_found"] = verify_phase.get("issues_found", 0)
            summary["quality"] = verify_phase.get("quality_assessment", "unknown")
        
        # Timeline summary
        if metrics["timeline"]:
            summary["checkpoints_completed"] = len(metrics["timeline"])
            summary["first_checkpoint"] = metrics["timeline"][0]["timestamp"]
            summary["last_checkpoint"] = metrics["timeline"][-1]["timestamp"]
        
        # Overall success indicator
        impl_success = metrics["phases"]["implementation"].get("tests_passing", 0) == \
                      metrics["phases"]["implementation"].get("tests_total", 1)
        no_critical_issues = metrics["phases"]["verification"].get("issues_found", 0) == 0
        
        summary["success"] = impl_success and no_critical_issues
    
    def save_metrics(self, metrics: Optional[Dict[str, Any]] = None) -> Path:
        """
        Save metrics to JSON file
        
        Args:
            metrics: Metrics to save (if None, extracts fresh metrics)
        
        Returns:
            Path to the saved metrics file
        """
        if metrics is None:
            metrics = self.extract_all_metrics()
        
        # Save to JSON file
        self.metrics_file.write_text(json.dumps(metrics, indent=2))
        
        return self.metrics_file
    
    def generate_report(self, metrics: Optional[Dict[str, Any]] = None) -> str:
        """
        Generate a human-readable report from metrics
        
        Args:
            metrics: Metrics to report on (if None, extracts fresh metrics)
        
        Returns:
            Formatted report string
        """
        if metrics is None:
            metrics = self.extract_all_metrics()
        
        report = []
        report.append(f"# TeamOps Metrics Report")
        report.append(f"\n**Feature:** {metrics['feature']}")
        report.append(f"**Generated:** {metrics['timestamp']}")
        report.append(f"**Run:** {metrics['run_directory']}")
        
        # Summary section
        summary = metrics.get("summary", {})
        if summary:
            report.append("\n## Summary")
            report.append(f"- **Total Tests:** {summary.get('total_tests', 'N/A')}")
            report.append(f"- **Test Pass Rate:** {summary.get('test_pass_rate', 0):.1f}%")
            report.append(f"- **Files Changed:** {summary.get('files_changed', 'N/A')}")
            report.append(f"- **Issues Found:** {summary.get('issues_found', 'N/A')}")
            report.append(f"- **Quality Assessment:** {summary.get('quality', 'N/A')}")
            report.append(f"- **Overall Success:** {'✅ Yes' if summary.get('success') else '❌ No'}")
        
        # Phase details
        report.append("\n## Phase Metrics")
        
        for phase_name, phase_data in metrics["phases"].items():
            if phase_data:
                report.append(f"\n### {phase_name.title()} Phase")
                for key, value in phase_data.items():
                    if not key.startswith("_"):
                        formatted_key = key.replace("_", " ").title()
                        if isinstance(value, list):
                            report.append(f"- **{formatted_key}:** {len(value)} items")
                        elif isinstance(value, bool):
                            report.append(f"- **{formatted_key}:** {'Yes' if value else 'No'}")
                        elif isinstance(value, float):
                            report.append(f"- **{formatted_key}:** {value:.2f}")
                        else:
                            report.append(f"- **{formatted_key}:** {value}")
        
        # Timeline
        if metrics.get("timeline"):
            report.append("\n## Timeline")
            for entry in metrics["timeline"]:
                report.append(f"- **{entry['checkpoint']}** - {entry['timestamp']}")
        
        return "\n".join(report)


def main():
    """Command-line interface for metrics extraction"""
    parser = argparse.ArgumentParser(description="Extract metrics from TeamOps checkpoints in parent .tmops directory")
    parser.add_argument("feature", help="Feature name")
    parser.add_argument("--run", help="Specific run directory (default: current)")
    parser.add_argument("--format", choices=["json", "report", "both"], default="both",
                       help="Output format")
    parser.add_argument("--output", help="Output file (default: print to console)")
    
    args = parser.parse_args()
    
    try:
        # Create extractor
        extractor = MetricsExtractor(args.feature, args.run)
        
        # Extract metrics
        metrics = extractor.extract_all_metrics()
        
        # Generate output based on format
        if args.format in ["json", "both"]:
            if args.output and args.format == "json":
                output_file = Path(args.output)
                output_file.write_text(json.dumps(metrics, indent=2))
                print(f"Metrics saved to: {output_file}")
            else:
                # Save to default location
                metrics_file = extractor.save_metrics(metrics)
                print(f"Metrics saved to: {metrics_file}")
                
                if args.format == "json" and not args.output:
                    print("\nMetrics JSON:")
                    print(json.dumps(metrics, indent=2))
        
        if args.format in ["report", "both"]:
            report = extractor.generate_report(metrics)
            
            if args.output and args.format == "report":
                output_file = Path(args.output)
                output_file.write_text(report)
                print(f"Report saved to: {output_file}")
            else:
                print("\n" + report)
    
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()