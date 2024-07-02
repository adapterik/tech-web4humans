# The Make File

.PHONY: all test build docs

run-dev-server:
	@echo "Starting dev server..."
	@docker compose run --rm --service-ports ruby

run-server:
	@echo "Starting dev server..."
	@docker compose run --rm --service-ports ruby

npm-install:
	@echo "Fetching npm dependencies..."
	@sh scripts/host/npm-install.sh
	@echo "...done."

example:
	sh scripts/host/example.sh

install-npm-dependencies: clean-npm-dependencies npm-install
	#sh scripts/host/install-npm-dependencies.sh
	@echo "Installing npm dependencies"
	@mkdir -p public/js/vendor
	@cp node_modules/requirejs/require.js public/js/vendor/require.js
	@mkdir -p public/style/vendor/font-awesome
	@cp -pr node_modules/font-awesome/css public/style/vendor/font-awesome
	@cp -pr node_modules/font-awesome/fonts public/style/vendor/font-awesome
	#	@mkdir -p public/style/vendor/normalize.css
	@cp node_modules/normalize.css/normalize.css public/style/vendor/normalize.css
	@echo "...done."

clean-npm-dependencies:
	@echo "Cleaning npm dependencies"
	rm -rf public/style/vendor
	rm -rf public/js/vendor
	@echo "...done."
	
start-dev-container:
	@echo "In the container, enter ... HOME_DIR=`pwd` passenger start"
	@sh scripts/host/start-dev-container.sh
    