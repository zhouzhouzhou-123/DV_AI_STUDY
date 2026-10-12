#!/usr/bin/env python3
"""
Unit tests for M script optimizations.
Tests cover: PerformanceMonitor, ConfigValidator, exception handling,
type annotations, and logging integration.
"""

import os
import sys
import unittest
import tempfile
import shutil
import logging
from unittest.mock import patch, MagicMock
from io import StringIO

# Add script directory to path
cur_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, cur_dir)

# Import modules under test using importlib for 'm' (no .py extension)
import importlib.util

# Load 'csrun.py' module dynamically (m is a symlink to csrun.py)
csrun_path = os.path.join(cur_dir, "csrun.py")
m_spec = importlib.util.spec_from_file_location("csrun", csrun_path)
m_module = importlib.util.module_from_spec(m_spec)
m_spec.loader.exec_module(m_module)

PerformanceMonitor = m_module.PerformanceMonitor
ConfigValidator = m_module.ConfigValidator
CSRun = m_module.CSRun
logger = m_module.logger

# Import cmdargs and envcfg normally (they have .py extension)
from cmdargs import logger as cmdargs_logger
from envcfg import logger as envcfg_logger


class TestPerformanceMonitor(unittest.TestCase):
    """Test PerformanceMonitor class."""

    def setUp(self):
        self.monitor = PerformanceMonitor()

    def test_start(self):
        """Test monitor start records time."""
        self.monitor.start()
        self.assertGreater(self.monitor.start_time, 0)

    def test_stage_timing(self):
        """Test stage start/end timing."""
        self.monitor.start()
        self.monitor.start_stage('test_stage')
        import time
        time.sleep(0.01)
        elapsed = self.monitor.end_stage('test_stage')
        self.assertGreater(elapsed, 0)
        self.assertIn('test_stage', self.monitor.stage_times)

    def test_end_stage_without_start(self):
        """Test ending a stage that was never started returns 0."""
        elapsed = self.monitor.end_stage('nonexistent')
        self.assertEqual(elapsed, 0.0)

    def test_get_total_time(self):
        """Test total time calculation."""
        self.monitor.start()
        import time
        time.sleep(0.01)
        total = self.monitor.get_total_time()
        self.assertGreater(total, 0)

    def test_report_output(self):
        """Test report prints correctly."""
        self.monitor.start()
        self.monitor.start_stage('simulation')
        self.monitor.end_stage('simulation')
        
        captured = StringIO()
        sys.stdout = captured
        self.monitor.report()
        sys.stdout = sys.__stdout__
        
        output = captured.getvalue()
        self.assertIn("Time Summary", output)
        self.assertIn("Total Time", output)

    def test_multiple_stages(self):
        """Test multiple stages tracked independently."""
        self.monitor.start()
        self.monitor.start_stage('stage_a')
        self.monitor.end_stage('stage_a')
        self.monitor.start_stage('stage_b')
        self.monitor.end_stage('stage_b')
        
        self.assertEqual(len(self.monitor.stage_times), 2)
        self.assertIn('stage_a', self.monitor.stage_times)
        self.assertIn('stage_b', self.monitor.stage_times)


class TestConfigValidator(unittest.TestCase):
    """Test ConfigValidator class."""

    def test_validate_file_exists(self):
        """Test file existence validation."""
        # Existing file
        self.assertTrue(ConfigValidator.validate_file(__file__))
        
        # Non-existing file
        self.assertFalse(ConfigValidator.validate_file("/nonexistent/path"))

    def test_validate_env_missing_work_dir(self):
        """Test env validation with missing WORK_DIR."""
        mock_env = MagicMock()
        mock_env.work_dir = "/nonexistent/path"
        
        with patch('os.path.exists', return_value=False):
            errors = ConfigValidator.validate_env(mock_env)
            self.assertGreater(len(errors), 0)

    def test_validate_env_valid(self):
        """Test env validation with valid config."""
        mock_env = MagicMock()
        mock_env.work_dir = cur_dir
        
        errors = ConfigValidator.validate_env(mock_env)
        self.assertEqual(len(errors), 0)

    def test_validate_args_missing_test_name(self):
        """Test args validation with missing test name."""
        mock_args = MagicMock()
        mock_args.is_run = True
        mock_args.test_name = ""
        
        errors = ConfigValidator.validate_args(mock_args)
        self.assertGreater(len(errors), 0)

    def test_validate_args_valid(self):
        """Test args validation with valid config."""
        mock_args = MagicMock()
        mock_args.is_run = True
        mock_args.test_name = "basetest"
        
        errors = ConfigValidator.validate_args(mock_args)
        self.assertEqual(len(errors), 0)


class TestCSRunOptimizations(unittest.TestCase):
    """Test CSRun optimizations."""

    def test_csrun_has_perf_monitor(self):
        """Test CSRun initializes PerformanceMonitor."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                self.assertIsInstance(runner.perf_monitor, PerformanceMonitor)

    def test_execute_command_returns_code(self):
        """Test execute_command_on_shell returns exit code."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                runner.cmd_args = MagicMock()
                
                # Test successful command
                result = runner.execute_command_on_shell("echo test")
                self.assertEqual(result, 0)

    def test_execute_command_handles_failure(self):
        """Test execute_command_on_shell handles command failure."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                runner.cmd_args = MagicMock()
                
                # Test failing command
                result = runner.execute_command_on_shell("false")
                self.assertNotEqual(result, 0)


class TestLoggingIntegration(unittest.TestCase):
    """Test logging is properly configured."""

    def test_logger_exists(self):
        """Test logger is created."""
        self.assertIsNotNone(logger)
        self.assertEqual(logger.name, 'm_script')

    def test_cmdargs_logger_exists(self):
        """Test cmdargs logger is created."""
        self.assertIsNotNone(cmdargs_logger)

    def test_envcfg_logger_exists(self):
        """Test envcfg logger is created."""
        self.assertIsNotNone(envcfg_logger)


class TestTypeAnnotations(unittest.TestCase):
    """Test type annotations are present."""

    def test_perf_monitor_annotations(self):
        """Test PerformanceMonitor methods have type annotations."""
        import inspect
        sig = inspect.signature(PerformanceMonitor.start)
        self.assertEqual(sig.return_annotation, type(None))
        
        sig = inspect.signature(PerformanceMonitor.start_stage)
        self.assertIn('stage_name', sig.parameters)
        
        sig = inspect.signature(PerformanceMonitor.get_total_time)
        self.assertEqual(sig.return_annotation, float)

    def test_config_validator_annotations(self):
        """Test ConfigValidator methods have type annotations."""
        import inspect
        sig = inspect.signature(ConfigValidator.validate_file)
        self.assertIn('file_path', sig.parameters)
        self.assertEqual(sig.return_annotation, bool)


class TestExceptionHandling(unittest.TestCase):
    """Test exception handling in file operations."""

    def test_check_sw_compile_error_missing_file(self):
        """Test check_sw_compile_error handles missing file."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                runner.cmd_args = MagicMock()
                
                # Should not raise, just log error
                runner.check_sw_compile_error("/nonexistent/file.log")

    def test_validate_file_nonexistent(self):
        """Test validate_file with nonexistent path."""
        result = ConfigValidator.validate_file("/nonexistent/path/file.txt")
        self.assertFalse(result)


class TestRefactoredFunctions(unittest.TestCase):
    """Test refactored sub-functions."""

    def test_build_sim_command_base(self):
        """Test _build_sim_command_base creates valid command."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                mock_env.xa_bsub_args = ""
                mock_env.bsub_default_args = ""
                mock_env.vcs_default_sim_args = "+UVM_TESTNAME=basetest"
                mock_env.timing_violation_limit = 0
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                runner.cmd_args = MagicMock()
                runner.cmd_args.is_xa = False
                runner.cmd_args.is_bsub = False
                runner.cmd_args.simv_file_path = "./simv"
                runner.cmd_args.rand_seed = 1
                runner.cmd_args.test_name = "basetest"
                runner.cmd_args.add_usr_plusargs = ""
                runner.cmd_args.sim_log_file_path = "./sim.log"
                
                cmd = runner._build_sim_command_base()
                self.assertIn("./simv", cmd)
                self.assertIn("+ntb_random_seed=1", cmd)
                self.assertIn("+UVM_TESTNAME=basetest", cmd)
                self.assertIn("+SIM_LOG_FILE=", cmd)

    def test_add_sim_coverage_args(self):
        """Test _add_sim_coverage_args adds coverage when enabled."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                mock_env.cov_default_args = "-cm line+cond"
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                runner.cmd_args = MagicMock()
                runner.cmd_args.is_cov = True
                runner.cmd_args.sim_test_name = "test_1"
                
                cmd = runner._add_sim_coverage_args("base_cmd ")
                self.assertIn("-cm line+cond", cmd)
                self.assertIn("-cm_name", cmd)

    def test_add_sim_coverage_args_disabled(self):
        """Test _add_sim_coverage_args does nothing when disabled."""
        with patch.dict(os.environ, {"WORK_DIR": cur_dir}):
            with patch.object(m_module, 'EnvCfg') as MockEnvCfg:
                mock_env = MagicMock()
                MockEnvCfg.return_value = mock_env
                
                runner = CSRun()
                runner.cmd_args = MagicMock()
                runner.cmd_args.is_cov = False
                
                cmd = runner._add_sim_coverage_args("base_cmd ")
                self.assertEqual(cmd, "base_cmd ")


if __name__ == '__main__':
    unittest.main(verbosity=2)
