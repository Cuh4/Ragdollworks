![Banner](assets/Imagery/BannerDark.png)

## 📚 Ragdollworks
A Roblox 2D sandbox featuring spawnable objects in various sandbox maps, simulated humans, physics, explosions, and more.

In other words, a cheap ripoff of People Playground.

## 🤬 | Rants
- Luau LSP is the most up-to-date LSP for Roblox, but I can't use it because it can't infer types through references (e.g: `require(Rage.Path.ID)` is an unknown type). Stuck with Roblox LSP that can do this but is outdated and most packages don't support types for it. Fuck
- Roblox LSP: Given two files `foo.luau` and `bar.luau`, if `foo` requires `bar`, and another file called `main.luau` requires `foo` and `bar`, the types in `bar` will get all fucked and can't be used in `main.luau`. The LSP knows its there and even shows that, but it will not provide things like auto-completion when indexing a table of the type. Fuck 

## ©️ | Copyright Notice
```
Copyright (C) 2025 Cuh4 - All Rights Reserved
- Unauthorized copying of this file, via any medium is strictly prohibited
- Proprietary and confidential
```