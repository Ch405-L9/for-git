.PHONY: venv upgini enrich clean

venv:
	python3 -m venv .venv && . .venv/bin/activate && pip install --upgrade pip

upgini:
	. .venv/bin/activate && pip install pandas upgini

enrich:
	./scripts/enrich.sh outputs/contacts/contacts.csv outputs/enriched/enriched.csv upgini EMAIL

clean:
	rm -rf outputs/enriched/enriched.csv

.PHONY: enrich autodoc one_shot
enrich:
	@bash scripts/enrich.sh

autodoc:
	@bash scripts/update_helpers_and_docs.sh

one_shot: enrich autodoc
	@echo "[DONE] Enrichment + Autodoc complete"
