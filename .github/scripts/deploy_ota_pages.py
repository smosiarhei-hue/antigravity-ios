# Path: .github/scripts/deploy_ota_pages.py
"""Generate custom Antigravity OTA manifest.plist, site, and deploy to gh-pages."""

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


def generate_html(owner: str, repo_name: str, version: str, build_num: str) -> str:
    ota_url = f"itms-services://?action=download-manifest&url=https://{owner}.github.io/{repo_name}/manifest.plist"
    direct_ipa = f"https://{owner}.github.io/{repo_name}/Antigravity.ipa"

    return f"""<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Antigravity iOS — Установка на iPhone</title>
    <link rel="icon" type="image/png" href="AppIcon.png">
    <style>
        :root {{
            --bg: #090a0f;
            --card-bg: rgba(22, 27, 34, 0.75);
            --card-border: rgba(255, 255, 255, 0.12);
            --accent-blue: #58a6ff;
            --accent-purple: #a371f7;
            --accent-green: #3fb950;
            --text-primary: #f0f6fc;
            --text-secondary: #8b949e;
        }}
        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Segoe UI", sans-serif;
            -webkit-font-smoothing: antialiased;
        }}
        body {{
            background: radial-gradient(circle at 50% -10%, #1c2333 0%, var(--bg) 80%);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justifyContent: center;
            padding: 32px 16px;
        }}
        .container {{
            max-width: 460px;
            width: 100%;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(40px);
            -webkit-backdrop-filter: blur(40px);
            border-radius: 36px;
            padding: 36px 24px;
            text-align: center;
            box-shadow: 0 30px 80px rgba(0, 0, 0, 0.7), 0 0 40px rgba(88, 166, 255, 0.15);
            position: relative;
            overflow: hidden;
        }}
        .icon-wrap {{
            position: relative;
            width: 112px;
            height: 112px;
            margin: 0 auto 18px;
        }}
        .app-icon {{
            width: 112px;
            height: 112px;
            border-radius: 26px;
            box-shadow: 0 16px 36px rgba(0, 0, 0, 0.6), 0 0 24px rgba(88, 166, 255, 0.4);
            display: block;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }}
        h1 {{
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -0.6px;
            margin-bottom: 6px;
            background: linear-gradient(135deg, #ffffff 40%, #58a6ff 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}
        .subtitle {{
            font-size: 14px;
            color: var(--text-secondary);
            margin-bottom: 18px;
            line-height: 1.4;
        }}
        .badge {{
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            background: rgba(63, 185, 80, 0.15);
            border: 1px solid rgba(63, 185, 80, 0.4);
            color: #3fb950;
            margin-bottom: 24px;
        }}
        .btn-install {{
            display: block;
            width: 100%;
            background: linear-gradient(135deg, #1f6feb 0%, #388bfd 100%);
            color: #ffffff;
            font-size: 17px;
            font-weight: 700;
            text-decoration: none;
            padding: 16px 24px;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(31, 111, 235, 0.45);
            transition: transform 0.15s ease;
            margin-bottom: 12px;
        }}
        .btn-install:active {{
            transform: scale(0.98);
        }}
        .btn-secondary {{
            display: block;
            width: 100%;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid var(--card-border);
            color: var(--text-primary);
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            padding: 12px;
            border-radius: 14px;
            margin-bottom: 24px;
        }}
        .tip {{
            margin-top: 14px;
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
            background: rgba(0, 0, 0, 0.25);
            border-radius: 14px;
            padding: 12px;
            border: 1px solid rgba(255, 255, 255, 0.05);
        }}
        .footer {{
            margin-top: 20px;
            font-size: 11px;
            color: rgba(255, 255, 255, 0.3);
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="icon-wrap">
            <img src="AppIcon.png" alt="Antigravity iOS" class="app-icon" />
        </div>

        <h1>Antigravity</h1>
        <p class="subtitle">Автономный AI-агент для iOS на базе Swift 6 и Gemini 2.5 Pro</p>

        <div class="badge">
            <span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#3fb950;"></span>
            Подписано сертификатом разработчика
        </div>

        <a id="installBtn" href="{ota_url}" class="btn-install">
            📲 Установить обновление на iPhone
        </a>

        <a href="{direct_ipa}" class="btn-secondary">
            ⬇️ Скачать прямой файл .ipa
        </a>

        <div class="tip">
            После открытия ссылки Safari покажет системное окно iOS:<br>
            <b>«{owner}.github.io собирается установить "Antigravity"»</b>.<br>
            Нажмите <b>«Установить»</b> — и приложение моментально появится на домашнем экране.
        </div>

        <p class="footer">Antigravity Cloud • Версия {version} (билд #{build_num})</p>
    </div>

    <script>
        // Автоматический вызов установки на iOS при открытии ссылки
        function autoTriggerInstall() {
            if (/iPhone|iPad|iPod/.test(navigator.userAgent)) {
                window.location.href = "{ota_url}";
            }
        }
        window.addEventListener("DOMContentLoaded", () => {
            setTimeout(autoTriggerInstall, 350);
        });
    </script>
</body>
</html>"""


def deploy(env=None):
    if env is None:
        env = os.environ

    token = env.get("GH_PAGES_TOKEN", "").strip()
    repository = env.get("GITHUB_REPOSITORY", "").strip()
    bundle_id = env.get("BUNDLE_ID", "app.hare5681.lyra4838").strip()
    version = env.get("MARKETING_VERSION", "1.0.0").strip()
    build_num = env.get("BUILD_NUMBER", "1").strip()
    temp_dir = Path(env.get("RUNNER_TEMP", tempfile.gettempdir()))

    if not token or not repository:
        print("Missing GH_PAGES_TOKEN or GITHUB_REPOSITORY, skipping OTA deploy.")
        return 0

    owner, repo_name = repository.split("/", 1)
    ipa_url = f"https://{owner}.github.io/{repo_name}/Antigravity.ipa"

    pages_dir = temp_dir / "gh_pages_deploy"
    if pages_dir.exists():
        shutil.rmtree(pages_dir)

    print(f"Cloning gh-pages branch from {repository}...")
    clone_url = f"https://x-access-token:{token}@github.com/{repository}.git"
    res = subprocess.run(
        ["git", "clone", "--depth", "1", "--branch", "gh-pages", clone_url, str(pages_dir)],
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
        print(f"Failed to clone gh-pages: {res.stderr}")
        return 1

    ipa_src = Path("Antigravity.ipa")
    if not ipa_src.exists():
        if Path("Antigravity-unsigned.ipa").exists():
            ipa_src = Path("Antigravity-unsigned.ipa")
        else:
            print("Antigravity.ipa not found for OTA deploy!")
            return 1

    shutil.copy2(ipa_src, pages_dir / "Antigravity.ipa")

    manifest_content = generate_manifest(bundle_id=bundle_id, version=version, ipa_url=ipa_url)
    (pages_dir / "manifest.plist").write_text(manifest_content, encoding="utf-8")

    index_html = generate_html(owner, repo_name, version, build_num)
    (pages_dir / "index.html").write_text(index_html, encoding="utf-8")

    icon_source = Path("Antigravity/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
    if icon_source.is_file():
        shutil.copy2(icon_source, pages_dir / "AppIcon.png")

    subprocess.run(["git", "-C", str(pages_dir), "config", "user.name", "github-actions[bot]"], check=True)
    subprocess.run(
        ["git", "-C", str(pages_dir), "config", "user.email", "github-actions[bot]@users.noreply.github.com"],
        check=True,
    )
    subprocess.run(["git", "-C", str(pages_dir), "add", "-A"], check=True)

    commit_res = subprocess.run(
        ["git", "-C", str(pages_dir), "commit", "-m", f"Deploy OTA Antigravity v{version} (#{build_num}) [skip ci]"],
        capture_output=True,
        text=True,
    )
    print(commit_res.stdout)

    push_res = subprocess.run(["git", "-C", str(pages_dir), "push", "origin", "gh-pages"], capture_output=True, text=True)
    if push_res.returncode != 0:
        print(f"Standard push to gh-pages rejected ({push_res.stderr.strip()}), retrying with force...")
        push_res = subprocess.run(["git", "-C", str(pages_dir), "push", "--force", "origin", "gh-pages"], capture_output=True, text=True)

    if push_res.returncode != 0:
        print(f"Failed to push to gh-pages: {push_res.stderr}")
        return 1

    print(f"Successfully deployed OTA build v{version} to GitHub Pages!")
    return 0


if __name__ == "__main__":
    sys.exit(deploy())
