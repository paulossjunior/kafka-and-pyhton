# 🚀 Kafka Consumer/Producer com Docker

Este projeto demonstra como configurar e usar Apache Kafka com Docker Compose, incluindo exemplos de Consumer e Producer em Python.

## 📋 Sumário

- [Pré-requisitos](#-pré-requisitos)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Docker Compose](#-docker-compose)
- [Makefile](#-makefile)
- [Instalação e Setup](#-instalação-e-setup)
- [Como Usar](#-como-usar)
- [Exemplos Práticos](#-exemplos-práticos)
- [Solução de Problemas](#-solução-de-problemas)

## 🛠 Pré-requisitos

- Docker e Docker Compose instalados
- Python 3.7+
- Make (opcional, mas recomendado)

## 📁 Estrutura do Projeto

```
kafka-project/
├── docker-compose.yml     # Configuração do Kafka
├── Makefile              # Comandos automatizados
├── requirements.txt      # Dependências Python
├── README.md            # Este arquivo
└── src/
    ├── simple_consumer.py
    └── simple_producer.py
```

## 🐳 Docker Compose

O arquivo `docker-compose.yml` configura um ambiente Kafka completo com:

### Serviços Incluídos

#### 🔧 Zookeeper
- **Porta**: 2181
- **Função**: Coordenação e configuração do cluster Kafka
- **Volumes**: Dados persistentes em `zookeeper-data` e `zookeeper-logs`

#### 📨 Kafka Broker
- **Porta Externa**: 9092 (para aplicações externas)
- **Porta Interna**: 29092 (para comunicação entre containers)
- **Porta JMX**: 9101 (para monitoramento)
- **Volumes**: Dados persistentes em `kafka-data`

#### 🖥 Kafka UI
- **Porta**: 8080
- **URL**: http://localhost:8080
- **Função**: Interface web para gerenciar tópicos, visualizar mensagens e monitorar o cluster

### Configurações Importantes

```yaml
# Configuração para desenvolvimento local
KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092

# Criação automática de tópicos
KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'

# Configurações para ambiente de desenvolvimento (single-broker)
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
```

## 🔨 Makefile

O Makefile automatiza tarefas comuns e inclui as seguintes funcionalidades:

### Variáveis de Configuração

```makefile
PYTHON := python3              # Comando Python
PIP := pip3                   # Comando pip
DOCKER_COMPOSE := docker-compose  # Docker Compose
KAFKA_FILE := simple_kafka.py     # Arquivo principal (não usado nesta versão)
```

### Sistema de Cores

O Makefile inclui um sistema de cores para melhor visualização:
- 🟢 **Verde**: Sucessos e confirmações
- 🟡 **Amarelo**: Avisos e processos em andamento
- 🔴 **Vermelho**: Erros
- 🔵 **Azul**: Informações importantes

### Comandos Principais

#### 📦 Gerenciamento de Dependências
```bash
make install    # Instala dependências do requirements.txt
```

#### 🐳 Gerenciamento do Kafka
```bash
make kafka-up   # Inicia o ambiente Kafka
make kafka-down # Para o ambiente Kafka
```

#### 🚀 Execução de Aplicações
```bash
make consumer   # Executa ./src/simple_consumer.py
make producer   # Executa ./src/simple_producer.py
```

## 🚀 Instalação e Setup

### 1. Clone o Projeto
```bash
git clone <seu-repositorio>
cd kafka-project
```

### 2. Crie o arquivo requirements.txt
```bash
echo "kafka-python==2.0.2" > requirements.txt
```

### 3. Setup Completo
```bash
# Instalar dependências Python
make install

# Subir ambiente Kafka
make kafka-up
```

### 4. Verificar Instalação
- Kafka UI: http://localhost:8080
- Verifique se os containers estão rodando:
```bash
docker-compose ps
```

## 🎯 Como Usar

### Método 1: Usando Makefile (Recomendado)

```bash
# Terminal 1 - Iniciar Consumer
make consumer

# Terminal 2 - Executar Producer
make producer
```

### Método 2: Comandos Diretos

```bash
# Subir Kafka
docker-compose up -d

# Terminal 1 - Consumer
python3 ./src/simple_consumer.py

# Terminal 2 - Producer  
python3 ./src/simple_producer.py
```

## 💡 Exemplos Práticos

### 1. Teste Básico Producer/Consumer

```bash
# 1. Subir ambiente
make kafka-up

# 2. Terminal 1: Consumer
make consumer

# 3. Terminal 2: Producer
make producer
```

### 2. Monitoramento via Kafka UI

1. Acesse: http://localhost:8080
2. Navegue até "Topics"
3. Veja as mensagens em tempo real
4. Monitore partições e offsets

### 3. Consumer Personalizado

Crie seu próprio consumer em `src/simple_consumer.py`:

```python
from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'meu-topico',
    bootstrap_servers=['localhost:9092'],
    group_id='meu-grupo',
    value_deserializer=lambda m: json.loads(m.decode('utf-8')),
    auto_offset_reset='earliest'
)

print("👂 Aguardando mensagens...")

for message in consumer:
    print(f"📨 Recebido: {message.value}")
    # Processe sua mensagem aqui
```

### 4. Producer Personalizado

Crie seu próprio producer em `src/simple_producer.py`:

```python
from kafka import KafkaProducer
import json
import time

producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

for i in range(10):
    message = {
        'id': i,
        'data': f'Mensagem {i}',
        'timestamp': time.time()
    }
    
    producer.send('meu-topico', message)
    print(f"✅ Enviado: {message}")
    time.sleep(1)

producer.close()
```

## 🔧 Configurações Avançadas

### Conexão do Kafka

Para aplicações **dentro do Docker**:
```python
bootstrap_servers=['kafka:29092']
```

Para aplicações **no host local**:
```python
bootstrap_servers=['localhost:9092']
```

### Consumer Groups

```python
# Múltiplos consumers no mesmo grupo = load balancing
consumer = KafkaConsumer(
    'meu-topico',
    group_id='processamento-grupo',  # Mesmo grupo
    bootstrap_servers=['localhost:9092']
)
```

### Múltiplos Tópicos

```python
# Subscribe em vários tópicos
consumer = KafkaConsumer(
    bootstrap_servers=['localhost:9092'],
    group_id='multi-grupo'
)
consumer.subscribe(['topico-1', 'topico-2', 'topico-3'])
```

## 🛠 Solução de Problemas

### Kafka não conecta

```bash
# Verificar containers
docker-compose ps

# Ver logs
docker-compose logs kafka

# Reiniciar ambiente
make kafka-down
make kafka-up
```

### Erro de dependências

```bash
# Reinstalar dependências
pip3 install kafka-python==2.0.2

# Ou usar o Makefile
make install
```

### Consumer não recebe mensagens

1. Verificar se o tópico existe no Kafka UI
2. Confirmar `group_id` diferente se quiser reprocessar
3. Usar `auto_offset_reset='earliest'` para ler desde o início

### Porta já em uso

```bash
# Verificar o que está usando a porta
lsof -i :9092

# Parar todos os containers
docker-compose down

# Limpar completamente
docker-compose down -v --remove-orphans
```

## 📊 Monitoramento

### Kafka UI (Recomendado)
- URL: http://localhost:8080
- Funcionalidades:
  - Visualizar tópicos e mensagens
  - Monitorar consumer groups
  - Verificar partições e offsets

### Comandos Docker

```bash
# Status dos containers
docker-compose ps

# Logs em tempo real
docker-compose logs -f kafka

# Uso de recursos
docker stats
```

## 📝 Notas Importantes

- Este setup é para **desenvolvimento local**
- Para **produção**, configure múltiplos brokers e replicação
- Sempre monitore o uso de disco dos volumes
- Use `consumer groups` para escalabilidade
- Implemente tratamento de erros robusto



