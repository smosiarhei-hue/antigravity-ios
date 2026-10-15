# Path: .github/scripts/deploy_ota_pages.py
"""Generate OTA manifest.plist and push to gh-pages branch."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def generate_manifest(bundle_id: str, version: str, ipa_url: str, title: str = "Antigravity") -> str:
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>{ipa_url}</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>{bundle_id}</string>
                <key>bundle-version</key>
                <string>{version}</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>{title}</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
"""


def deploy(env=None):
    if env is None:
        env = os.environ

    token = env.get("GH_PAGES_TOKEN", "").strip()
    repository = env.get("GITHUB_REPOSITORY", "").strip()
    bundle_id = env.get("BUNDLE_ID", "com.smoze.antigravity").strip()
    version = env.get("MARKETING_VERSION", "1.0.0").strip()

    if not token or not repository:
        print("Missing GH_PAGES_TOKEN or GITHUB_REPOSITORY. Skipping OTA deploy.")
        return 0

    owner, repo_name = repository.split("/", 1)
    ipa_url = f"https://github.com/{repository}/releases/latest/download/Antigravity.ipa"
    manifest_xml = generate_manifest(bundle_id, version, ipa_url, title="Antigravity")

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        (tmp_path / "manifest.plist").write_text(manifest_xml, encoding="utf-8")
        
        index_html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Install Antigravity</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background: #0d1117; color: #f0f6fc; text-align: center; padding: 50px 20px; }}
        .btn {{ display: inline-block; background: #1f6feb; color: white; padding: 14px 28px; border-radius: 12px; font-weight: 600; text-decoration: none; font-size: 18px; margin-top: 20px; }}
        .card {{ background: #161b22; max-width: 400px; margin: 0 auto; padding: 30px; border-radius: 16px; border: 1px solid #30363d; }}
    </style>
</head>
<body>
    <div class="card">
        <h1>🚀 Antigravity iOS</h1>
        <p>Version: {version}</p>
        <a class="btn" href="itms-services://?action=download-manifest&url=https://{owner}.github.io/{repo_name}/manifest.plist">Install App</a>
    </div>
</body>
</html>"""
        (tmp_path / "index.html").write_text(index_html, encoding="utf-8")

        # Push to gh-pages branch
        try:
            remote_url = f"https://x-access-token:{token}@github.com/{repository}.git"
            subprocess.run(["git", "clone", "--depth", "1", "--branch", "gh-pages", remote_url, "gh-pages-repo"], cwd=tmp_dir, check=False)
            pages_dir = tmp_path / "gh-pages-repo"
            if not pages_dir.exists():
                subprocess.run(["git", "init"], cwd=tmp_dir, check=True)
                subprocess.run(["git", "checkout", "-b", "gh-pages"], cwd=tmp_dir, check=True)
                pages_dir = tmp_path
            
            shutil.copy(tmp_path / "manifest.plist", pages_dir / "manifest.plist")
            shutil.copy(tmp_path / "index.html", pages_dir / "index.html")

            subprocess.run(["git", "config", "user.name", "github-actions[bot]"], cwd=str(pages_dir), check=True)
            subprocess.run(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"], cwd=str(pages_dir), check=True)
            subprocess.run(["git", "add", "manifest.plist", "index.html"], cwd=str(pages_dir), check=True)
            subprocess.run(["git", "commit", "-m", f"Deploy OTA manifest {version}"], cwd=str(pages_dir), check=True)
            subprocess.run(["git", "push", "-f", remote_url, "gh-pages"], cwd=str(pages_dir), check=True)
            print("Successfully deployed OTA pages!")
        except Exception as e:
            print(f"Warning: Failed to deploy OTA pages: {e}")
    return 0


if __name__ == "__main__":
    sys.exit(deploy())
