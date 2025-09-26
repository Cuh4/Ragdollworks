![Banner](assets/Imagery/BannerDark.png)

## 📚 Ragdollworks
A Roblox 2D sandbox featuring spawnable objects in various sandbox maps, simulated humans, physics, explosions, and more.

In other words, a cheap ripoff of People Playground.

## 📸 | Game Screenshots
![Game Screenshot 4: 2D Human in front of explosion](assets/Imagery/GameScreenshots/4.png)
![Game Screenshot 5: 2D Human under light](assets/Imagery/GameScreenshots/5.png)
![Game Screenshot 4: 2D Human falling while bleeding](assets/Imagery/GameScreenshots/1.png)

## 🤬 | Rants
- Luau LSP is the most up-to-date LSP for Roblox, but I can't use it because it can't infer types through references (e.g: `require(Rage.Path.ID)` is an unknown type). Stuck with Roblox LSP that can do this but is outdated and most packages don't support types for it. Fuck
- Roblox LSP: Given two files `foo.luau` and `bar.luau`, if `foo` requires `bar`, and another file called `main.luau` requires `foo` and `bar`, the types in `bar` will get all fucked and can't be used in `main.luau`. The LSP knows its there and even shows that, but it will not provide things like auto-completion when indexing a table of the type. Fuck 

## ©️ | License
```
Copyright (C) 2025 Cuh4

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```