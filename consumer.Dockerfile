# Imagem base
FROM python:3.11-slim

# Diretório de trabalho dentro do container
WORKDIR /app

# Copia apenas requirements para instalar dependências primeiro (cache)
COPY requirements.txt .

# Instala dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copia o arquivo do consumer
COPY src/simple_consumer.py .

# Comando padrão para rodar o consumer
CMD ["python", "simple_consumer.py"]
