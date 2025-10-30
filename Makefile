.PHONY: venv upgini enrich clean

venv:
	python3 -m venv .venv && . .venv/bin/activate && pip install --upgrade pip

upgini:
	. .venv/bin/activate && pip install pandas upgini

enrich:
	./scripts/enrich.sh outputs/contacts/contacts.csv outputs/enriched/enriched.csv upgini EMAIL

clean:
	rm -rf outputs/enriched/enriched.csv
