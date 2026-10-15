# Path: .github/scripts/deploy_ota_pages.py
"""Generate custom Antigravity OTA manifest.plist, site, and deploy to gh-pages."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def generate_manifest(bundle_id: str, version: str, ipa_url: str, title: str = "ZeroG") -> str:
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
    direct_ipa = f"https://{owner}.github.io/{repo_name}/ZeroG.ipa"

    return f"""<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>ZeroG — Установка на iPhone</title>
    <link rel="icon" type="image/png" href="AppIcon.png">
    <style>
        :root {{
            --bg: #090a0f;
            --card-bg: rgba(255, 255, 255, 0.05);
            --card-border: rgba(255, 255, 255, 0.12);
            --accent: #0A84FF;
            --accent-glow: rgba(10, 132, 255, 0.4);
            --text: #F5F5F7;
            --text-secondary: #86868B;
        }}
        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", sans-serif;
            -webkit-font-smoothing: antialiased;
        }}
        body {{
            background: radial-gradient(circle at 50% 0%, #1c1e2e 0%, var(--bg) 75%);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 24px 16px;
        }}
        .container {{
            max-width: 440px;
            width: 100%;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(40px);
            -webkit-backdrop-filter: blur(40px);
            border-radius: 32px;
            padding: 36px 24px;
            text-align: center;
            box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
        }}
        .app-icon {{
            width: 108px;
            height: 108px;
            border-radius: 24px;
            margin: 0 auto 20px;
            box-shadow: 0 12px 32px rgba(10, 132, 255, 0.35);
            display: block;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }}
        h1 {{
            font-size: 28px;
            font-weight: 700;
            letter-spacing: -0.5px;
            margin-bottom: 6px;
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
            background: rgba(10, 132, 255, 0.15);
            border: 1px solid rgba(10, 132, 255, 0.3);
            color: #64D2FF;
            font-size: 13px;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 99px;
            margin-bottom: 24px;
        }}
        .badge .dot {{
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #30D158;
            box-shadow: 0 0 10px #30D158;
        }}
        .info-list {{
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.06);
            border-radius: 18px;
            padding: 16px;
            margin-bottom: 24px;
            text-align: left;
            font-size: 14px;
        }}
        .info-row {{
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }}
        .info-row:last-child {{
            border-bottom: none;
        }}
        .info-label {{
            color: var(--text-secondary);
        }}
        .info-val {{
            font-weight: 600;
            color: #F5F5F7;
        }}
        .btn-install {{
            display: block;
            width: 100%;
            background: linear-gradient(180deg, #0A84FF 0%, #0066CC 100%);
            color: #ffffff;
            text-decoration: none;
            font-size: 17px;
            font-weight: 600;
            padding: 16px 20px;
            border-radius: 16px;
            box-shadow: 0 8px 24px var(--accent-glow);
            transition: all 0.2s ease;
            cursor: pointer;
            border: none;
            margin-bottom: 14px;
        }}
        .btn-install:active {{
            transform: scale(0.98);
            filter: brightness(0.9);
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
        .tip-warning {{
            border-left: 3px solid #FF9F0A;
            background: rgba(255, 159, 10, 0.1);
            color: #FFD60A;
            text-align: left;
        }}
        .fallback-link {{
            margin-top: 14px;
            display: inline-block;
            font-size: 13px;
            color: #64D2FF;
            text-decoration: none;
        }}
        .fallback-link:hover {{
            text-decoration: underline;
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
        <img src="AppIcon.png" alt="ZeroG iOS" class="app-icon" />

        <h1>ZeroG</h1>
        <p class="subtitle">Автономный AI-агент Antigravity • Swift 6</p>

        <div class="badge">
            <span class="dot"></span>
            Подписано сертификатом разработчика
        </div>

        <div class="info-list">
            <div class="info-row">
                <span class="info-label">Сертификат</span>
                <span class="info-val">iPhone Distribution (до 05.12.2026)</span>
            </div>
            <div class="info-row">
                <span class="info-label">Устройство</span>
                <span class="info-val">Ваш iPhone (UDID привязан)</span>
            </div>
            <div class="info-row">
                <span class="info-label">Установка</span>
                <span class="info-val">Прямая (Over-The-Air)</span>
            </div>
        </div>

        <a id="installBtn" href="{ota_url}" class="btn-install">
            📲 Установить ZeroG на iPhone
        </a>

        <div class="tip tip-warning">
            ⚠️ <b>Важно:</b> Если на вашем iPhone уже установлено приложение <b>Sonivo (Aura Player)</b>, обязательно <b>удалите его</b> перед установкой! Так как сертификат привязан к одному Bundle ID, iOS не сможет создать отдельную иконку, пока старое приложение не удалено.
        </div>

        <div class="tip">
            После нажатия кнопки или перехода по ссылке в Safari появится окно iOS:<br>
            <b>«{owner}.github.io собирается установить "ZeroG"»</b>.<br>
            Нажмите <b>«Установить»</b> — приложение сразу появится на экране!
        </div>

        <a href="{direct_ipa}" class="fallback-link">Скачать прямой файл .ipa</a>

        <p class="footer">ZeroG Cloud • Версия {version} (сборка #{build_num})</p>
    </div>

    <script>
        // Автоматический запуск установки при открытии в Safari на iOS
        function autoTriggerInstall() {{
            if (/iPhone|iPad|iPod/.test(navigator.userAgent)) {{
                window.location.href = "{ota_url}";
            }}
        }}
        window.addEventListener("DOMContentLoaded", () => {{
            setTimeout(autoTriggerInstall, 350);
        }});
    </script>
</body>
</html>"""


def deploy(env=None):
    if env is None:
        env = os.environ

    token = env.get("GH_PAGES_TOKEN", "").strip()
    repository = env.get("GITHUB_REPOSITORY", "").strip()
    bundle_id = env.get("BUNDLE_ID", "app.hare5681.zerog").strip()
    version = env.get("MARKETING_VERSION", "1.0.0").strip()
    build_num = env.get("BUILD_NUMBER", "1").strip()
    temp_dir = Path(env.get("RUNNER_TEMP", tempfile.gettempdir()))

    if not token or not repository:
        print("Missing GH_PAGES_TOKEN or GITHUB_REPOSITORY, skipping OTA deploy.")
        return 0

    owner, repo_name = repository.split("/", 1)
    ipa_url = f"https://{owner}.github.io/{repo_name}/ZeroG.ipa"

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

    ipa_src = Path("ZeroG.ipa")
    if not ipa_src.exists():
        if Path("Antigravity.ipa").exists():
            ipa_src = Path("Antigravity.ipa")
        elif Path("ZeroG-unsigned.ipa").exists():
            ipa_src = Path("ZeroG-unsigned.ipa")
        elif Path("Antigravity-unsigned.ipa").exists():
            ipa_src = Path("Antigravity-unsigned.ipa")
        else:
            print("ZeroG.ipa not found for OTA deploy!")
            return 1

    shutil.copy2(ipa_src, pages_dir / "ZeroG.ipa")
    shutil.copy2(ipa_src, pages_dir / "Antigravity.ipa")

    manifest_content = generate_manifest(bundle_id=bundle_id, version=version, ipa_url=ipa_url)
    (pages_dir / "manifest.plist").write_text(manifest_content, encoding="utf-8")

    index_html = generate_html(owner, repo_name, version, build_num)
    (pages_dir / "index.html").write_text(index_html, encoding="utf-8")

    # Important: .nojekyll disables Jekyll processing on GitHub Pages
    (pages_dir / ".nojekyll").write_text("", encoding="utf-8")

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
