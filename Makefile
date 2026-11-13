# Ручные curl-проверки сервиса. Сервис: npm run dev (по умолчанию :3000).
#
# Порядок для result.json из TASK.md:
#   docker compose up -d && npm run migrate && npm run dev
#   make sync
#   make webhooks
#   make result

BASE   ?= http://localhost:3000
ID     ?= c_7
FROM   ?= 2026-03-27
TO     ?= 2026-03-31

TOTALS_URL = $(BASE)/customers/$(ID)/daily-totals?from=$(FROM)&to=$(TO)

.DEFAULT_GOAL := help

.PHONY: help health sync totals result webhook webhooks

help:
	@echo health    GET  /health
	@echo sync      POST /sync
	@echo totals    GET  /customers/$(ID)/daily-totals?from=$(FROM)^&to=$(TO)
	@echo result    тот же запрос, ответ в result.json
	@echo webhook   POST /webhooks/order (пример заказа со скидкой)
	@echo webhooks  прогон вебхуков внешнего API (docker compose)

health:
	curl -sS --fail-with-body -w "\n" "$(BASE)/health"

sync:
	curl -sS --fail-with-body -w "\n" -X POST "$(BASE)/sync"

totals:
	curl -sS --fail-with-body -w "\n" "$(TOTALS_URL)"

result:
	curl -sS --fail-with-body "$(TOTALS_URL)" -o result.json
	@echo wrote result.json

webhook:
	curl -sS --fail-with-body -w "\n" -X POST "$(BASE)/webhooks/order" -H "Content-Type: application/json" -d "{\"id\":\"o_demo\",\"customerId\":\"$(ID)\",\"amount\":1000,\"discountPercent\":10,\"amountPaid\":900,\"status\":\"paid\",\"createdAt\":\"$(FROM)T12:00:00.000Z\",\"updatedAt\":\"$(FROM)T12:00:00.000Z\"}"

webhooks:
	docker compose run --rm orders-api webhooks --target http://host.docker.internal:3000/webhooks/order
