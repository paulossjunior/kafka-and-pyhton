# =====================================
# Variáveis
# =====================================
PYTHON := python3
PIP := pip3
DOCKER_COMPOSE := docker-compose

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
build:
	@$(call print-yellow, building ...)
	$(DOCKER_COMPOSE) build
	@$(call print-green, Compilados)	

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
