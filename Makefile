.PHONY: build
build:
	spin build -u --sqlite="@migration.sql"
