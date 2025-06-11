# Variáveis
PYTHON := python3
PIP := pip3
DOCKER_COMPOSE := docker-compose
KAFKA_FILE := simple_kafka.py

# Cores para output
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BLUE := \033[34m
RESET := \033[0m

install: ## Instala as dependências Python
	@echo "$(YELLOW)Instalando dependências...$(RESET)"
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependências instaladas!$(RESET)"


kafka-up: ## Sobe o ambiente Kafka com Docker
	@echo "$(YELLOW)Subindo Kafka...$(RESET)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Kafka está rodando!$(RESET)"
	@echo "$(BLUE)Kafka UI: http://localhost:8080$(RESET)"

kafka-down: ## Para o ambiente Kafka
	@echo "$(YELLOW)Parando Kafka...$(RESET)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Kafka parado!$(RESET)"

consumer: ## Executa o consumer simples
	@echo "$(YELLOW)Iniciando Consumer...$(RESET)"
	@echo "$(BLUE)Pressione Ctrl+C para parar$(RESET)"
	$(PYTHON) ./src/simple_consumer.py

producer: ## Executa o producer simples
	@echo "$(YELLOW)Iniciando Producer...$(RESET)"
	$(PYTHON) ./src/simple_producer.py