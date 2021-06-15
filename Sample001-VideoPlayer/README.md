# iOS Samples > Sample001-VideoPlayer

AVPlayer & SwiftUI & Combine & async/await 実験用プロジェクト

# 開発環境

- Xcode 13 beta
- iOS 15.0 以上

# 環境構築

多分合ってる...

```sh
# brew でツールをインストール
brew install rbenv
brew install mint

# rbenv で Ruby をインストール
rbenv install 3.0.1

# bundler gem をインストール
rbenv exec gem install bundler

# gem 一括インストール
rbenv exec bundle install

# mint で ツールをインストール
mint bootstrap

# XcodeGen 実行
#   XcodeGen 実行後に pod install が実行される
make xcodegen
```

# 動作の様子

https://user-images.githubusercontent.com/4784032/121989985-01195700-cdd8-11eb-85f7-559b2b59663e.mov
