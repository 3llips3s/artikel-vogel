# studio10200.dev — Deployment & Replication Guide

This guide documents the complete production setup derived from the Hangmensch project.
Use it as the standard blueprint for every new game and for the portfolio itself.

---

## Part 1: Architecture Overview

### The "Under One Roof" Strategy
All projects live on GitHub, served through GitHub Pages, under the single domain `studio10200.dev`.

| Role | Repository | URL |
| :--- | :--- | :--- |
| **Portfolio** | `3llips3s.github.io` | `https://studio10200.dev/` |
| **Game (Web + Android)** | e.g. `hangmensch` | `https://studio10200.dev/hangmensch/` |
| **Game (Android-only)** | e.g. `[game-name]` | No web URL — APK via Releases only |

### Rules for Game Repos
- **DO NOT** include a `CNAME` file (the Portfolio owns the domain).
- **ALWAYS** set `--base-href "/[repo-name]/"` in every web build command.
- The repo name becomes the URL subpath — **choose it carefully upfront**.

### Rules for the Portfolio Repo
- **Must** include `web/CNAME` containing `studio10200.dev`.
- Built with `--base-href "/"`.
- All links to games use the subpath format above.

---

## Part 2: Setting Up a New Game (Web + Android)

### Step 1 — Metadata & Naming
| File | What to Update |
| :--- | :--- |
| `pubspec.yaml` | `name`, `description`, `version` |
| `AndroidManifest.xml` | `android:label="Your Game Name"` |
| `web/index.html` | `<title>`, meta description, apple-mobile-web-app-title |
| `web/manifest.json` | `name`, `short_name`, `description` |

**`index.html` Initialization**: Use the modern Flutter loader. Replace any legacy script block with:
```html
<script src="flutter_bootstrap.js" async></script>
```
Do NOT use the deprecated `_flutter.loader.loadEntrypoint(...)` pattern.

### Step 2 — Android Configuration
In `android/app/build.gradle.kts`:

```kotlin
android {
    namespace = "dev.studio10200.[game_name]"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"   // Required — avoids plugin NDK conflicts
    ...
    defaultConfig {
        applicationId = "dev.studio10200.[game_name]"
        ...
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

> [!IMPORTANT]
> The NDK version `27.0.12077973` is required by `audioplayers`, `path_provider`, and `shared_preferences`. Always pin this version to avoid build conflicts.

### Step 3 — Icon Generation
1. Add to `pubspec.yaml` under `dev_dependencies`:
   ```yaml
   flutter_launcher_icons: ^0.14.4
   ```
2. Add configuration at the root of `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: "ic_launcher"
     ios: true
     image_path: "assets/icons/icon_full.png"
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/icons/icon_foreground.png"
     web:
       generate: true
       image_path: "assets/icons/icon_full.png"
       background_color: "#FFFFFF"
       theme_color: "#FFFFFF"
   ```
3. Place your icon files in `assets/icons/` and declare the folder in `pubspec.yaml` assets.
4. Run: `flutter pub get && dart run flutter_launcher_icons`

### Step 4 — Code Cleanliness
Before any production build, verify:
```bash
grep -r "print(" lib/
grep -r "debugPrint(" lib/
```
Both commands should return **zero results**.

### Step 5 — Legal & Documentation
- Create a `LICENSE` file (MIT recommended):
  ```
  MIT License
  Copyright (c) 2026 3llips3s
  ```
- Create a `README.md` with: About, Tech Stack, How to Play (Web), Installation (Android), License.

### Step 6 — Git Integrity

**`.gitignore` additions** (append to the default Flutter `.gitignore`):
```gitignore
# Internal IDE / AI docs
*.antigravity*
brain/
hangmensch_*.md
*_prd.md
*_progress.md
*_setup_guide.md

# Android secrets
/android/local.properties
/android/app/key.properties
**/*.jks
**/*.keystore

# Environment
.env*
```

**If internal files were already committed**, untrack them without deleting locally:
```bash
git rm --cached [filename]
git commit -m "chore: remove internal files from tracking"
```

> [!NOTE]
> Files removed this way will still exist in prior commits. For documentation this is fine. For secrets, a full history rewrite would be required.

### Step 7 — GitHub Actions (CI/CD)

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main

permissions:
  contents: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: '3.29.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Build Web
        run: flutter build web --release --base-href "/[repo-name]/"

      - name: Deploy to GitHub Pages
        uses: JamesIves/github-pages-deploy-action@v4
        with:
          folder: build/web
          branch: gh-pages
```

> [!IMPORTANT]
> Change `/[repo-name]/` to match the actual GitHub repository name. This must match exactly.

### Step 8 — Building & Releasing

**APK (Android)**:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Web (manual — normally handled by the Action)**:
```bash
flutter build web --release --base-href "/[repo-name]/"
```

**Git Tag (mark the release)**:
```bash
git tag -a v1.0.0 -m "Production release v1.0.0"
git push origin v1.0.0
```

**Creating the GitHub Release**:
1. Go to the repo > **Releases** > **Draft a new release**.
2. Select your tag (`v1.0.0`).
3. Title: `[Game Name] v1.0.0`.
4. Upload `app-release.apk` as the binary attachment.
5. Publish.

**Direct download link** (use this in portfolio buttons):
```
https://github.com/3llips3s/[repo-name]/releases/latest/download/app-release.apk
```

### Step 9 — Activate GitHub Pages
After the first successful Action run:
1. Go to repo **Settings > Pages**.
2. Under **Build and deployment**, set:
   - **Branch**: `gh-pages`
   - **Folder**: `/(root)`
3. Click **Save**. The site will be live within ~60 seconds.

---

## Part 3: Android-Only Game

For a game that ships as APK only (no web version), skip Steps 1 (web parts), 7, and 9.
- You only need Steps 2 (Android config), 3 (icons), 4 (cleanliness), 5 (legal), 6 (git), and 8 (build only the APK).
- Create a GitHub Release and upload the APK. The portfolio links directly to the download URL.

---

## Part 4: Setting Up the Portfolio

> [!IMPORTANT]
> The portfolio repo must be set up **before** pointing your domain to GitHub. Any game already deployed will automatically become available at `studio10200.dev/[game-name]` once the portfolio claims the root.

### Step 1 — Create the Repo
- Repo name: `3llips3s.github.io`
- Clone and set up the Flutter project using the fork from `david-legend/david-legend.github.io`.

### Step 2 — Add the Domain File
Create `web/CNAME`:
```
studio10200.dev
```

### Step 3 — Configure `deploy.yml`
Use the same template as games, but with `--base-href "/"`:
```yaml
- name: Build Web
  run: flutter build web --release --base-href "/"
```

### Step 4 — Cloudflare DNS
Log in to Cloudflare > `studio10200.dev` > DNS records.

**First, delete** any existing records that point to `studio10200-legal.pages.dev` (the old legal pages project).

**Then add**:
| Type | Name | Content | Proxy Status |
| :--- | :--- | :--- | :--- |
| A | `@` | `185.199.108.153` | DNS Only |
| A | `@` | `185.199.109.153` | DNS Only |
| A | `@` | `185.199.110.153` | DNS Only |
| A | `@` | `185.199.111.153` | DNS Only |
| CNAME | `www` | `3llips3s.github.io` | DNS Only |

> [!TIP]
> Use "DNS Only" (grey cloud, not orange) to avoid Cloudflare proxy conflicts with GitHub's SSL certificate.

### Step 5 — GitHub Settings
1. Push the portfolio to `main`.
2. Wait for the Action to complete (the `gh-pages` branch gets created).
3. Go to repo **Settings > Pages**: set Branch to `gh-pages`, Folder to `/(root)`, Save.
4. In the same Settings > Pages, enter `studio10200.dev` in **Custom Domain** and click Save.
5. Wait for the DNS check to pass (~5-30 min), then check **Enforce HTTPS**.

---

## Project Registry

| Game | Repo | Web? | Android? | URL |
| :--- | :--- | :---: | :---: | :--- |
| Hangmensch | `hangmensch` | ✅ | ✅ | `studio10200.dev/hangmensch/` |
| [Game 2] | `[repo-name]` | ✅ | ✅ | `studio10200.dev/[repo-name]/` |
| [Game 3] | `[repo-name]` | ❌ | ✅ | APK download only |
| Portfolio | `3llips3s.github.io` | ✅ | ❌ | `studio10200.dev/` |
