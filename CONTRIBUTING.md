# 🤝 Contributing to Orbit-DevOps

First off, thank you for considering contributing to Orbit-DevOps! It's people like you that make it a great tool for the community.

## 🛠️ Development Workflow

1.  **Fork the repo** and create your branch from `main`.
2.  **Install dependencies**: `npm install`.
3.  **Make your changes**. If you're adding a new PowerShell script, place it in the root or a logical subfolder under `scripts/`.
4.  **Test your changes**: Run `node bin/orbit.js [command]` or `npm link` and run `orbit [command]`.
5.  **Submit a Pull Request** using our PR template.

## 📝 Coding Standards

- **PowerShell**: Use clear variable names, include error handling (`Try/Catch`), and use `Write-Log` (or similar output helpers) for visibility.
- **Node.js**: Follow ESM standards, use `commander` for new CLI commands, and ensure Windows path compatibility using `path.resolve`.

## 🐛 Reporting Issues

Use GitHub Issues to report bugs or suggest features. Be as descriptive as possible and include your OS version and Node.js version.

---
Built with ❤️ by the **Symbeon** community.
