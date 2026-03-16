<div align="center">
  <h1>
    TXG0Fk3's <img src="https://i.imgur.com/1uhQUhh.png" alt="NixOS" width="50"/> Configuration
  </h1>
</div>

<div align="center">
  
  [![Forgejo](https://img.shields.io/badge/Hosted_at-Forgejo-7ebae4?style=for-the-badge&logo=forgejo&logoColor=white)](https://fgj.txgfk.xyz/TXG0Fk3/NixOS-Config)
  ![GitHub last commit (mirror)](https://img.shields.io/github/last-commit/TXG0Fk3/NixOS-Config?label=last%20mirror&style=for-the-badge&color=5277c3)
  ![GitHub stars](https://img.shields.io/github/stars/TXG0Fk3/NixOS-Config?style=for-the-badge&color=7ebae4)
</div>

<div align="center">
    <h2>📖 Overview</h2>

This repository contains my personal NixOS configuration. The goal is to have a consistent, fast, and easy-to-replicate environment.
</div>

<div align="center">
    <h2>🗃️ Structure</h2>
</div>

- [❄️ flake.nix](flake.nix) - Flakes configuration
- [🏠 home-manager](home-manager/) - HomeManager files
  - [🧩 modules](home-manager/modules/) - HomeManager modules
  - [👤 users](home-manager/users/) - Users configs
- [🔑 secrets](secrets/) - Sops secrets
- [🔧 system](system/) - System Files
  - [🧩 modules](system/modules/) - System modules
  - [🖥️ hosts](system/hosts/) - Hosts configs
    - [🐉 hydra](system/hosts/hydra/) - My homelab server
    - [🌠 orion](system/hosts/orion/) - My personal computer
    - [🐦‍🔥 phoenix](system/hosts/phoenix) - Disposable virtual machine

<div align="center">
    <h2>🖥️ Screenshots</h2>
</div>

<div align="center">
  <h3>🌠 Orion</h3>
  <img src="assets/screenshots/orion.png" width="840"/>
  <br>
  <sub>GNOME • Marble-Blue-Dark</sub>
</div>


