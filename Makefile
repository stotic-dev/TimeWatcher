RUBY_VERSION := 3.3.10

.PHONY: setup install-ruby install-bundler install help

help:
	@echo "Usage:"
	@echo "  make setup    - Ruby のインストールから fastlane のセットアップまで一括実行"
	@echo "  make install  - bundle install のみ実行（Ruby セットアップ済みの場合）"

setup: install-ruby install-bundler install

install-ruby:
	@echo ">>> rbenv で Ruby $(RUBY_VERSION) をインストールします"
	rbenv install -s $(RUBY_VERSION)
	rbenv local $(RUBY_VERSION)

install-bundler:
	@echo ">>> bundler をインストールします"
	gem install bundler --no-document

install:
	@echo ">>> fastlane をインストールします"
	bundle install
