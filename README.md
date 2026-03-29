# Assembly Game (MIPS 組合語言遊戲)

這是一個利用 MIPS 組合語言 (Assembly language) 開發的遊戲專案。本專案搭配 MARS (MIPS Assembler and Runtime Simulator) 模擬器進行開發、組譯與執行。

## 📂 專案配置與檔案說明

本專案的目錄與檔案架構如下：

* **[`main.asm`](./main.asm)**：遊戲的主程式入口，負責初始化與主控流程的呼叫。
* **[`core.asm`](./core.asm)**：遊戲的核心邏輯原始碼，包含主要機制、資料運算與控制狀態等底層實作。
* **`Mars4_5.jar`**：MARS 模擬器的 Java 執行檔，用來編譯、除錯與執行本專案的 MIPS 程式碼。
* **`run_mars.bat`**：Windows 系統的批次檔 (Batch file)，用來快速啟動 MARS 模擬器。
* **`map.png`**：專案中所使用的地圖或圖形素材檔案。
* **`.vscode/`**：Visual Studio Code 的環境設定資料夾，包含編譯與執行所需的 task 設定。
* **[`README.md`](./README.md)**：本專案的主說明文件，介紹專案架構與執行方式。
* **[`Game_Rule.md`](./Game_Rule.md)**：遊戲的規則說明書。詳細記載了遊戲的玩法、操作方式與過關條件，請點擊連結跳轉至該文件查看詳細規則。

---

## 🚀 如何使用與執行此專案

1. 將整個專案 Clone 下來至本機端。
2. 在此專案目錄下透過 **VS Code (Visual Studio Code)** 開啟。
3. 在左側檔案總管選取並開啟 **`main.asm`**。
4. 按下快捷鍵 **`Ctrl + Shift + B`** 即可自動組譯並執行遊戲。