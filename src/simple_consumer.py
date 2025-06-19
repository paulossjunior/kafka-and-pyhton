from kafka import KafkaConsumer
import json
import os
import random

def simple_consumer():
    bootstrap_servers = os.getenv("BOOTSTRAP_SERVERS", "localhost:9092")
    group_id = f'meu-grupo-{random.randint(1000, 9999)}'
    consumer = KafkaConsumer(
        'meu-topico',
        bootstrap_servers=[bootstrap_servers],
        group_id=group_id,
        value_deserializer=lambda m: json.loads(m.decode('utf-8')),
        auto_offset_reset='earliest'  # Lê desde o início
    )
    
    print(f"Aguardando mensagens no group_id={group_id}... (Ctrl+C para sair)")
    
    try:
        for message in consumer:
            print(f"Recebido: {message.value}")
            
            # Aqui você processa sua mensagem
            # Exemplo: salvar no banco, enviar email, etc.
            
    except KeyboardInterrupt:
        print("Consumer interrompido")
    finally:
        consumer.close()


if __name__ == "__main__":
    simple_consumer()
    