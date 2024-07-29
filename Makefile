.PHONY: dev
dev:
	nim js toc.nim
	web-ext run

.PHONY: lint
lint:
	web-ext lint

.PHONY: package
package:
	nim js -d:release toc.nim
	web-ext build -n archive.zip --overwrite-dest
	web-ext sign \
		--api-key $(ADDONS_MOZ_JWT_ISSUER) --api-secret $(ADDONS_MOZ_JWT_SECRET) \
		--channel listed \
		--amo-metadata ./amo-metadata.json
