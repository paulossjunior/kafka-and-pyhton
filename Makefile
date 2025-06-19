# =====================================
# Variáveis
# =====================================
PYTHON := python3
PIP := pip3
DOCKER_COMPOSE := docker-compose

TOPIC := meu-topico
PARTITIONS := 2
REPLICATION_FACTOR := 1
BOOTSTRAP := kafka:29092

# Cores para output
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_RED := \033[31m
COLOR_BLUE := \033[34m
COLOR_RESET := \033[0m

# Helpers para impressão colorida
print-yellow = printf "$(COLOR_YELLOW)%s$(COLOR_RESET)\n" "$(1)"
print-green = printf "$(COLOR_GREEN)%s$(COLOR_RESET)\n" "$(1)"
print-blue = printf "$(COLOR_BLUE)%s$(COLOR_RESET)\n" "$(1)"
print-red = printf "$(COLOR_RED)%s$(COLOR_RESET)\n" "$(1)"

# =====================================
# Dependências Python (Local)
# =====================================

install: ## Instala dependências Python localmente
	@$(call print-yellow, Instalando dependências Python...)
	$(PIP) install -r requirements.txt
	@$(call print-green, Dependências instaladas!)

# =====================================
# Kafka + Docker Compose
# =====================================

up: ## Sobe Kafka, UI, Consumer e Producer
	@$(call print-yellow, Subindo Kafka, UI, Consumer e Producer...)
	$(DOCKER_COMPOSE) up -d
	@$(call print-green, Todos os serviços estão rodando!)
	@$(call print-blue, Acesse Kafka UI em: http://localhost:8080)

down: ## Para todos os containers
	@$(call print-yellow, Parando todos os serviços...)
	$(DOCKER_COMPOSE) down
	@$(call print-green, Todos os serviços foram parados!)

logs: ## Mostra os logs dos containers
	@$(DOCKER_COMPOSE) logs -f

# =====================================
# Kafka Tópicos
# =====================================

create-topic: ## Cria um tópico no Kafka
	@$(call print-yellow, Criando tópico '$(TOPIC)' com $(PARTITIONS) partições...)
	docker exec kafka kafka-topics --create --if-not-exists \
		--topic $(TOPIC) \
		--bootstrap-server $(BOOTSTRAP) \
		--partitions $(PARTITIONS) \
		--replication-factor $(REPLICATION_FACTOR)
	@$(call print-green, Tópico '$(TOPIC)' criado com sucesso!)

list-topics: ## Lista tópicos no Kafka
	docker exec kafka kafka-topics --list --bootstrap-server $(BOOTSTRAP)

describe-topic: ## Descreve um tópico
	docker exec kafka kafka-topics --describe --topic $(TOPIC) --bootstrap-server $(BOOTSTRAP)

# =====================================
# Kafka Apps via Docker (Execução única)
# =====================================

consumer: ## Executa o Consumer no container (execução única)
	@$(call print-yellow, Iniciando Consumer (modo execução única)...)
	$(DOCKER_COMPOSE) run --rm consumer

producer: ## Executa o Producer no container (execução única)
	@$(call print-yellow, Iniciando Producer (modo execução única)...)
	$(DOCKER_COMPOSE) run --rm producer

# =====================================
# Kafka Apps via Docker (Modo daemon)
# =====================================

up-apps: ## Sobe apenas Consumer e Producer em segundo plano
	@$(call print-yellow, Subindo Consumer e Producer...)
	$(DOCKER_COMPOSE) up -d consumer producer
	@$(call print-green, Consumer e Producer estão rodando em segundo plano!)

down-apps: ## Para apenas Consumer e Producer
	@$(call print-yellow, Parando Consumer e Producer...)
	$(DOCKER_COMPOSE) stop consumer producer
	@$(call print-green, Consumer e Producer foram parados!)

# =====================================
# Consumidores Dinâmicos
# =====================================

run-consumers: ## Sobe N consumidores dinamicamente. Use CONSUMERS=N
	@if [ -z "$(CONSUMERS)" ]; then \
		$(call print-red, "Erro: Informe a quantidade usando CONSUMERS=N"); \
		exit 1; \
	fi; \
	for i in $$(seq 1 $(CONSUMERS)); do \
		$(call print-yellow, "Subindo consumer-$$i..."); \
		docker-compose run -d --name consumer-$$i -e GROUP_ID=grupo-dinamico docker_consumer; \
	done; \
	$(call print-green, "$(CONSUMERS) consumidores iniciados!")

stop-consumers: ## Para todos os consumers dinâmicos
	@for id in $$(docker ps --filter "name=consumer-" --format "{{.Names}}"); do \
		$(call print-yellow, "Parando $$id..."); \
		docker stop $$id && docker rm $$id; \
	done; \
	$(call print-green, Todos os consumidores dinâmicos foram parados!)

# =====================================
# Desenvolvimento local (Python sem Docker)
# =====================================

consumer-local: ## Executa o Consumer localmente (Kafka precisa estar rodando)
	@$(call print-yellow, Iniciando Consumer local...)
	$(PYTHON) ./src/simple_consumer.py

producer-local: ## Executa o Producer localmente (Kafka precisa estar rodando)
	@$(call print-yellow, Iniciando Producer local...)
	$(PYTHON) ./src/simple_producer.py

# =====================================
# Utilitários
# =====================================

ps: ## Lista os containers rodando
	$(DOCKER_COMPOSE) ps

clean: ## Remove containers, volumes e redes
	@$(call print-yellow, Removendo containers, volumes e redes...)
	$(DOCKER_COMPOSE) down -v --remove-orphans
	@$(call print-green, Cleanup concluído!)

help: ## Mostra este help
	@$(call print-blue, Comandos disponíveis:)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[33m%-20s\033[0m %s\n", $$1, $$2}'
