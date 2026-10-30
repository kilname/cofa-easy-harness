import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALL = ROOT/'install.py'

class InstallTests(unittest.TestCase):
    def project(self, path):
        path.mkdir(parents=True,exist_ok=True)
        (path/'README.md').write_text('# User-provided task\n',encoding='utf-8')
        (path/'app.js').write_text('const important = 42;\n',encoding='utf-8')
        return path

    def run_install(self,*args):
        return subprocess.run([sys.executable,str(INSTALL),*(str(a) for a in args)],text=True,capture_output=True)

    def test_fresh_install_preserves_sources(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=self.project(Path(tmp)/'task')
            r=self.run_install(p)
            self.assertEqual(r.returncode,0,r.stderr)
            self.assertEqual((p/'README.md').read_text(encoding='utf-8'),'# User-provided task\n')
            self.assertEqual((p/'app.js').read_text(encoding='utf-8'),'const important = 42;\n')
            self.assertTrue((p/'AGENTS.md').is_file())
            self.assertTrue((p/'COFA_WORKFLOW.md').is_file())
            self.assertTrue((p/'.agents/skills/critical-verification/SKILL.md').is_file())

    def test_reinstall_is_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=self.project(Path(tmp)/'task')
            self.assertEqual(self.run_install(p).returncode,0)
            original=(p/'AGENTS.md').read_bytes()
            self.assertEqual(self.run_install(p).returncode,0)
            self.assertEqual((p/'AGENTS.md').read_bytes(),original)
            self.assertEqual(len(list(p.glob('AGENTS.md.backup-*'))),0)

    def test_existing_agents_merged_once_and_backed_up(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=self.project(Path(tmp)/'task')
            (p/'AGENTS.md').write_text('# user policies\nNO CHANGES TO X\n',encoding='utf-8')
            self.assertEqual(self.run_install(p).returncode,0)
            a=(p/'AGENTS.md').read_text(encoding='utf-8')
            self.assertIn('NO CHANGES TO X',a)
            self.assertEqual(a.count('COFA_EASY_HARNESS_V2_START'),1)
            backups=list(p.glob('AGENTS.md.backup-*'))
            self.assertEqual(len(backups),1)
            self.assertEqual(backups[0].read_text(encoding='utf-8'),'# user policies\nNO CHANGES TO X\n')
            self.assertEqual(self.run_install(p).returncode,0)
            self.assertEqual((p/'AGENTS.md').read_text(encoding='utf-8').count('COFA_EASY_HARNESS_V2_START'),1)
            self.assertEqual(len(list(p.glob('AGENTS.md.backup-*'))),1)

    def test_existing_skill_not_overwritten(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=self.project(Path(tmp)/'task')
            f=p/'.agents/skills/critical-verification/SKILL.md'
            f.parent.mkdir(parents=True)
            f.write_text('user-original',encoding='utf-8')
            self.assertEqual(self.run_install(p).returncode,0)
            self.assertEqual(f.read_text(encoding='utf-8'),'user-original')

    def test_dry_run_does_not_mutate(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=self.project(Path(tmp)/'task')
            self.assertEqual(self.run_install(p,'--dry-run').returncode,0)
            self.assertEqual(sorted(x.name for x in p.iterdir()),['README.md','app.js'])

    def test_missing_readme_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            r=self.run_install(Path(tmp))
            self.assertEqual(r.returncode,2)

    def test_symlink_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=self.project(Path(tmp)/'task')
            outside=Path(tmp)/'outside.md';outside.write_text('protected',encoding='utf-8')
            try:
                (p/'AGENTS.md').symlink_to(outside)
            except (OSError,NotImplementedError):
                self.skipTest('symlink not supported')
            self.assertEqual(self.run_install(p).returncode,3)
            self.assertEqual(outside.read_text(encoding='utf-8'),'protected')

if __name__=='__main__':unittest.main()

# additional scenarios live in the main suite below, which discovery loads directly
