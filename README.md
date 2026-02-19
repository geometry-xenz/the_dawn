# 📝 PowerShell Daily Learner

A streamlined Command Line Interface (CLI) tool designed to help you log daily learning milestones and retrieve them instantly. This tool helps you maintain a chronological journal of your progress using a clean folder structure and Markdown formatting.

---

## 🚀 Quick Start

To begin logging your entries, follow these steps:

1. **Open PowerShell 7** — This script is optimized for the latest version of PowerShell for the best visual experience.

2. **Run the Script** — Execute the script from your terminal:
```powershell
.\dawn.ps1
```

3. **Select Your Identity** — Choose your name from the numbered list provided by the static database.

4. **Log Your Progress** — Select `1) Log an Entry` and type what you learned today.

> 💡 **Tip:** You can use Markdown syntax like `**bold**` or `- bullets` directly in the prompt!

---

## 📅 Retrieving Past Logs

To view your previous entries without leaving the terminal:

1. Select your name from the user menu.
2. Choose option `2) Retrieve an Entry`.
3. When prompted, enter the date in **Day Month** format.
   - Example: `20 2` for February 20th.
   - Example: `5 12` for December 5th.

### Rendering Engine

| Environment | Behavior |
|---|---|
| PowerShell 7+ | Uses the `Show-Markdown` engine for a beautiful, color-coded display |
| Legacy (PS 5.1) | Automatically falls back to raw text display to ensure data is always accessible |

---

## 🛠️ Prerequisites

- **PowerShell 7+** — Highly recommended.
  - Install Command: `winget install --id Microsoft.Powershell --source winget`
- **File System** — Ensure the script has write permissions to create the `./Month/Day/` directory structure.

---

## 📂 Data Structure

Your logs are saved in a clean, human-readable hierarchy:
```
./[MonthName]/[Day]/[username]_learning.md
```